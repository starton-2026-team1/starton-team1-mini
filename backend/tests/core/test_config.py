from app.core.config import Settings


def test_cors_origins_are_trimmed_and_normalized() -> None:
    settings = Settings(
        database_url="sqlite+aiosqlite:///:memory:",
        jwt_secret_key="test-secret-key-at-least-32-bytes-long",
        cors_origins=" https://example.com/, https://app.example.com ",
    )

    assert settings.allowed_cors_origins == [
        "https://example.com",
        "https://app.example.com",
    ]
