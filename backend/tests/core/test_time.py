from datetime import UTC, datetime, timedelta, timezone

import pytest
from pydantic import ValidationError

from app.core.time import (
    kst_isoformat,
    to_kst_naive,
    utc_naive_to_kst_isoformat,
)
from app.models.enums import AuctionStatus
from app.schemas.auction import AuctionCreate, AuctionPreviewResponse


def test_utc_datetime_is_normalized_to_kst_naive() -> None:
    utc_value = datetime(2026, 8, 23, 1, tzinfo=UTC)

    assert to_kst_naive(utc_value) == datetime(2026, 8, 23, 10)


def test_kst_datetime_is_serialized_with_offset() -> None:
    value = datetime(2026, 8, 23, 10)

    assert kst_isoformat(value) == "2026-08-23T10:00:00+09:00"


def test_utc_naive_datetime_is_serialized_as_kst() -> None:
    value = datetime(2026, 8, 23, 1)

    assert utc_naive_to_kst_isoformat(value) == "2026-08-23T10:00:00+09:00"


def test_other_timezone_is_converted_to_kst() -> None:
    value = datetime(
        2026,
        8,
        23,
        10,
        tzinfo=timezone(timedelta(hours=-4)),
    )

    assert to_kst_naive(value) == datetime(2026, 8, 23, 23)


def test_auction_create_normalizes_utc_fields_to_kst_naive() -> None:
    data = AuctionCreate(
        category_id=1,
        title="테스트 경매",
        description="시간대 변환 테스트",
        start_price=1000,
        minimum_bid_unit=100,
        starts_at="2026-08-23T01:00:00Z",
        ends_at="2026-08-23T02:00:00Z",
    )

    assert data.starts_at == datetime(2026, 8, 23, 10)
    assert data.ends_at == datetime(2026, 8, 23, 11)


def test_auction_create_rejects_bid_unit_above_start_price() -> None:
    with pytest.raises(
        ValidationError,
        match="최소 입찰 단위는 시작 가격을 넘을 수 없습니다.",
    ):
        AuctionCreate(
            category_id=1,
            title="테스트 경매",
            description="가격 검증 테스트",
            start_price=1000,
            minimum_bid_unit=1001,
            starts_at="2026-08-23T01:00:00Z",
            ends_at="2026-08-23T02:00:00Z",
        )


def test_auction_create_allows_bid_unit_equal_to_start_price() -> None:
    data = AuctionCreate(
        category_id=1,
        title="테스트 경매",
        description="가격 경계값 테스트",
        start_price=1000,
        minimum_bid_unit=1000,
        starts_at="2026-08-23T01:00:00Z",
        ends_at="2026-08-23T02:00:00Z",
    )

    assert data.minimum_bid_unit == data.start_price


def test_auction_response_serializes_kst_offset() -> None:
    response = AuctionPreviewResponse(
        id=1,
        title="테스트 경매",
        category_name="기타",
        status=AuctionStatus.ACTIVE,
        thumbnail_url=None,
        start_price=1000,
        current_price=1000,
        minimum_bid_unit=100,
        bid_count=0,
        starts_at=datetime(2026, 8, 23, 10),
        ends_at=datetime(2026, 8, 23, 11),
    )

    payload = response.model_dump(mode="json")
    assert payload["starts_at"] == "2026-08-23T10:00:00+09:00"
    assert payload["ends_at"] == "2026-08-23T11:00:00+09:00"
