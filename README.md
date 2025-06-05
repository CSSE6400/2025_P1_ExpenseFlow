# CSSE6400 ExpenseFlow project

## [Website](https://expenseflow.g3.csse6400.xyz/) | [Proposal](https://csse6400.github.io/project-proposal-2025/s4744008/proposal.html) | [Report](report/report.pdf) | [Video]()

## Description

Have you ever had to explain a suspiciously large 'business lunch', wonder where all your money went, or chase down friends for their share of last night's dinner? With ExpenseFlow, budget leaks become a thing of the past and you'll never have to play detective with your finances again. 

ExpenseFlow is a comprehensive expense management tool aimed at both individuals and businesses. It simplifies financial tracking and reporting through an intuitive interface. With automated document scanning and auto-generated reports, ExpenseFlow empowers users to gain financial clarity and control. It offers easy budget management and spending analysis for individuals, making expense management effortless and transparent. 

## Authors

This project has been completed solely by members of Team ExpenseFlow.

### Frontend

- [Aaditya Yadav](https://github.com/aadityayadav17)
- [Ella Berglas](https://github.com/EllaBerglas)
- [Lucas Hicks](https://github.com/lucashicks1)

### Backend & Plugins

- [Donghyug David Jeong](https://github.com/DonghyugDavidJeong)
- [Lucas Hicks](https://github.com/lucashicks1)
- [Ruidong Ding](https://github.com/aa879861)

### Testing

- [Donghyug David Jeong](https://github.com/DonghyugDavidJeong)
- [Lucas Hicks](https://github.com/lucashicks1)

### Devops (Infra & Tooling)

- [Lucas Hicks](https://github.com/lucashicks1)

## Project Structure

Below is the project structure for ExpenseFlow:

```bash
./
├── api/        # Backend, built in python using FastAPI
├── assets/     # Various project-related assets
├── infra/      # This is where all the IaC lives (Terraform)
├── model/      # Model artefacts (e.g. Structurizr DSL or PUML files)
├── report/     # Project report
├── ui/         # Frontend, with Flutter
├── ...         # Other top-level files
```

## Getting started

### Local

The quickest and easiest way to get the project running on your local machine is to use [Docker Compose](https://docs.docker.com/compose/). This will let you build and run the backend, frontend and database containers locally.


#### Environment Variables

Before running `docker compose`, you must create `.env` file in the project root directory, with the following values:

```bash
POSTGRES_PASSWORD=...   # Password for the local PostgreSQL DB.
POSTGRES_USER=...       # Username for the local PostgreSQL DB.
POSTGRES_DB=...         # Database name for the local PostgreSQL DB.
AUTH0_DOMAIN=...        # Domain name of your Auth0 Tenant (Auth0 is used for authentication in the project).
AUTH0_CLIENT_ID=...     # Client ID of your Auth0 Client Application
JWT_AUDIENCE=...        # Identifier of your Auth0 API Application (Resource Server)
```

_Notes:_

- The values for the `POSTGRES_` variables are completely up to you.
- You must also have an Auth0 tenant setup to run this project. To deploy this using Terraform, view [here](infra/auth0.tf).

#### Docker Compose

Then you must run `docker compose up -d` to build the containers and run them. To force the images to be built again use the `--build` flag.

Once up and running, the following will be available:

- UI -> `localhost:3000`
- API -> `localhost:8080` (The base path `/` will redirect you to the docs `/docs`)

#### Removing Containers

Once you are reading, you can stop the containers with `docker compose down`. If would also like to remove the database volume created when running the containers, add the `--volumes` flag.

### Remote Deployment

To deploy remotely, store the AWS credentials in a file called `credentials` (file name must be exact), in the root directory, then run `./infra/deploy-infra.sh [--auto]`, with `--auto` being optional if you want to run confirmations automatically. 

## Testing

### Backend

Backend tests are done using `pytest` and require a running postgres instance to work. The easiest way to run this database is using `docker compose up database`.

To run the tests, you must navigate to the `api/` directory and run `pytest`.

```bash
docker compose up database -d  # Run DB used for testing
cd api/                        # Change directory
pytest                         # Run tests
```

For automated tests, we use GitHub Actions which run the same test suite.