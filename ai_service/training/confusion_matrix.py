"""
Generate confusion matrix plot and save to file.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import torch
from torch.utils.data import DataLoader
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import numpy as np

from models.oral_model import OralDiseaseModel, DISEASE_CLASSES
from train import OralDataset

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", default="data", help="Dataset root")
    parser.add_argument("--model", default="model.pt")
    parser.add_argument("--batch", type=int, default=16)
    parser.add_argument("--out", default="confusion_matrix.png")
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

    cm = confusion_matrix(all_yd, all_pred_d, labels=range(len(DISEASE_CLASSES)))
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(cm, interpolation="nearest", cmap=plt.cm.Blues)
    ax.set_xticks(np.arange(len(DISEASE_CLASSES)))
    ax.set_yticks(np.arange(len(DISEASE_CLASSES)))
    ax.set_xticklabels(DISEASE_CLASSES)
    ax.set_yticklabels(DISEASE_CLASSES)
    plt.setp(ax.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")
    for i in range(len(DISEASE_CLASSES)):
        for j in range(len(DISEASE_CLASSES)):
            ax.text(j, i, cm[i, j], ha="center", va="center", color="white" if cm[i, j] > cm.max() / 2 else "black")
    ax.set_title("Confusion Matrix (Disease)")
    fig.tight_layout()
    plt.savefig(args.out, dpi=150)
    print(f"Saved {args.out}")


if __name__ == "__main__":
    main()
