<?php
/**
 * GET /api/admin_get_stats.php?admin_id=X
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Config\Database;
use Models\Report;
use Utils\AdminAuth;
use Utils\Response;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

AdminAuth::assertAdmin($_GET['admin_id'] ?? null);

$pdo = Database::getConnection();

$totalUsers = (int) $pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
$totalPatients = (int) $pdo->query("SELECT COUNT(*) FROM users WHERE role = 'patient'")->fetchColumn();
$totalDoctors = (int) $pdo->query("SELECT COUNT(*) FROM users WHERE role = 'doctor'")->fetchColumn();
$pendingDoctors = (int) $pdo->query(
    "SELECT COUNT(*) FROM users WHERE role = 'doctor' AND is_approved = 0"
)->fetchColumn();

$totalReports = Report::countAll();
$reportsToday = Report::countCreatedToday();
$top = Report::mostCommonDiagnosisRow();
$mostCommon = $top === null
    ? null
    : ['result' => $top['result'], 'count' => $top['count']];

Response::json([
    'status' => 'success',
    'stats' => [
        'total_users' => $totalUsers,
        'total_patients' => $totalPatients,
        'total_doctors' => $totalDoctors,
        'pending_doctors' => $pendingDoctors,
        'total_reports' => $totalReports,
        'reports_today' => $reportsToday,
        'most_common_diagnosis' => $mostCommon,
    ],
]);
