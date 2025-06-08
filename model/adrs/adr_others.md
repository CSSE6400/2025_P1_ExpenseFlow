# GROUPS AND USERS

Modelling them seperately

- easiest to do
- very little db complexity
- not flexible when more constructs are added (e.g., Business accounts)
- requires several dbs for expenses
- requires several db joins, impacting performance and potentially reliability (if there are bugs)

Modelling groups and users as entities

- More complex db setup
- no joins required
- one table for expenses
- can easily add more constructs without creating new tables (e.g., business account could also be treated as an entity)

# FRONTEND CHOICE

Web-based app for larger devices

- easiest to build
- less convinient for users to use

Mobile devices

- ExpenseFlow is aimed at personal use for the MVP
- more difficult to build phone application
