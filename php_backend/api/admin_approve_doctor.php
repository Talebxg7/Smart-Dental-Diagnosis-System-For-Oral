<?php
/**
 * POST /api/admin_approve_doctor.php JSON: admin_id, user_id, is_approved (1|0)
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
$ap = $data['is_approved'] ?? null;

if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}
if ($ap !== 0 && $ap !== '0' && $ap !== 1 && $ap !== '1') {
    Response::json(['status' => 'error', 'message' => 'is_approved must be 0 or 1'], 400);
    exit;
}

$target = User::findById((int) $userId);
if ($target === null) {
    Response::json(['status' => 'error', 'message' => 'User not found'], 404);
    exit;
}
if (($target['role'] ?? '') !== 'doctor') {
    Response::json(['status' => 'error', 'message' => 'User is not a doctor'], 400);
    exit;
}

$flag = ((int) $ap) === 1 ? 1 : 0;
User::updateIsApproved((int) $userId, $flag);

Response::json(['status' => 'success', 'message' => $flag === 1 ? 'Doctor approved' : 'Doctor rejected']);
