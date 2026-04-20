<?php
/**
 * POST /api/admin_delete_user.php JSON: admin_id, user_id
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
if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}

$target = User::findById((int) $userId);
if ($target === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}
if (($target['role'] ?? '') === 'admin') {
    Response::json(['status' => 'error', 'message' => 'Cannot delete admin accounts'], 403);
    exit;
}

User::deleteById((int) $userId);

Response::json(['status' => 'success', 'message' => 'User deleted']);
