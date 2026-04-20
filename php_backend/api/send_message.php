<?php
/**
 * POST /api/send_message.php
 * JSON: report_id, doctor_id, patient_id, sender_role (doctor|patient), message,
 *       appointment_date (optional ISO 8601)
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\Report;
use Models\ReportMessage;
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

$reportId = $data['report_id'] ?? null;
$doctorId = $data['doctor_id'] ?? null;
$patientId = $data['patient_id'] ?? null;
$senderRole = isset($data['sender_role']) ? trim((string) $data['sender_role']) : '';
$message = isset($data['message']) ? trim((string) $data['message']) : '';
$appt = isset($data['appointment_date']) ? trim((string) $data['appointment_date']) : null;
if ($appt === '') {
    $appt = null;
}

if (!Validator::intPositive($reportId) || !Validator::intPositive($patientId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid report_id or patient_id'], 400);
    exit;
}
if ($message === '') {
    Response::json(['status' => 'error', 'message' => 'Message is required'], 400);
    exit;
}
if ($senderRole !== 'doctor' && $senderRole !== 'patient') {
    Response::json(['status' => 'error', 'message' => 'sender_role must be doctor or patient'], 400);
    exit;
}

$report = Report::findById((int) $reportId);
if ($report === null) {
    Response::json(['status' => 'error', 'message' => 'Report not found'], 404);
    exit;
}
if ((int) $report['user_id'] !== (int) $patientId) {
    Response::json(['status' => 'error', 'message' => 'patient_id does not match report'], 400);
    exit;
}

$doctorIdInt = null;
if ($doctorId !== null && $doctorId !== '' && $doctorId !== 'null') {
    if (!Validator::intPositive($doctorId)) {
        Response::json(['status' => 'error', 'message' => 'Invalid doctor_id'], 400);
        exit;
    }
    $doctorIdInt = (int) $doctorId;
}

if ($senderRole === 'doctor') {
    if ($doctorIdInt === null) {
        Response::json(['status' => 'error', 'message' => 'doctor_id required for doctor messages'], 400);
        exit;
    }
    if (!User::isApprovedDoctor($doctorIdInt)) {
        Response::json(['status' => 'error', 'message' => 'doctor_id is not an approved doctor account'], 403);
        exit;
    }
}

try {
    ReportMessage::create(
        (int) $reportId,
        $doctorIdInt,
        (int) $patientId,
        $senderRole,
        $message,
        $appt
    );
} catch (\Throwable $e) {
    Response::json([
        'status'  => 'error',
        'message' => 'Database error: report_messages table may not exist. Run migration 005_report_messages_safe.sql in phpMyAdmin.',
    ], 500);
    exit;
}

Response::json([
    'status'  => 'success',
    'message' => 'Message sent',
]);

