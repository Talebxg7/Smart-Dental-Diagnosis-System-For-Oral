<?php
/**
 * POST /api/register.php
 * Body (JSON or form): name, phone, email, password
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
// Merge POST fields (form-data / x-www-form-urlencoded)
$data = array_merge($data, $_POST);

$err = Validator::required($data, ['name', 'phone', 'email', 'password']);
if ($err !== null) {
    Response::json(['status' => 'error', 'message' => $err], 400);
    exit;
}

$name = trim((string) $data['name']);
$phone = trim((string) $data['phone']);
$email = trim((string) $data['email']);
$password = (string) $data['password'];

if (!Validator::email($email)) {
    Response::json(['status' => 'error', 'message' => 'Invalid email'], 400);
    exit;
}
if (!Validator::phone($phone)) {
    Response::json(['status' => 'error', 'message' => 'Invalid phone number'], 400);
    exit;
}
if (!Validator::passwordMinLength($password)) {
    Response::json(['status' => 'error', 'message' => 'Password must be at least 6 characters'], 400);
    exit;
}

if (User::phoneExists($phone)) {
    Response::json(['status' => 'error', 'message' => 'Phone already registered'], 409);
    exit;
}
if (User::emailExists($email)) {
    Response::json(['status' => 'error', 'message' => 'Email already registered'], 409);
    exit;
}

$role = isset($data['role']) ? trim((string) $data['role']) : 'patient';
if ($role !== 'doctor' && $role !== 'patient') {
    $role = 'patient';
}

$isApproved = ($role === 'doctor') ? 0 : 1;

$hash = password_hash($password, PASSWORD_DEFAULT);
User::create($name, $phone, $email, $hash, $role, $isApproved);

Response::json([
    'status' => 'success',
    'message' => 'User registered',
]);
