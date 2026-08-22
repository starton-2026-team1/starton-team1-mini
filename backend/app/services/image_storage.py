import uuid
from pathlib import Path

from fastapi import UploadFile

from app.core.config import settings


# 업로드된 이미지를 로컬 디스크에 저장 (나중에 S3 등으로 옮길 때 save()만 교체하면 되는 구조)
class ImageStorage:
    def __init__(self, upload_dir: str | None = None) -> None:
        self.root = Path(upload_dir or settings.upload_dir)
        self.root.mkdir(parents=True, exist_ok=True)

    async def save(self, files: list[UploadFile]) -> list[str]:
        urls = []
        for file in files:
            extension = Path(file.filename or "").suffix
            # 원본 파일명 대신 uuid로 저장해서 충돌/경로 조작 방지
            filename = f"{uuid.uuid4().hex}{extension}"
            content = await file.read()
            (self.root / filename).write_bytes(content)
            # main.py에서 /static/uploads 로 정적 서빙되는 경로와 맞춰야 함
            urls.append(f"/static/uploads/{filename}")
        return urls


# 요청마다 새로 안 만들고 프로세스 전체에서 공유
image_storage = ImageStorage()
