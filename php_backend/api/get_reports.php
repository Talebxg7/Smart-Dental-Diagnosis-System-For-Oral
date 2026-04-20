<?php
/**
 * GET /api/get_reports.php?user_id=1
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\Report;
use Utils\Response;
use Utils\Validator;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

$userId = $_GET['user_id'] ?? null;
if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid or missing user_id'], 400);
    exit;
}

$rows = Report::findByUserId((int) $userId);

// Sanitize text fields for JSON output
$reports = [];
foreach ($rows as $r) {
    $reports[] = [
        'id' => (int) $r['id'],
        'user_id' => (int) $r['user_id'],
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
