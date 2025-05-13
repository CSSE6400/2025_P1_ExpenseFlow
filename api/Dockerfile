FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0


WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


# Final Image
FROM python:3.13-slim-bookworm

# Install curl
RUN apt-get update && apt-get install -y --no-install-recommends curl

# Put the app back in
COPY --from=builder --chown=app:app /app /app

WORKDIR /app

# Add to path
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 6400

CMD ["fastapi", "run", "--host", "0.0.0.0", "--port", "6400", "src/expenseflow/main.py"]