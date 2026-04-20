"""
Training script for Oral Disease model (EfficientNet-B0).
Expects dataset root with subdirs: Caries, Plaque, Tartar, Gingivitis, Healthy.
Each subdir can have severity subdirs or we use a single label per image.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import torch
import torch.nn as nn
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from PIL import Image

from models.oral_model import OralDiseaseModel, DISEASE_CLASSES, SEVERITY_CLASSES

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]
IMAGE_SIZE = 224


class OralDataset(Dataset):
    def __init__(self, root: str, is_train: bool = True):
        self.root = root
        self.is_train = is_train
        self.samples = []
        for i, cls in enumerate(DISEASE_CLASSES):
            d = os.path.join(root, cls)
            if not os.path.isdir(d):
                continue
            for f in os.listdir(d):
                if f.lower().endswith((".jpg", ".jpeg", ".png", ".webp")):
                    self.samples.append((os.path.join(d, f), i, 0))

        if is_train:
            self.transform = transforms.Compose([
                transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
                transforms.RandomHorizontalFlip(),
                transforms.RandomAffine(degrees=10, translate=(0.1, 0.1), scale=(0.9, 1.1)),
                transforms.ToTensor(),
                transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ])
        else:
            self.transform = transforms.Compose([
                transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
                transforms.ToTensor(),
                transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
            ])

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        path, disease_idx, severity_idx = self.samples[idx]
        img = Image.open(path).convert("RGB")
        x = self.transform(img)
        return x, disease_idx, severity_idx


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", default="data", help="Dataset root")
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--batch", type=int, default=16)
    parser.add_argument("--lr", type=float, default=1e-4)
    parser.add_argument("--out", default="model.pt")
    parser.add_argument("--device", default="cuda" if torch.cuda.is_available() else "cpu")
    args = parser.parse_args()

    train_set = OralDataset(args.data, is_train=True)
    if len(train_set) == 0:
        print("No images found. Create dataset with subdirs: Caries, Plaque, Tartar, Gingivitis, Healthy")
        return
    train_loader = DataLoader(train_set, batch_size=args.batch, shuffle=True, num_workers=0)

    model = OralDiseaseModel()
    for p in model.backbone.parameters():
        p.requires_grad = False
    model = model.to(args.device)
    opt = torch.optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=args.lr)
    loss_fn_d = nn.CrossEntropyLoss()
    loss_fn_s = nn.CrossEntropyLoss()

    for epoch in range(args.epochs):
        model.train()
        total_loss = 0.0
        for x, yd, ys in train_loader:
            x, yd, ys = x.to(args.device), yd.to(args.device), ys.to(args.device)
            opt.zero_grad()
            logits_d, logits_s = model(x)
            loss = loss_fn_d(logits_d, yd) + loss_fn_s(logits_s, ys)
            loss.backward()
            opt.step()
            total_loss += loss.item()
        print(f"Epoch {epoch + 1}/{args.epochs} loss={total_loss / len(train_loader):.4f}")

    torch.save(model.state_dict(), args.out)
    print(f"Saved {args.out}")


if __name__ == "__main__":
    main()
