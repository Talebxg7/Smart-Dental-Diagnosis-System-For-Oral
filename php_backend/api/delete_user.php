<?php
/**
 * POST /api/delete_user.php
 * JSON or form: user_id, password (must match current password)
 * Deletes user; reports CASCADE in DB.
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
$password = (string) ($data['password'] ?? '');

if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}
if ($password === '') {
    Response::json(['status' => 'error', 'message' => 'Password required to delete account'], 400);
    exit;
}

$row = User::findById((int) $userId);
if ($row === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}

if (!password_verify($password, $row['password'])) {
    Response::json(['status' => 'error', 'message' => 'Incorrect password'], 401);
    exit;
}

User::deleteById((int) $userId);

Response::json([
    'status' => 'success',
    'message' => 'Account deleted',
]);
