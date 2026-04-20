<?php
/**
 * POST /api/update_user.php
 * JSON or form: user_id, first_name, last_name, phone, email
 * Updates name (combined), phone, and email in MySQL.
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
$first = isset($data['first_name']) ? trim((string) $data['first_name']) : '';
$last = isset($data['last_name']) ? trim((string) $data['last_name']) : '';
$phone = isset($data['phone']) ? trim((string) $data['phone']) : '';
$email = isset($data['email']) ? trim((string) $data['email']) : '';

if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}
if ($phone === '') {
    Response::json(['status' => 'error', 'message' => 'Phone is required'], 400);
    exit;
}
if (!Validator::phone($phone)) {
    Response::json(['status' => 'error', 'message' => 'Invalid phone number'], 400);
    exit;
}
if ($email === '' || !Validator::email($email)) {
    Response::json(['status' => 'error', 'message' => 'Valid email is required'], 400);
    exit;
}

$name = trim($first . ' ' . $last);
if ($name === '') {
    $name = 'User';
}

$row = User::findById((int) $userId);
if ($row === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}

if (User::phoneTakenByOther((int) $userId, $phone)) {
    Response::json(['status' => 'error', 'message' => 'Phone already used by another account'], 409);
    exit;
}

if (User::emailTakenByOther((int) $userId, $email)) {
    Response::json(['status' => 'error', 'message' => 'Email already used by another account'], 409);
    exit;
}

User::updateProfile((int) $userId, $name, $phone, $email);

Response::json([
    'status' => 'success',
    'message' => 'Profile updated',
]);
