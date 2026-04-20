<?php
/**
 * PDO database connection (singleton-style).
 * Adjust credentials for your XAMPP MySQL setup.
 */
declare(strict_types=1);

namespace Config;

use PDO;
use PDOException;

final class Database
{
    private static ?PDO $instance = null;

    private const HOST = '127.0.0.1';
    /** Must match the database name in phpMyAdmin where `users` and `reports` exist (e.g. dentist or dental_app). */
    private const DB_NAME = 'dentist';
    private const USER = 'root';
    private const PASS = ''; // XAMPP default: empty password
    private const CHARSET = 'utf8mb4';

    public static function getConnection(): PDO
    {
        if (self::$instance === null) {
            $dsn = sprintf(
                'mysql:host=%s;dbname=%s;charset=%s',
                self::HOST,
                self::DB_NAME,
                self::CHARSET
            );
            try {
                self::$instance = new PDO($dsn, self::USER, self::PASS, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]);
            } catch (PDOException $e) {
                http_response_code(500);
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Database connection failed',
                ]);
                exit;
            }
        }
        return self::$instance;
    }
}
