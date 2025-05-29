"""Plugin to generate reports."""
from fastapi.responses import FileResponse
from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.plugin import Plugin, PluginSettings, plugin_registry
from typing import Any, Dict, List
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.service import get_uploaded_expenses, get_expense
import asyncio
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime as dt
import os
from io import BytesIO
import matplotlib.pyplot as plt
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors

from pydantic import BaseModel

class ReportGenSettings(PluginSettings):
    """ReportGen 插件的配置类，匹配 plugin_config.yml 中的字段"""
    budget: int

@plugin_registry.register("report_gen")
class ReportGenPlugin(Plugin[PluginSettings]):
    """Report generation plugin."""
    _settings_type = ReportGenSettings

    def _on_init(self) -> None:
        """Register report generation endpoint."""
        
        self._app.add_api_route(
            "/report",
            self.generate_report,
            methods=["GET"],
        )

    def _on_call(self, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Do this method on call."""


    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True


    def shutdown(self) -> None:
        """Shutdown plugin."""


    async def generate_report(self, db: DbSession, user: CurrentUser) -> FileResponse:
        """Route to generate reports for the user."""
        import uuid
        self.CHART_PATH = f"chart_{uuid.uuid4()}.png"
        self.PDF_PATH = f"report_{uuid.uuid4()}.pdf"
        budget_data = await self.get_budget_and_distribution(db, user)
        transactions = await self.get_recent_transactions(db, user)
        await self.generate_chart(db, user)
        self.generate_pdf_report(budget_data, transactions)
        return FileResponse(self.PDF_PATH, media_type='application/pdf', filename=self.PDF_PATH)

    async def get_budget_and_distribution(self, db: DbSession, user: CurrentUser) -> Dict[str, Any]:
        """Get budget data and category distribution using service methods."""

        uploaded_expenses = await get_uploaded_expenses(db, user)
        
        
        total_spent = sum(
            item.price * split.proportion * item.quantity
            for expense in uploaded_expenses 
            for item in expense.items 
            for split in item.splits
        )

        # Calculate category distribution
        category_distribution = {}
        for expense in uploaded_expenses:
            for item in expense.items:
                i_total_price = item.price * item.quantity * sum(split.proportion for split in item.splits)
                if expense.category in category_distribution:
                    category_distribution[expense.category] += i_total_price
                else:
                    category_distribution[expense.category] = i_total_price

        return {
            "budget": self._config.budget,
            "spent": total_spent,
            "remaining": self._config.budget - total_spent,
            "category_distribution": category_distribution
        }

    async def get_recent_transactions(self, db: DbSession, user: CurrentUser) -> List[ExpenseModel]:
        """Get recent transactions using service methods."""
        uploaded = await get_uploaded_expenses(db, user)

        return sorted(uploaded, key=lambda x: x.created_at, reverse=True)

    async def generate_chart(self, db: DbSession, user: CurrentUser) -> None:
        """Generate expense distribution chart."""
        category_data = await self.get_budget_and_distribution(db, user)
        categories = list(category_data["category_distribution"].keys())
        amounts = list(category_data["category_distribution"].values())
        
        def _generate():
            plt.figure(figsize=(8, 6))
            plt.pie(amounts, labels=categories, autopct='%1.1f%%')
            plt.axis('equal')
            plt.title(f"Expenses Distribution ({dt.now().strftime('%Y-%m-%d')})")
            plt.tight_layout()
            plt.savefig(self.CHART_PATH, format='png')
            plt.close()
        
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(ThreadPoolExecutor(max_workers=2), _generate)

    def generate_pdf_report(self, budget_data: Dict[str, Any], recent_transactions: List[ExpenseModel]) -> None:
        buffer = BytesIO()
        c = canvas.Canvas(buffer, pagesize=letter)
        width, height = letter
        styles = getSampleStyleSheet()
        left_margin = 50
        top_margin = height - 50
        line_height = 14
        section_gap = 20

        # Title
        c.setFont("Helvetica-Bold", 16)
        c.drawString(left_margin, top_margin, "Expense Report")
        top_margin -= line_height + 10

        # Budget Data
        c.setFont("Helvetica-Bold", 12)
        top_margin -= line_height + 5
        budget_rows = [
            ('Budget:', budget_data['budget']),
            ('Spent:', budget_data['spent']),
            ('Remaining:', budget_data['remaining'])
        ]

        for label, value in budget_rows:
            c.setFont("Helvetica", 10)
            c.drawString(left_margin, top_margin, f"{label}: {value}")
            top_margin -= line_height 

        top_margin -= section_gap

        # Category Distribution
        c.setFont("Helvetica-Bold", 12)
        c.drawString(left_margin, top_margin, "Category Distribution")
        top_margin -= line_height + 5
        if os.path.exists(self.CHART_PATH):
            c.drawImage(self.CHART_PATH, left_margin, top_margin - 150, width=300, height=150)
            top_margin -= 170
        
        top_margin -= section_gap

        # Recent Transactions
        c.setFont("Helvetica-Bold", 12)
        c.drawString(left_margin, top_margin, "Recent Transactions")
        top_margin -= line_height + 15

        headers = ['Date', 'ExpenseID', 'Price']
        col_widths = [80, 250, 80]
        row_height = 20

        x = left_margin
        y = top_margin
        c.setFont("Helvetica-Bold", 10)
        for i, header in enumerate(headers):
            c.setFillColor(colors.lightblue)
            c.rect(x, y, col_widths[i], row_height, fill=1)
            c.setFillColor(colors.black)
            c.drawString(x + 5, y + 5, header)
            x += col_widths[i]
        y -= row_height + 5

        for t in recent_transactions:
            x = left_margin
            name = getattr(t, 'name', '')[:30] + "..." if len(getattr(t, 'name', '')) > 30 else getattr(t, 'name', '')
            date_str = t.created_at.strftime("%Y-%m-%d") if hasattr(t, 'created_at') else ""
            price = f"${sum(
            item.price * item.quantity * split.proportion
            for item in t.items
            for split in item.splits
            ):.2f}"
            
            for i, val in enumerate([date_str, name, price]):
                c.rect(x, y, col_widths[i], row_height, fill=0)
                c.drawString(x + 5, y + 5, val)
                x += col_widths[i]
            y -= row_height + 8

            
            items = getattr(t, "items", [])
            for item in items:
                item_name = getattr(item, "name", "")
                item_price = getattr(item, "price", "")
                item_quantity = getattr(item, "quantity", "")
                c.setFont("Helvetica", 9)
                c.drawString(left_margin + 20, y + 5, f"Item: {item_name}, Price: {item_price}, Quantity: {item_quantity}")
                y -= row_height
                if y < 50:
                    c.showPage()
                    y = height - 50
            y -= 5
            if y < 50:
                c.showPage()
                y = height - 50

        c.save()
        buffer.seek(0)
        with open(self.PDF_PATH, 'wb') as f:
            f.write(buffer.read())
