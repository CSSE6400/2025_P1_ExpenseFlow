import 'package:flutter/material.dart';
import 'package:expenseflow/models/enums.dart' show ExpenseStatus;

Color statusBackgroundColor(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.paid:
      return Colors.green.shade100;
    case ExpenseStatus.accepted:
      return Colors.orange.shade100;
    case ExpenseStatus.requested:
      return Colors.blueGrey.shade100;
  }
}

Color statusIconAndTextColor(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.paid:
      return Colors.green.shade800;
    case ExpenseStatus.accepted:
      return Colors.orange.shade800;
    case ExpenseStatus.requested:
      return Colors.blueGrey.shade700;
  }
}
