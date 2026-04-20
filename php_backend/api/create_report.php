<?php
/**
 * POST /api/create_report.php
 * multipart/form-data: user_id, image (file), result, confidence
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\Report;
use PDOException;
use Utils\Response;
use Utils\Validator;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

$userId = $_POST['user_id'] ?? null;
$result = isset($_POST['result']) ? trim((string) $_POST['result']) : '';
$confidence = $_POST['confidence'] ?? null;

if (!Validator::intPositive($userId)) {
    Response::json(['status' => 'error', 'message' => 'Invalid user_id'], 400);
    exit;
}
if ($result === '') {
    Response::json(['status' => 'error', 'message' => 'Missing result'], 400);
    exit;
}
if (!Validator::floatNonNegative($confidence)) {
    Response::json(['status' => 'error', 'message' => 'Invalid confidence'], 400);
    exit;
}

if (!isset($_FILES['image']) || !is_uploaded_file($_FILES['image']['tmp_name'])) {
    Response::json(['status' => 'error', 'message' => 'Image file required'], 400);
    exit;
}

$file = $_FILES['image'];
if ($file['error'] !== UPLOAD_ERR_OK) {
    Response::json(['status' => 'error', 'message' => 'Upload failed'], 400);
    exit;
}

$allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
$finfo = new finfo(FILEINFO_MIME_TYPE);
$mime = $finfo->file($file['tmp_name']);
if (!isset($allowed[$mime])) {
    Response::json(['status' => 'error', 'message' => 'Only JPEG, PNG, WebP allowed'], 400);
    exit;
}

$uploadDir = dirname(__DIR__) . '/uploads';
if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
    Response::json(['status' => 'error', 'message' => 'Cannot create uploads folder'], 500);
    exit;
}

$ext = $allowed[$mime];
$newName = sprintf('report_%d_%s.%s', (int) $userId, bin2hex(random_bytes(8)), $ext);
$destPath = $uploadDir . '/' . $newName;

if (!move_uploaded_file($file['tmp_name'], $destPath)) {
    Response::json(['status' => 'error', 'message' => 'Could not save file'], 500);
    exit;
}

// Store web-relative path (adjust base URL in client if needed)
$relativePath = 'uploads/' . $newName;

try {
    $reportId = Report::create(
        (int) $userId,
        $relativePath,
        $result,
        (float) $confidence
    );
} catch (PDOException $e) {
    @unlink($destPath);
    // e.g. unknown user_id (foreign key)
    Response::json(['status' => 'error', 'message' => 'Invalid user or database error'], 400);
    exit;
}

Response::json([
    'status' => 'success',
    'message' => 'Report created',
    'report_id' => $reportId,
    'image_path' => $relativePath,
]);
