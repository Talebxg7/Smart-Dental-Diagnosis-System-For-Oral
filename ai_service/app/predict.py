import io
import os
from pathlib import Path

import torch
from PIL import Image
from torchvision import transforms

from models.oral_model import (
    OralDiseaseModel,
    DISEASE_CLASSES,
    SEVERITY_CLASSES,
    get_recommendation,
)

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]
IMAGE_SIZE = 224

_transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
])

_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
_model: OralDiseaseModel | None = None
_model_path: str | None = None


def load_model(path: str | None = None) -> OralDiseaseModel:
    global _model, _model_path
    path = path or os.environ.get("MODEL_PATH", "model.pt")
    if _model is not None and _model_path == path:
        return _model
    model = OralDiseaseModel()
    p = Path(path)
    if p.exists():
        try:
            state = torch.load(p, map_location=_device, weights_only=True)
            model.load_state_dict(state, strict=False)
        except Exception:
            pass
    model.to(_device)
    model.eval()
    _model = model
    _model_path = path
    return model


def preprocess_image(image_bytes: bytes | str) -> torch.Tensor:
    if isinstance(image_bytes, str):
        img = Image.open(image_bytes).convert("RGB")
    else:
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    return _transform(img).unsqueeze(0)


def predict(image_bytes: bytes | str) -> dict:
    model = load_model()
    x = preprocess_image(image_bytes).to(_device)
    with torch.no_grad():
        disease_logits, severity_logits = model(x)
        disease_probs = torch.softmax(disease_logits, dim=1)
        severity_probs = torch.softmax(severity_logits, dim=1)
    disease_idx = disease_probs.argmax(1).item()
    severity_idx = severity_probs.argmax(1).item()
    disease = DISEASE_CLASSES[disease_idx]
    severity = SEVERITY_CLASSES[severity_idx]
    confidence = float(disease_probs[0, disease_idx].item())
    recommendation = get_recommendation(disease, severity)
    return {
        "disease_type": disease,
        "severity": severity,
        "confidence_score": confidence,
        "recommendation": recommendation,
    }
