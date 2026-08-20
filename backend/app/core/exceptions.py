class AppError(Exception):
    """Base exception for application-level errors."""


class AuthenticationError(AppError):
    pass
