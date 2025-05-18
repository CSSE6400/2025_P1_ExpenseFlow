"""Utils."""


class SingletonMeta(type):
    """Meta class for singleton."""

    _instance = None

    def __call__(cls, *args, **kwargs):  # noqa: ANN002, ANN003, ANN204
        """Override call dunder method for singleton."""
        if cls._instance is None:
            cls._instance = super().__call__(*args, **kwargs)
        return cls._instance
