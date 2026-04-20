from pathlib import Path
from datetime import datetime

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader

from app.models.scan import Scan
from app.models.user import User


def generate_scan_report(scan: Scan, user: User, image_path: str | None) -> bytes:
    """Generate PDF report for a scan. Returns PDF bytes."""
    from io import BytesIO

    buffer = BytesIO()
    c = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4

    # Title
    c.setFont("Helvetica-Bold", 18)
    c.drawString(2 * cm, height - 2 * cm, "Smart Dental Diagnosis - Scan Report")

    # Patient & date
    c.setFont("Helvetica", 11)
    y = height - 2.8 * cm
    c.drawString(2 * cm, y, f"Patient: {user.first_name} {user.last_name}")
    y -= 0.5 * cm
    c.drawString(2 * cm, y, f"Scan date: {scan.created_at.strftime('%Y-%m-%d %H:%M') if scan.created_at else '—'}")

    # Image if available
    if image_path and Path(image_path).exists():
        try:
            img = ImageReader(image_path)
            iw, ih = img.getSize()
            max_w, max_h = 14 * cm, 10 * cm
            scale = min(max_w / iw, max_h / ih, 1)
            c.drawImage(image_path, 2 * cm, y - max_h - 0.5 * cm, width=iw * scale, height=ih * scale)
            y -= max_h + 1 * cm
        except Exception:
            pass
    else:
        y -= 1 * cm

    # Results
    c.setFont("Helvetica-Bold", 12)
    c.drawString(2 * cm, y, "Results")
    c.setFont("Helvetica", 10)
    y -= 0.6 * cm
    c.drawString(2 * cm, y, f"Detected condition: {scan.disease_type or '—'}")
    y -= 0.5 * cm
    c.drawString(2 * cm, y, f"Severity: {scan.severity or '—'}")
    y -= 0.5 * cm
    c.drawString(2 * cm, y, f"Confidence: {(scan.confidence_score * 100) if scan.confidence_score is not None else 0:.1f}%")
    y -= 0.8 * cm
    if scan.recommendation:
        c.drawString(2 * cm, y, "Recommendation:")
        y -= 0.4 * cm
        # Simple wrap
        for line in _wrap(scan.recommendation, 80):
            c.drawString(2 * cm, y, line)
            y -= 0.4 * cm
    y -= 0.8 * cm

    # Disclaimer
    c.setFont("Helvetica-Oblique", 9)
    disclaimer = (
        "This system provides preliminary AI-based screening and does not replace "
        "professional dental consultation."
    )
    for line in _wrap(disclaimer, 90):
        c.drawString(2 * cm, y, line)
        y -= 0.35 * cm

    c.save()
    buffer.seek(0)
    return buffer.read()


def _wrap(text: str, max_chars: int) -> list[str]:
    words = text.split()
    lines = []
    current: list[str] = []
    length = 0
    for w in words:
        need = len(w) + (1 if current else 0)
        if length + need <= max_chars:
            current.append(w)
            length += need
        else:
            if current:
                lines.append(" ".join(current))
            current = [w]
            length = len(w)
    if current:
        lines.append(" ".join(current))
    return lines
