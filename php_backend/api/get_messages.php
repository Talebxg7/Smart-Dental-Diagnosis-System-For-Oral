<?php
/**
 * GET /api/get_messages.php?report_id=X&doctor_id=Y (optional, for future auth)
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\Report;
use Models\ReportMessage;
use Utils\Response;
use Utils\Validator;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

$reportId = $_GET['report_id'] ?? null;
if (!Validator::intPositive($reportId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid or missing report_id'], 400);
    exit;
}

if (Report::findById((int) $reportId) === null) {
    Response::json(['status' => 'error', 'message' => 'Report not found'], 404);
    exit;
}

try {
    $rows = ReportMessage::findByReportId((int) $reportId);
} catch (\Throwable $e) {
    Response::json([
        'status'  => 'error',
        'message' => 'Database error: report_messages table may not exist. Run migration 005_report_messages_safe.sql in phpMyAdmin.',
    ], 500);
    exit;
}

// Pre-fetch doctor names to avoid N+1 queries
$doctorNames = [];
try {
    $pdo  = \Config\Database::getConnection();
    $stmt = $pdo->query("SELECT id, name FROM users WHERE role = 'doctor'");
    foreach ($stmt->fetchAll() as $u) {
        $doctorNames[(int)$u['id']] = $u['name'];
    }
} catch (\Throwable $e) {
    // Non-fatal: fall back to null / "Doctor" label in the app
}

$messages = [];
foreach ($rows as $m) {
    $doctorId   = $m['doctor_id'] !== null ? (int) $m['doctor_id'] : null;
    $doctorName = ($doctorId !== null && isset($doctorNames[$doctorId]))
        ? $doctorNames[$doctorId]
        : null;

    $messages[] = [
        'id'               => (int) $m['id'],
        'report_id'        => (int) $m['report_id'],
        'doctor_id'        => $doctorId,
        'doctor_name'      => $doctorName,
        'patient_id'       => (int) $m['patient_id'],
        'sender_role'      => $m['sender_role'],
        'message'          => $m['message'],
        'appointment_date' => $m['appointment_date'],
        'created_at'       => $m['created_at'],
    ];
}

Response::json([
    'status'   => 'success',
    'messages' => $messages,
]);
