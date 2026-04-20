<?php
/**
 * POST /api/change_password.php
 * JSON or form: user_id, current_password, new_password
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\User;
use Utils\Response;
use Utils\Validator;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

$raw = file_get_contents('php://input');
$data = [];
if ($raw !== '' && $raw !== false) {
    $decoded = json_decode($raw, true);
    if (is_array($decoded)) {
        $data = $decoded;
    }
}
$data = array_merge($data, $_POST);

$userId = $data['user_id'] ?? null;
$current = (string) ($data['current_password'] ?? '');
$new = (string) ($data['new_password'] ?? '');

if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}
if ($current === '' || $new === '') {
    Response::json(['status' => 'error', 'message' => 'Passwords required'], 400);
    exit;
}
if (!Validator::passwordMinLength($new)) {
    Response::json(['status' => 'error', 'message' => 'New password must be at least 6 characters'], 400);
    exit;
}

$row = User::findById((int) $userId);
if ($row === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}

if (!password_verify($current, $row['password'])) {
    Response::json(['status' => 'error', 'message' => 'Current password is incorrect'], 401);
    exit;
}

User::updatePasswordHash((int) $userId, password_hash($new, PASSWORD_DEFAULT));

Response::json([
    'status' => 'success',
    'message' => 'Password updated',
]);
