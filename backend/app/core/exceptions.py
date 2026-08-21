class AppError(Exception):
    """Base exception for application-level errors."""


class AuthenticationError(AppError):
    pass


class ProductNotFoundError(AppError):
    pass


class ProductPermissionError(AppError):
    pass


class ProductStateError(AppError):
    pass
