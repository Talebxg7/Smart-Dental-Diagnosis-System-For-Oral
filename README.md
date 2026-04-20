# Smart Dental Diagnosis System

AI-powered mobile system for oral disease detection from intraoral images.

## Structure

- **mobile/** – Flutter app (Android + iOS). Open in Android Studio or run from here.
- **backend/** – FastAPI REST API, JWT auth, PostgreSQL, PDF reports.
- **ai_service/** – PyTorch EfficientNet-B0 inference and training scripts.

## Quick start

### 1. Database

```bash
# With Docker
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=dentist -p 5432:5432 postgres:16-alpine

# Run migrations
cd backend && pip install -r requirements.txt && alembic upgrade head
```

### 2. Backend

```bash
cd backend
pip install -r requirements.txt
# Set DATABASE_URL if not default: postgresql+asyncpg://postgres:postgres@localhost:5432/dentist
uvicorn app.main:app --reload --port 8000
```

### 3. AI service

```bash
cd ai_service
pip install -r requirements.txt
# Optional: place trained model.pt in this folder
uvicorn app.main:app --host 0.0.0.0 --port 8001
```

### 4. Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Use Android emulator; set `ApiConstants.baseUrl` to `http://10.0.2.2:8000` (already set for emulator).

### 5. Full stack with Docker

```bash
docker compose up --build
# Backend: http://localhost:8000, AI: http://localhost:8001
# Run migrations once: docker compose exec backend alembic upgrade head
```

## AI training

Place images in `ai_service/data/` with subdirs: `Caries`, `Plaque`, `Tartar`, `Gingivitis`, `Healthy`. Then:

```bash
cd ai_service
python training/train.py --data data --epochs 10 --out model.pt
python training/evaluate.py --data data --model model.pt
python training/confusion_matrix.py --data data --model model.pt --out confusion_matrix.png
```

Copy `model.pt` into the AI service root (or set `MODEL_PATH`) for inference.

## API

- `POST /api/v1/auth/register` – register
- `POST /api/v1/auth/login` – login (returns JWT)
- `GET /api/v1/users/me` – current user (Bearer)
- `POST /api/v1/scans/upload` – upload image (multipart), returns diagnosis
- `GET /api/v1/scans` – list user's scans
- `GET /api/v1/scans/{id}/report` – PDF report
- `GET /api/v1/admin/users` – list users (admin only)

## Security

- Passwords hashed with bcrypt; JWT for API auth.
- Set `SECRET_KEY` in production; use HTTPS.
- Admin role: set `role = 'admin'` in DB for a user to access `/admin/users`.
