from datetime import datetime
from typing import Annotated

from pydantic import PlainSerializer

from app.core.time import kst_isoformat

KstDateTime = Annotated[
    datetime,
    PlainSerializer(kst_isoformat, return_type=str),
]
