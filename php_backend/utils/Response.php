<?php
/**
 * JSON API responses + CORS for mobile / Postman.
 */
declare(strict_types=1);

namespace Utils;

final class Response
{
    public static function cors(): void
    {
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        header('Content-Type: application/json; charset=utf-8');
    }

    public static function handleOptions(): void
    {
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            self::cors();
            http_response_code(204);
            exit;
        }
    }

    public static function json(array $data, int $code = 200): void
    {
        self::cors();
        http_response_code($code);
        $json = json_encode($data, JSON_UNESCAPED_UNICODE);
        if ($json === false) {
            $json = '{"status":"error","message":"JSON encode failed"}';
        }
        echo $json;
    }

    /** Escape string for safe JSON output (defence in depth). */
    public static function sanitizeString(?string $s): string
    {
        if ($s === null) {
            return '';
        }
        return htmlspecialchars($s, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }
}
