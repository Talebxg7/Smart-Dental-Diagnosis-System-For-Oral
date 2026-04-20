<?php
/**
 * Verifies admin_id refers to a user with role admin.
 */
declare(strict_types=1);

namespace Utils;

use Models\User;

final class AdminAuth
{
    /**
     * Accepts admin_id from GET/POST/JSON (string or int).
     * Must not throw (always returns JSON on failure).
     * @param mixed $rawAdminId
     */
    public static function assertAdmin($rawAdminId): int
    {
        $s = is_string($rawAdminId) ? $rawAdminId : (is_int($rawAdminId) ? (string) $rawAdminId : null);
        if (!Validator::intPositive($s)) {
            Response::json(['status' => 'error', 'message' => 'Invalid or missing admin_id'], 401);
            exit;
        }
        $id = (int) $s;
        $row = User::findById($id);
        if ($row === null || ($row['role'] ?? '') !== 'admin') {
            Response::json(['status' => 'error', 'message' => 'Forbidden: admin only'], 403);
            exit;
        }
        return $id;
    }
}
