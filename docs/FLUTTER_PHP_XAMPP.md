# Flutter app + PHP (XAMPP) backend

The app is configured to use your **`php_backend`** on XAMPP instead of FastAPI.

## URL (`lib/core/constants/api_constants.dart`)

- **Android emulator:** `http://10.0.2.2` + `/dentist/php_backend/`
- **iOS simulator:** `http://127.0.0.1` + same path
- **Physical phone:** set `phpHostOverride` to your PC’s LAN IP, e.g.  
  `static const String? phpHostOverride = 'http://192.168.1.10';`

The folder **`/dentist/php_backend`** must match Apache (`htdocs/dentist/php_backend/`).

## Sign in

Use **phone** + **password** (same as on `register.php`), not email.

## Copy new PHP file

After pulling changes, copy **`api/get_user.php`** to your XAMPP `htdocs` copy if needed.

## Profile & password (PHP)

- **Edit profile** → `update_user.php` (updates MySQL `users` name, phone, email).
- **Change password** → `change_password.php`.
- **Delete account** → `delete_user.php` (requires password); **Delete account** in the app asks for your password after the confirmation dialog.

## Limits (PHP only)

- No JWT; app stores **`php_user_id`** after login.
- Scan upload saves an image + placeholder result (`review_required`); no AI until you connect a model.

## Apache must be running

Start **Apache** + **MySQL** in XAMPP before opening the app.
