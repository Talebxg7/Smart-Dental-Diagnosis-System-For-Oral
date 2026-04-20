"""
Evaluation script: accuracy, precision, recall, F1 per class and macro.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import torch
from torch.utils.data import DataLoader
from sklearn.metrics import accuracy_score, precision_recall_fscore_support

from models.oral_model import OralDiseaseModel, DISEASE_CLASSES
from train import OralDataset


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", default="data", help="Dataset root")
    parser.add_argument("--model", default="model.pt")
    parser.add_argument("--batch", type=int, default=16)
    parser.add_argument("--device", default="cuda" if torch.cuda.is_available() else "cpu")
    args = parser.parse_args()

    dataset = OralDataset(args.data, is_train=False)
    if len(dataset) == 0:
        print("No images found.")
        return
    loader = DataLoader(dataset, batch_size=args.batch, shuffle=False)

    model = OralDiseaseModel()
    if os.path.exists(args.model):
        model.load_state_dict(torch.load(args.model, map_location=args.device, weights_only=True))
    model = model.to(args.device)
    model.eval()

    all_yd = []
    all_pred_d = []
    with torch.no_grad():
        for x, yd, _ in loader:
            x = x.to(args.device)
            logits_d, _ = model(x)
            pred_d = logits_d.argmax(1).cpu().tolist()
            all_yd.extend(yd.tolist())
            all_pred_d.extend(pred_d)

    acc = accuracy_score(all_yd, all_pred_d)
    prec, rec, f1, _ = precision_recall_fscore_support(all_yd, all_pred_d, average="macro", zero_division=0)
    print(f"Accuracy: {acc:.4f}")
    print(f"Macro Precision: {prec:.4f}")
    print(f"Macro Recall: {rec:.4f}")
    print(f"Macro F1: {f1:.4f}")
    prec_per, rec_per, f1_per, _ = precision_recall_fscore_support(
        all_yd, all_pred_d, average=None, labels=range(len(DISEASE_CLASSES)), zero_division=0
    )
    for i, name in enumerate(DISEASE_CLASSES):
        print(f"  {name}: P={prec_per[i]:.4f} R={rec_per[i]:.4f} F1={f1_per[i]:.4f}")


if __name__ == "__main__":
    main()
