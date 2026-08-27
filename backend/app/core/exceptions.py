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


# 경매 도메인 예외 (auction_service.py에서 발생, api/v1/auctions.py에서 HTTP 에러로 변환)
class AuctionNotFoundError(AppError):
    pass


# 판매자가 자신의 경매에 입찰하려고 할 때
class AuctionPermissionError(AppError):
    pass


# 진행 중이 아닌 경매에 입찰하려고 할 때
class AuctionStateError(AppError):
    pass


# 최소 입찰가보다 낮은 금액으로 입찰하려고 할 때
class BidAmountError(AppError):
    pass
