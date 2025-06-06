# ADR 01

## Authentication

This ADR relates to how users are authenticated and authorised in Expenseflow.

## Importance

- Authentication is important in the system as users must be identifier before making any actions (i.e., they must be a valid user).
- Authorisation is importatnt as users should have limited scope in terms of what they can do (e.g., they should not be able to view the expenses of another person without permission)

## Options

- No Auth
- DIY Auth
- Auth Provider (Auth0, Cognito, etc.)

## Comparison

Obviously not implementing auth would be the easiest option; however, with this it would be impossible to identify users and what they could do. Additionally, in a more practical example, if a user was to open the app and view all their expenses, how would they know which expenses are theirs?

- No auth is easy but everyone has access to everyone's data
- DIY Auth would also be somewhat easy and super flexible; however, its still not very secure
- Auth Provider would be more work to implement and setup; however, user information would be a lot more secure
- Auth Provider (when using JWT) is more secure but includes token expiration and rotation

## Chosen Outcome

The auth provider option was chosen as it was the most secure and security was one of the project's quality attributes. After further investigation into our optoins, Auth0 was chosen as our auth provider as other auth providers (aws cognito) were deemed to be complex to setup and didn't offer the functionality that Auth0 offered us. Our auth0 setup could also be managed via Terraform so deployment was less complex.
