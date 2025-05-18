# CSSE6400 ExpenseFlow project

## Description

What is ExpenseFlow?

## Key Deliverables

- TODO

## Authors

This project has been completed solely by members of Team 3.

### Frontend

-

### Backend

-

### Devops (Infra & Tooling)

-

## Project Structure

Below is the project structure for ExpenseFlow:

```bash
./
├── api/        # Backend, built in python using FastAPI
├── ui/         # Frontend, with Flutter
├── infra/      # This is where all the IaC lives (Terraform)
├── assets/     # Various project-related assets
├── model/      # Model artefacts (e.g. Structurizr DSL or PUML files)
├── report/     # Project report
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

#### Removing Containers

Once you are reading, you can stop the containers with `docker compose down`. If would also like to remove the database volume created when running the containers, add the `--volumes` flag.

### Remote Deployment

## Testing

### Backend

Backend tests are done using `pytest` and require a running postgres instance to work. The easiest way to run this database is using `docker compose up database`.

To run the tests, you must navigate to the `api/` directory and run `pytest`.

```bash
docker compose up database  # Run DB used for testing
cd api/                     # Change directory
pytest                      # Run tests
```

## Architecture

- TODO

## Evaluation Criteria

- TODO
