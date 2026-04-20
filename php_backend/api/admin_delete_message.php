<?php
/**
 * POST /api/admin_delete_message.php JSON: admin_id, message_id
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\ReportMessage;
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

$messageId = $data['message_id'] ?? null;
if (!Validator::intPositive($messageId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid message_id'], 400);
    exit;
}

$ok = ReportMessage::deleteById((int) $messageId);
if (!$ok) {
    Response::json(['status' => 'error', 'message' => 'Message not found'], 404);
    exit;
}

Response::json(['status' => 'success', 'message' => 'Message deleted']);
