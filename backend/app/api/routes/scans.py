import os
import uuid
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.responses import Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.config import get_settings
from app.api.deps import get_current_user
from app.models.user import User
from app.models.scan import Scan
from app.schemas.scan import ScanResponse, ScanUploadResponse
from app.services.ai_client import predict_from_image
from app.services.pdf_service import generate_scan_report

router = APIRouter(prefix="/scans", tags=["scans"])


def _allowed_file(filename: str) -> bool:
    ext = Path(filename).suffix.lower()
    return ext in {".jpg", ".jpeg", ".png", ".webp"}


@router.post("/upload", response_model=ScanUploadResponse)
async def upload_scan(
    current_user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
    file: UploadFile = File(...),
):
    settings = get_settings()
    if not file.filename or not _allowed_file(file.filename):
        raise HTTPException(status_code=400, detail="Allowed formats: jpg, png, webp")

    content = await file.read()
    if len(content) > settings.max_upload_mb * 1024 * 1024:
        raise HTTPException(status_code=400, detail=f"File too large (max {settings.max_upload_mb}MB)")

    upload_dir = Path(settings.upload_dir)
    upload_dir.mkdir(parents=True, exist_ok=True)
    safe_name = f"{uuid.uuid4().hex}{Path(file.filename).suffix.lower()}"
    save_path = upload_dir / safe_name
    save_path.write_bytes(content)

    try:
        result = await predict_from_image(str(save_path))
    except Exception as e:
        result = {
            "disease_type": "Unknown",
            "severity": "Low",
            "confidence_score": 0.0,
            "recommendation": f"Analysis failed: {e}. Please consult a dentist.",
        }

    scan = Scan(
        user_id=current_user.id,
        image_path=str(save_path),
        disease_type=result.get("disease_type"),
        severity=result.get("severity"),
        confidence_score=result.get("confidence_score"),
        recommendation=result.get("recommendation"),
    )
    db.add(scan)
    await db.commit()
    await db.refresh(scan)

    return ScanUploadResponse(
        id=scan.id,
        disease_type=scan.disease_type,
        severity=scan.severity,
        confidence_score=scan.confidence_score,
        recommendation=scan.recommendation,
        image_path=scan.image_path,
    )


@router.get("", response_model=list[ScanResponse])
async def list_scans(
    current_user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Scan).where(Scan.user_id == current_user.id).order_by(Scan.created_at.desc())
    )
    scans = result.scalars().all()
    return [
        ScanResponse(
            id=s.id,
            user_id=s.user_id,
            image_path=s.image_path,
            disease_type=s.disease_type,
            severity=s.severity,
            confidence_score=s.confidence_score,
            recommendation=s.recommendation,
            created_at=s.created_at.isoformat() if s.created_at else None,
        )
        for s in scans
    ]


@router.get("/{scan_id}", response_model=ScanResponse)
async def get_scan(
    scan_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Scan).where(Scan.id == scan_id, Scan.user_id == current_user.id)
    )
    scan = result.scalar_one_or_none()
    if not scan:
        raise HTTPException(status_code=404, detail="Scan not found")
    return ScanResponse(
        id=scan.id,
        user_id=scan.user_id,
        image_path=scan.image_path,
        disease_type=scan.disease_type,
        severity=scan.severity,
        confidence_score=scan.confidence_score,
        recommendation=scan.recommendation,
        created_at=scan.created_at.isoformat() if scan.created_at else None,
    )


@router.get("/{scan_id}/report")
async def get_scan_report(
    scan_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Scan).where(Scan.id == scan_id, Scan.user_id == current_user.id)
    )
    scan = result.scalar_one_or_none()
    if not scan:
        raise HTTPException(status_code=404, detail="Scan not found")
    pdf_bytes = generate_scan_report(scan, current_user, scan.image_path if os.path.exists(scan.image_path) else None)
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="dental_scan_{scan_id}.pdf"'},
    )
