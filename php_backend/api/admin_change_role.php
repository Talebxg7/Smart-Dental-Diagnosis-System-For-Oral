<?php
/**
 * POST /api/admin_change_role.php JSON: admin_id, user_id, new_role
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\User;
use Utils\AdminAuth;
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

AdminAuth::assertAdmin($data['admin_id'] ?? null);

$userId = $data['user_id'] ?? null;
$newRole = isset($data['new_role']) ? trim((string) $data['new_role']) : '';

if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}
if (!in_array($newRole, ['patient', 'doctor', 'admin'], true)) {
    Response::json(['status' => 'error', 'message' => 'new_role must be patient, doctor, or admin'], 400);
    exit;
}

$target = User::findById((int) $userId);
if ($target === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}

$oldRole = $target['role'] ?? 'patient';

try {
    User::updateRole((int) $userId, $newRole);
} catch (\InvalidArgumentException $e) {
    Response::json(['status' => 'error', 'message' => $e->getMessage()], 400);
    exit;
}

if ($newRole === 'doctor' && $oldRole !== 'doctor') {
    User::updateIsApproved((int) $userId, 0);
}
if ($newRole === 'admin' || $newRole === 'patient') {
    User::updateIsApproved((int) $userId, 1);
}

Response::json(['status' => 'success', 'message' => 'Role updated']);
