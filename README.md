🦷 Smart Dental Diagnosis System
📌 Overview

The Smart Dental Diagnosis System is a software application designed to assist in the early detection and analysis of oral health conditions using intelligent diagnostic support tools. The system helps streamline dental evaluations by providing structured data handling, automated processing, and user-friendly interaction for dental professionals and researchers.

This project aims to demonstrate how technology can improve decision-making efficiency in dental diagnostics through organized patient data management and smart analysis workflows.

🎯 Project Objectives
Support early detection of oral health conditions
Improve diagnostic workflow efficiency
Provide structured patient data management
Demonstrate integration of intelligent diagnostic logic
Offer a scalable foundation for future AI-assisted extensions


🧠 Key Features
Patient data entry and management
Dental condition tracking interface
Structured diagnostic workflow
Smart analysis support logic
Organized modular project architecture
Expandable system design for future enhancements
🛠️ Technologies Used

Example

Java / Kotlin
Android Studio
XML (UI Design)
SQLite / Local Database
Machine Learning integration (optional/future-ready)
Git version control


🏗️ System Architecture
The application follows a modular structure:

Smart Dental Diagnosis System
│
├── UI Layer
├── Data Processing Layer
├── Diagnostic Logic Layer
└── Storage Layer

This structure improves scalability, readability, and maintainability.

🚀 How to Run the Project
Requirements

Install:

Android Studio
Java SDK
Android Emulator or Physical Device
Steps
Clone the repository
git clone https://github.com/Talebxg7/Smart-Dental-Diagnosis-System-For-Oral.git
Open the project in Android Studio
Build the project
Run the application on emulator or device
📊 Future Improvements

Planned upgrades may include:

AI-based image analysis for dental conditions
Cloud database integration
Patient report generation (PDF export)
Multi-user authentication system
Real-time diagnosis assistance
Dashboard analytics for dentists
👨‍⚕️ Target Users
Dental students
Dental professionals
Medical researchers
Academic supervisors
Healthcare software developers
📚 Academic Value

This project demonstrates:

Software engineering practices
Healthcare application development
Diagnostic workflow modeling
Structured system architecture design
Version control using Git
🤝 Contribution

Contributions are welcome.

To contribute:

fork → clone → edit → commit → pull request
📄 License

This project is intended for educational and research purposes.


<<<<<<< HEAD
=======
>>>>>>> origin/main
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
=======
# Smart-Dental-Diagnosis-System-For-Oral
Smart Dental Diagnosis System is an AI-powered mobile app that analyzes dental images to detect oral diseases such as caries, tartar, and gingivitis. It provides instant results with confidence scores, scan history, and educational insights for better oral health awareness.
>>>>>>> 6766a0d263d94a7f5b61834e4509f408bc8b234d
