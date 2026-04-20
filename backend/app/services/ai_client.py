import httpx
from pathlib import Path

from app.core.config import get_settings


async def predict_from_image(image_path: str) -> dict:
    """Call AI service with image path. Returns dict with disease_type, severity, confidence_score, recommendation."""
    settings = get_settings()
    path = Path(image_path)
    if not path.exists():
        return _fallback_response("Image file not found")

    try:
        content = path.read_bytes()
        files = {"file": (path.name, content, "image/jpeg")}
        async with httpx.AsyncClient(timeout=60.0) as client:
            r = await client.post(
                f"{settings.ai_service_url}/predict",
                files=files,
            )
        if r.status_code != 200:
            return _fallback_response(f"AI service error: {r.status_code}")
        data = r.json()
        return {
            "disease_type": data.get("disease_type", "Unknown"),
            "severity": data.get("severity", "Low"),
            "confidence_score": float(data.get("confidence_score", 0.0)),
            "recommendation": data.get("recommendation", "Please consult a dentist."),
        }
    except Exception as e:
        return _fallback_response(str(e))


def _fallback_response(reason: str) -> dict:
    return {
        "disease_type": "Healthy",
        "severity": "Low",
        "confidence_score": 0.0,
        "recommendation": f"AI analysis unavailable ({reason}). Please consult a dentist for a professional assessment.",
    }
