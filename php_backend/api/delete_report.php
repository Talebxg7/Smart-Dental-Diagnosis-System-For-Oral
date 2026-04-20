<?php
/**
 * POST /api/delete_report.php
 * Body: report_id (JSON, form, or x-www-form-urlencoded)
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\Report;
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
if (!Validator::intPositive($reportId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid or missing report_id'], 400);
    exit;
}

$report = Report::findById((int) $reportId);
if ($report === null) {
    Response::json(['status' => 'error', 'message' => 'Report not found'], 404);
    exit;
}

$imagePath = (string) $report['image_path'];
// Only allow deleting files under /uploads (prevent path traversal)
if (strpos($imagePath, 'uploads/') !== 0 || strpos($imagePath, '..') !== false) {
    Response::json(['status' => 'error', 'message' => 'Invalid stored path'], 500);
    exit;
}
$fullPath = dirname(__DIR__) . '/' . $imagePath;

if (is_file($fullPath)) {
    @unlink($fullPath);
}

$deleted = Report::delete((int) $reportId);
if (!$deleted) {
    Response::json(['status' => 'error', 'message' => 'Could not delete report'], 500);
    exit;
}

Response::json([
    'status' => 'success',
    'message' => 'Report deleted',
]);
