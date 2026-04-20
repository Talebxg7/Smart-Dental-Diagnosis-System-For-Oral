<?php
/**
 * One-time: generate a bcrypt hash for MySQL `users.password`.
 *
 * Usage (from folder php_backend):
 *   php tools/generate_password_hash.php "your_plain_password"
 *
 * XAMPP (Windows), example:
 *   C:\xampp\php\php.exe tools\generate_password_hash.php "admin@dental9"
 *
 * Then in phpMyAdmin run:
 *   UPDATE users SET password = '<paste_hash_here>' WHERE id = 6;
 */
declare(strict_types=1);

$plain = $argv[1] ?? '';
if ($plain === '') {
    fwrite(STDERR, "Usage: php generate_password_hash.php \"YourPassword\"\n");
    exit(1);
}

echo password_hash($plain, PASSWORD_DEFAULT), PHP_EOL;
