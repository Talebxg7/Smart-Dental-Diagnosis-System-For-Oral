<?php
/**
 * GET /api/get_user.php?user_id=1
 * Returns user profile (no password) for mobile app after PHP login.
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\User;
use Utils\Response;
use Utils\Validator;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

$userId = $_GET['user_id'] ?? null;
if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid or missing user_id'], 400);
    exit;
}

$row = User::findById((int) $userId);
if ($row === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}

$name = (string) $row['name'];
$parts = preg_split('/\s+/', trim($name), 2);
$first = $parts[0] ?? '';
$last = $parts[1] ?? '';

Response::json([
    'status' => 'success',
    'user' => [
        'id' => (int) $row['id'],
        'name' => $name,
        'first_name' => $first,
        'last_name' => $last,
        'phone' => $row['phone'],
        'email' => $row['email'],
        'role' => $row['role'] ?? 'patient',
        'is_approved' => (int) ($row['is_approved'] ?? 1),
    ],
]);
