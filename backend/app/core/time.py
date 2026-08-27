from datetime import datetime, timedelta, timezone

KST = timezone(timedelta(hours=9))


# DB의 기존 naive DATETIME 형식을 유지하면서 모든 서버 계산 기준을 KST로 고정
def now_kst_naive() -> datetime:
    return datetime.now(KST).replace(tzinfo=None)


# 오프셋이 있는 입력은 KST로 변환하고, 기존 naive 입력은 KST 값으로 간주
def to_kst_naive(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value
    return value.astimezone(KST).replace(tzinfo=None)


# DB에서 읽은 naive KST 시간을 API에서 명확한 +09:00 ISO 문자열로 직렬화
def kst_isoformat(value: datetime) -> str:
    return to_kst_naive(value).replace(tzinfo=KST).isoformat()


# DB 서버가 생성한 UTC naive 시각을 KST 오프셋이 포함된 문자열로 변환
def utc_naive_to_kst_isoformat(value: datetime) -> str:
    if value.tzinfo is None:
        value = value.replace(tzinfo=timezone.utc)
    return value.astimezone(KST).isoformat()
