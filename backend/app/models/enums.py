from enum import StrEnum


class SaleType(StrEnum):
    FIXED_PRICE = "FIXED_PRICE"
    AUCTION = "AUCTION"


class ProductStatus(StrEnum):
    ACTIVE = "ACTIVE"
    SOLD = "SOLD"
    CANCELLED = "CANCELLED"


class AuctionStatus(StrEnum):
    WAITING = "WAITING"
    ACTIVE = "ACTIVE"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
