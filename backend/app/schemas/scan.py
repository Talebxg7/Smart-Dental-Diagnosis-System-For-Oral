from pydantic import BaseModel


class ScanCreate(BaseModel):
    pass  # Created via upload


class ScanResponse(BaseModel):
    id: int
    user_id: int
    image_path: str
    disease_type: str | None
    severity: str | None
    confidence_score: float | None
    recommendation: str | None
    created_at: str | None = None

    model_config = {"from_attributes": True}


class ScanUploadResponse(BaseModel):
    id: int
    disease_type: str | None
    severity: str | None
    confidence_score: float | None
    recommendation: str | None
    image_path: str
