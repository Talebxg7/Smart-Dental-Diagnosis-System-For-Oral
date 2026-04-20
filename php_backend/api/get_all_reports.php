<?php
/**
 * GET /api/get_all_reports.php?doctor_id=X
 * Lists every patient report (doctor dashboard). Caller must be a doctor.
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\Report;
use Models\User;
use Utils\Response;
use Utils\Validator;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

$doctorId = $_GET['doctor_id'] ?? null;
if (!Validator::intPositive($doctorId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid or missing doctor_id'], 400);
    exit;
}

if (!User::isApprovedDoctor((int) $doctorId)) {
    Response::json([
        'status' => 'error',
        'message' => 'Forbidden: not an approved doctor account',
    ], 403);
    exit;
}

$rows = Report::findAllWithPatient();
$reports = [];
foreach ($rows as $r) {
    $reports[] = [
        'id' => (int) $r['id'],
        'patient_id' => (int) $r['patient_id'],
        'patient_name' => $r['patient_name'],
        'image_path' => $r['image_path'],
        'result' => $r['result'],
        'confidence' => (float) $r['confidence'],
        'created_at' => $r['created_at'],
    ];
}

Response::json([
    'status' => 'success',
    'reports' => $reports,
]);
