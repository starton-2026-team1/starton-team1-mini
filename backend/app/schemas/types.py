from datetime import datetime
from typing import Annotated

from pydantic import PlainSerializer

from app.core.time import kst_isoformat, utc_naive_to_kst_isoformat

KstDateTime = Annotated[
    datetime,
    PlainSerializer(kst_isoformat, return_type=str),
]

UtcDateTime = Annotated[
    datetime,
    PlainSerializer(utc_naive_to_kst_isoformat, return_type=str),
]
