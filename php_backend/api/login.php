<?php
/**
 * POST /api/login.php
 * Body: phone, password
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

$err = Validator::required($data, ['phone', 'password']);
if ($err !== null) {
    Response::json(['status' => 'error', 'message' => $err], 400);
    exit;
}

$phone = trim((string) $data['phone']);
$password = (string) $data['password'];

$user = User::findByPhone($phone);
if ($user === null || !password_verify($password, $user['password'])) {
    Response::json([
        'status' => 'error',
        'message' => 'Invalid credentials',
    ], 401);
    exit;
}

if (($user['role'] ?? '') === 'doctor' && (int) ($user['is_approved'] ?? 1) === 0) {
    Response::json([
        'status' => 'error',
        'message' => 'Pending admin approval',
    ], 403);
    exit;
}

Response::json([
    'status' => 'success',
    'user' => [
        'id' => (int) $user['id'],
        'name' => $user['name'],
        'phone' => $user['phone'],
        'email' => $user['email'] ?? '',
        'role' => $user['role'] ?? 'patient',
        'is_approved' => (int) ($user['is_approved'] ?? 1),
    ],
]);
