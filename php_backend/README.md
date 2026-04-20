# Dental App – PHP + MySQL API (XAMPP)

RESTful JSON API with OOP structure: `config/`, `api/`, `models/`, `utils/`.

---

## Folder structure

```
php_backend/
├── bootstrap.php          # Autoloader (no Composer)
├── schema.sql             # MySQL tables
├── README.md
├── postman_collection.json
├── config/
│   └── database.php       # PDO connection
├── models/
│   ├── User.php
│   └── Report.php
├── utils/
│   ├── Response.php       # JSON + CORS
│   └── Validator.php
├── api/
│   ├── register.php
│   ├── login.php
│   ├── create_report.php
│   ├── get_reports.php
│   └── delete_report.php
└── uploads/               # Saved scan images (writable by Apache)
```

---

## 1. Start XAMPP

1. Open **XAMPP Control Panel**.
2. Start **Apache**.
3. Start **MySQL**.

---

## 2. Import database (phpMyAdmin)

1. Browser: `http://localhost/phpmyadmin`
2. Click **Import**.
3. Choose `schema.sql` from this folder.
4. Click **Go**.

Alternatively: **New** → database name `dental_app` → **Import** → `schema.sql`.

---

## 3. Place project under `htdocs`

Copy the whole `php_backend` folder so URLs match your setup.

**Example paths:**

| Copy to | API base URL |
|--------|----------------|
| `C:\xampp\htdocs\dentist\php_backend\` | `http://localhost/dentist/php_backend/api/` |

If you put only `php_backend` in `htdocs`:

| Copy to | API base URL |
|--------|----------------|
| `C:\xampp\htdocs\php_backend\` | `http://localhost/php_backend/api/` |

Update `postman_collection.json` variable `baseUrl` to match.

---

## 4. MySQL credentials

Edit `config/database.php` if needed:

- **User:** `root` (XAMPP default)
- **Password:** empty `''` (change if you set a MySQL password)
- **Database:** `dental_app`

---

## 5. Uploads folder

Apache must be able to write to `uploads/`.

On Windows, if uploads fail, right‑click `uploads` → **Properties** → ensure the user running Apache can modify the folder.

---

## 6. Test with Postman

Import **`postman_collection.json`** (Postman → **Import**).

Set collection variable **`baseUrl`** to your real API folder, e.g.:

`http://localhost/dentist/php_backend/api`

### Register

- **POST** `{{baseUrl}}/register.php`
- **Body** → **raw** → **JSON**:

```json
{
  "name": "Ali Ahmed",
  "phone": "07901234567",
  "email": "ali@example.com",
  "password": "secret12"
}
```

**Expected:**

```json
{
  "status": "success",
  "message": "User registered"
}
```

### Login

- **POST** `{{baseUrl}}/login.php`
- **Body** → **raw** → **JSON**:

```json
{
  "phone": "07901234567",
  "password": "secret12"
}
```

**Expected:**

```json
{
  "status": "success",
  "user": {
    "id": 1,
    "name": "Ali Ahmed",
    "phone": "07901234567"
  }
}
```

Wrong password → `401` with `"Invalid credentials"`.

### Create report

- **POST** `{{baseUrl}}/create_report.php`
- **Body** → **form-data** (not raw JSON):

| Key | Type | Value |
|-----|------|--------|
| `user_id` | Text | `1` (use id from login) |
| `result` | Text | `caries` or `tartar` / free text |
| `confidence` | Text | `0.92` |
| `image` | **File** | Pick a `.jpg` / `.png` / `.webp` |

**Expected:**

```json
{
  "status": "success",
  "message": "Report created",
  "report_id": 1,
  "image_path": "uploads/report_1_....jpg"
}
```

Image URL in browser (example):

`http://localhost/dentist/php_backend/uploads/report_1_xxxxx.jpg`

### Get reports

- **GET** `{{baseUrl}}/get_reports.php?user_id=1`

**Expected:**

```json
{
  "status": "success",
  "reports": [
    {
      "id": 1,
      "user_id": 1,
      "image_path": "uploads/...",
      "result": "caries",
      "confidence": 0.92,
      "created_at": "2025-01-01 12:00:00"
    }
  ]
}
```

### Delete report

- **POST** `{{baseUrl}}/delete_report.php`
- **Body** → **raw** → **JSON**:

```json
{
  "report_id": 1
}
```

---

## Security notes (production)

- **Auth:** This API uses `user_id` in body/query for reports. For production, add **JWT** or **session tokens** and never trust client-supplied `user_id` without verification.
- **HTTPS** in production.
- **CORS:** Currently `*`; restrict to your app origin when deployed.
- Passwords: `password_hash()` / `password_verify()` (already used).
- SQL: **PDO prepared statements** everywhere.

---

## API summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register.php` | Register (name, phone, email, password) |
| POST | `/api/login.php` | Login (phone, password) |
| POST | `/api/create_report.php` | Multipart: user_id, image, result, confidence |
| GET | `/api/get_reports.php?user_id=1` | List reports (newest first) |
| POST | `/api/delete_report.php` | JSON/form: report_id |
| GET | `/api/get_user.php?user_id=1` | Profile for Flutter app after login |
| POST | `/api/update_user.php` | JSON: `user_id`, `first_name`, `last_name`, `phone`, `email` |
| POST | `/api/change_password.php` | JSON: `user_id`, `current_password`, `new_password` |
| POST | `/api/delete_user.php` | JSON: `user_id`, `password` (confirm) — deletes user + reports (CASCADE) |

All responses are **JSON**. **OPTIONS** requests return CORS headers for mobile/web clients.
