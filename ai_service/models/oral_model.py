import torch
import torch.nn as nn
from torchvision import models

DISEASE_CLASSES = ["Caries", "Plaque", "Tartar", "Gingivitis", "Healthy"]
SEVERITY_CLASSES = ["Low", "Moderate", "High"]
NUM_DISEASE = len(DISEASE_CLASSES)
NUM_SEVERITY = len(SEVERITY_CLASSES)


class OralDiseaseModel(nn.Module):
    """EfficientNet-B0 with disease (5-class) and severity (3-class) heads."""

    def __init__(self, num_disease: int = NUM_DISEASE, num_severity: int = NUM_SEVERITY):
        super().__init__()
        self.backbone = models.efficientnet_b0(weights=models.EfficientNet_B0_Weights.IMAGENET1K_V1)
        in_features = self.backbone.classifier[1].in_features
        self.backbone.classifier = nn.Identity()
        self.disease_head = nn.Linear(in_features, num_disease)
        self.severity_head = nn.Linear(in_features, num_severity)
        self.num_disease = num_disease
        self.num_severity = num_severity

    def forward(self, x: torch.Tensor):
        features = self.backbone(x)
        disease_logits = self.disease_head(features)
        severity_logits = self.severity_head(features)
        return disease_logits, severity_logits


def get_recommendation(disease: str, severity: str) -> str:
    recommendations = {
        "Caries": {
            "Low": "Minor decay detected. Consider fluoride treatment and improved oral hygiene. Schedule a check-up.",
            "Moderate": "Moderate caries. Dental filling likely needed. Please see a dentist soon.",
            "High": "Significant decay. Urgent dental care recommended for restoration or root canal.",
        },
        "Plaque": {
            "Low": "Light plaque buildup. Brush twice daily and floss. Consider professional cleaning.",
            "Moderate": "Moderate plaque. Improve brushing technique and schedule a cleaning.",
            "High": "Heavy plaque. Professional cleaning recommended. Focus on daily oral care.",
        },
        "Tartar": {
            "Low": "Some tartar present. Professional scaling recommended at next visit.",
            "Moderate": "Tartar buildup. Schedule scaling and root planing with your dentist.",
            "High": "Significant tartar. Professional scaling needed to prevent gum disease.",
        },
        "Gingivitis": {
            "Low": "Mild gum inflammation. Improve flossing and use antiseptic mouthwash. See dentist if it persists.",
            "Moderate": "Moderate gingivitis. Professional cleaning and improved home care recommended.",
            "High": "Severe gingivitis. Please see a dentist for evaluation and treatment.",
        },
        "Healthy": {
            "Low": "No significant issues detected. Maintain good oral hygiene and regular check-ups.",
            "Moderate": "No significant issues detected. Maintain good oral hygiene and regular check-ups.",
            "High": "No significant issues detected. Maintain good oral hygiene and regular check-ups.",
        },
    }
    return recommendations.get(disease, {}).get(severity, "Please consult a dentist for a professional assessment.")
