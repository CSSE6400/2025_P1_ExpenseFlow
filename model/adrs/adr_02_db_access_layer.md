# ADR 02

## Database Access Layer

This ADR relates to how backend services access the data persistence layer.

## Importance

This is an important aspect to the system as ExpenseFlow is data driven and requires database access.

## Options

- RAW SQL
- ORM

## Comparison

- RAW SQL requires you to know SQL which may be daunting
- Not everyone in the team is familiar with SQL
- ORMs are easier to work with and gives type safety (to an extent, mypy was used here)
- ORMs (especially in active record patterns) can mix the data access layer with the service layer (Having orm db models used throughout the app - can be avoided by using POCO classes; however, this is more overhead)

## Chosen Outcome

SQLAlchemy was used as our ORM....
