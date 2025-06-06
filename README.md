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

### Frontend & Backend Integration

- [Ella Berglas](https://github.com/EllaBerglas)
- [Lucas Hicks](https://github.com/lucashicks1)

### Backend

- [Lucas Hicks](https://github.com/lucashicks1)

### Plugins

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

> [!NOTE]
> The `local.sh` and `kill_local.sh` all require Docker Compose to be installed on your machine.

#### Environment Variables

Before starting the app with `./local.sh ` you must have Docker compose installed and must have a `.env` file in the project root directory, with the following values:

```bash
AUTH0_DOMAIN=...        # Domain name of your Auth0 Tenant (Auth0 is used for authentication in the project).
AUTH0_CLIENT_ID=...     # Client ID of your Auth0 Client Application
JWT_AUDIENCE=...        # Identifier of your Auth0 API Application (Resource Server)
```

> [!IMPORTANT]
> You must also have an Auth0 tenant setup to run this project. To can be deployed using [Terraform](infra/auth0.tf) or if you have access to the repo settings, you will be able to find our Auth0 secrets in **Settings** > **Secrets and Variables** > **Actions**

Then run `./local.sh`. This will make the following will be available:

- Web UI -> `localhost:3000`
- API -> `localhost:8080` (The base path `/` will redirect you to the docs `/docs`)

Once you are finished with the application, run `./kill_local.sh` to stop everything.

### Remote Deployment

> [!NOTE]
> Our deployment is done using Terraform, so you will need it installed. [Official Terraform Install Guide](https://developer.hashicorp.com/terraform/install)

> [!TIP]
> You can skip this process by running the [Infrastructure Deployment](https://github.com/CSSE6400/2025_P1_ExpenseFlow/actions/workflows/infrastructure_deploy.yml) workflow with your aws credentials as input.

To deploy to AWS, put your aws credentials in a file called `credentials` in the root directory (file name must be **exact**).

> [!NOTE] Your AWS credentials must be in the following format:

```bash
[profile_name]
aws_access_key_id=...
aws_secret_access_key=...
aws_session_token=...
```

You must also have a `terraform.tfvars` file in the `/infra` directory to contain the following values:

```bash
db_password         = ...
auth0_domain        = ... # Same value as local deployment
auth0_client_id     = ... # Same value as local deployment
auth0_client_secret = ... # Same value as local deployment
sentry_dsn          = "https://f0e2babc247dfbc9bef0b233664acab0@o4509370795032576.ingest.us.sentry.io/4509370811219968"
```

Once complete, run `./infra/deploy-infra.sh [--auto]`, with `--auto` being optional if you want to run confirmations automatically.

To remove the infrastructure, run `./infra/teardown.sh [--auto]`, with `--auto` being optional if you want to run confirmations automatically.

## Testing

### Backend

To run the unit and integration tests on the backend, run:

```bash
./test.sh
```

> [!NOTE]
> This requires Docker Compose to be installed and an internet connection to pull the postgres image.

This script uses Docker Compose as a running postgres instance is required to run the Pytest tests. Once complete, this script will also output the code coverage details.

> [!TIP]
> You can skip this process by running the [Backend Tests](https://github.com/CSSE6400/2025_P1_ExpenseFlow/actions/workflows/backend_tests.yml) workflow which will run tests and a static type checking tool on the code.
