<?php
/**
 * GET /api/admin_get_all_messages.php?admin_id=X
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\ReportMessage;
use Utils\AdminAuth;
use Utils\Response;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

AdminAuth::assertAdmin($_GET['admin_id'] ?? null);

$rows = ReportMessage::findAllForAdmin();
$messages = [];
foreach ($rows as $m) {
    $messages[] = [
        'id' => (int) $m['id'],
        'report_id' => (int) $m['report_id'],
        'doctor_name' => $m['doctor_name'],
        'patient_name' => $m['patient_name'],
        'message' => $m['message'],
        'appointment_date' => $m['appointment_date'],
        'created_at' => $m['created_at'],
    ];
}

Response::json(['status' => 'success', 'messages' => $messages]);
