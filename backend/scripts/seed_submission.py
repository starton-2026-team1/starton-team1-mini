"""제출 시연용 데이터로 데이터베이스를 초기화한다."""

import argparse
import asyncio
from datetime import timedelta

from sqlalchemy import delete, text

from app.core.database import async_session_factory, close_database_connection
from app.core.time import now_kst_naive
from app.models import Auction, Bid, Category, Favorite, FixedPrice, Product, ProductImage, User
from app.models.enums import AuctionStatus, ProductStatus, SaleType

AUCTIONS = [
    (
        "에어팟 프로 2세대",
        "정상 작동하며 충전 케이스와 이어팁을 포함합니다.",
        "디지털기기",
        "airpods.jpg",
        80_000,
        5_000,
        3,
        [85_000, 90_000, 95_000],
    ),
    (
        "닌텐도 스위치 OLED",
        "생활 사용감이 있으며 본체, 독, 충전기를 포함합니다.",
        "게임",
        "nintendo.jpg",
        180_000,
        10_000,
        4,
        [190_000, 200_000],
    ),
    (
        "아이패드 9세대 64GB",
        "화면과 주요 기능이 정상이며 충전기를 함께 드립니다.",
        "디지털기기",
        "ipad.jpg",
        200_000,
        10_000,
        4,
        [210_000],
    ),
    (
        "소니 WH-1000XM5 헤드폰",
        "노이즈 캔슬링이 정상 작동하며 전용 케이스를 포함합니다.",
        "디지털기기",
        "sony.jpg",
        150_000,
        10_000,
        3,
        [160_000, 170_000, 180_000],
    ),
    (
        "레고 테크닉 스포츠카",
        "조립 후 전시한 제품이며 설명서를 포함합니다.",
        "취미",
        "lego.jpg",
        30_000,
        2_000,
        3,
        [32_000, 34_000],
    ),
    (
        "폴라로이드 즉석카메라",
        "정상 작동하며 촬영 가능한 필름 5장을 포함합니다.",
        "취미",
        "camera.jpg",
        40_000,
        5_000,
        4,
        [45_000],
    ),
    (
        "기계식 키보드 적축",
        "모든 키가 정상 작동하며 키캡과 연결 케이블을 포함합니다.",
        "생활가전",
        "keyboard.jpg",
        25_000,
        2_000,
        3,
        [27_000, 29_000],
    ),
    (
        "캠핑용 경량 체어 2개",
        "실사용 3회이며 각각의 보관 가방을 포함합니다.",
        "스포츠·레저",
        "chair.jpg",
        20_000,
        2_000,
        4,
        [],
    ),
    (
        "빈티지 턴테이블",
        "블루투스 연결과 내장 스피커가 정상 작동합니다.",
        "생활가전",
        "table.jpg",
        60_000,
        5_000,
        4,
        [65_000, 70_000],
    ),
    (
        "한정판 스니커즈 270mm",
        "정품이며 실착 2회, 제품 박스를 포함합니다.",
        "패션",
        "shoes.jpg",
        100_000,
        5_000,
        3,
        [105_000, 110_000, 115_000],
    ),
]

FIXED_PRODUCTS = [
    (
        "드립 커피 세트",
        "핸드드립 입문용 세트입니다. 드리퍼와 서버를 함께 드립니다.",
        "생활가전",
        "fixed_coffee.jpg",
        25_000,
    ),
    (
        "무드등 스탠드",
        "밝기 조절이 가능하고 따뜻한 색상의 조명입니다.",
        "생활가전",
        "fixed_lamp.jpg",
        18_000,
    ),
    (
        "여행용 백팩 30L",
        "노트북 수납 공간이 있으며 사용감이 적습니다.",
        "패션",
        "fixed_backpack.jpg",
        35_000,
    ),
    (
        "블루투스 스피커",
        "충전과 블루투스 연결 모두 정상 작동합니다.",
        "디지털기기",
        "fixed_speaker.jpg",
        42_000,
    ),
    (
        "소설책 8권 세트",
        "한 번 읽고 보관한 책으로 낙서나 찢김이 없습니다.",
        "도서",
        "fixed_books.jpg",
        24_000,
    ),
    (
        "미니멀 손목시계",
        "생활 방수 제품이며 배터리를 최근 교체했습니다.",
        "패션",
        "fixed_watch.jpg",
        30_000,
    ),
    (
        "공기정화 식물 화분",
        "관리하기 쉬운 실내 식물이며 화분을 포함합니다.",
        "생활",
        "fixed_plant.jpg",
        15_000,
    ),
    (
        "출퇴근용 자전거",
        "브레이크와 기어 점검을 마쳤고 바로 탈 수 있습니다.",
        "스포츠·레저",
        "fixed_bicycle.jpg",
        120_000,
    ),
    (
        "데님 재킷 100사이즈",
        "봄가을에 입기 좋은 제품으로 오염 없이 깨끗합니다.",
        "패션",
        "fixed_jacket.jpg",
        38_000,
    ),
    (
        "입문용 어쿠스틱 기타",
        "줄을 새로 교체했으며 소프트 케이스를 포함합니다.",
        "취미",
        "fixed_guitar.jpg",
        75_000,
    ),
]


async def reset_and_seed() -> None:
    # 외래 키 의존 순서에 맞춰 기존 데이터를 모두 제거
    async with async_session_factory() as session:
        for model in (Favorite, Bid, ProductImage, Auction, FixedPrice, Product, Category, User):
            await session.execute(delete(model))
        await session.commit()

        # 제출 DB를 처음부터 확인하기 쉽도록 자동 증가 식별자도 1부터 재시작
        for table_name in ("users", "categories", "products", "product_images", "auctions", "bids"):
            await session.execute(text(f"ALTER TABLE {table_name} AUTO_INCREMENT = 1"))
        await session.commit()

        seller = User(phone_number="01010000001", name="활기찬여우01")
        bidders = [
            User(phone_number="01010000002", name="호기심많은고양이02"),
            User(phone_number="01010000003", name="명랑한수달03"),
        ]
        category_names = list(
            dict.fromkeys([item[2] for item in AUCTIONS] + [item[2] for item in FIXED_PRODUCTS])
        )
        categories = {
            name: Category(name=name, sort_order=index) for index, name in enumerate(category_names)
        }
        session.add_all([seller, *bidders, *categories.values()])
        await session.flush()

        now = now_kst_naive()
        starts_at = now - timedelta(hours=1)
        for index, (
            title,
            description,
            category,
            image,
            start_price,
            bid_unit,
            days,
            amounts,
        ) in enumerate(AUCTIONS):
            product = Product(
                seller_id=seller.id,
                category_id=categories[category].id,
                sale_type=SaleType.AUCTION,
                title=title,
                description=description,
                status=ProductStatus.ACTIVE,
                created_at=now - timedelta(minutes=index * 2),
                updated_at=now - timedelta(minutes=index * 2),
            )
            session.add(product)
            await session.flush()
            session.add(
                ProductImage(
                    product_id=product.id, image_url=f"/static/uploads/{image}", sort_order=0
                )
            )

            # 운영진이 이틀 뒤 확인해도 모두 진행 중이도록 3일 또는 4일 뒤 종료
            auction = Auction(
                product_id=product.id,
                start_price=start_price,
                minimum_bid_unit=bid_unit,
                starts_at=starts_at,
                ends_at=now + timedelta(days=days, minutes=index * 7),
                status=AuctionStatus.ACTIVE,
                extension_count=0,
            )
            session.add(auction)
            await session.flush()
            for bid_index, amount in enumerate(amounts):
                bidder = bidders[bid_index % len(bidders)]
                session.add(Bid(auction_id=auction.id, bidder_id=bidder.id, amount=amount))

        for index, (title, description, category, image, price) in enumerate(FIXED_PRODUCTS):
            created_at = now - timedelta(minutes=index * 2 + 1)
            product = Product(
                seller_id=seller.id,
                category_id=categories[category].id,
                sale_type=SaleType.FIXED_PRICE,
                title=title,
                description=description,
                status=ProductStatus.ACTIVE,
                created_at=created_at,
                updated_at=created_at,
            )
            session.add(product)
            await session.flush()
            session.add_all(
                [
                    ProductImage(
                        product_id=product.id,
                        image_url=f"/static/uploads/{image}",
                        sort_order=0,
                    ),
                    FixedPrice(product_id=product.id, price=price),
                ]
            )

        await session.commit()

        # 생성된 데이터 수를 출력해 시드 결과 확인
        counts = {}
        for table_name in ("users", "categories", "products", "product_images", "auctions", "bids"):
            result = await session.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
            counts[table_name] = result.scalar_one()
        print(counts)


async def main() -> None:
    try:
        await reset_and_seed()
    finally:
        await close_database_connection()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--reset", action="store_true", help="기존 데이터를 삭제하고 제출 데이터를 생성"
    )
    args = parser.parse_args()
    if not args.reset:
        raise SystemExit("데이터 전체 삭제 작업입니다. 실행하려면 --reset을 지정하세요.")
    asyncio.run(main())
