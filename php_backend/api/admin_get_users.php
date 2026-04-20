<?php
/**
 * GET /api/admin_get_users.php?admin_id=X
 */
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

use Models\User;
use Utils\AdminAuth;
use Utils\Response;

Response::handleOptions();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::json(['status' => 'error', 'message' => 'Method not allowed'], 405);
    exit;
}

AdminAuth::assertAdmin($_GET['admin_id'] ?? null);

$rows = User::findAllForAdmin();
$users = [];
foreach ($rows as $r) {
    $users[] = [
        'id' => (int) $r['id'],
        'name' => $r['name'],
        'phone' => $r['phone'],
        'email' => $r['email'],
        'role' => $r['role'] ?? 'patient',
        'is_approved' => (int) ($r['is_approved'] ?? 1),
        'created_at' => $r['created_at'],
    ];
}

Response::json(['status' => 'success', 'users' => $users]);
