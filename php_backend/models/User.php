<?php
/**
 * User model – register, login, lookups.
 */
declare(strict_types=1);

namespace Models;

use Config\Database;
use PDO;

final class User
{
    public static function findById(int $id): ?array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'SELECT id, name, phone, email, password, COALESCE(role, \'patient\') AS role,
                    COALESCE(is_approved, 1) AS is_approved, created_at
             FROM users WHERE id = ? LIMIT 1'
        );
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public static function findByPhone(string $phone): ?array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'SELECT id, name, phone, email, password, COALESCE(role, \'patient\') AS role,
                    COALESCE(is_approved, 1) AS is_approved, created_at
             FROM users WHERE phone = ? LIMIT 1'
        );
        $stmt->execute([$phone]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public static function findByEmail(string $email): ?array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public static function phoneExists(string $phone): bool
    {
        return self::findByPhone($phone) !== null;
    }

    public static function emailExists(string $email): bool
    {
        return self::findByEmail($email) !== null;
    }

    public static function create(
        string $name,
        string $phone,
        string $email,
        string $passwordHash,
        string $role = 'patient',
        int $isApproved = 1
    ): int {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'INSERT INTO users (name, phone, email, password, role, is_approved) VALUES (?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([$name, $phone, $email, $passwordHash, $role, $isApproved]);
        return (int) $pdo->lastInsertId();
    }

    /** All users for admin list (newest first). */
    public static function findAllForAdmin(): array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query(
            'SELECT id, name, phone, email, role, is_approved, created_at FROM users ORDER BY created_at DESC'
        );
        return $stmt->fetchAll();
    }

    public static function updateRole(int $id, string $role): void
    {
        if (!in_array($role, ['patient', 'doctor', 'admin'], true)) {
            throw new \InvalidArgumentException('Invalid role');
        }
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('UPDATE users SET role = ? WHERE id = ?');
        $stmt->execute([$role, $id]);
    }

    public static function updateIsApproved(int $id, int $isApproved): void
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('UPDATE users SET is_approved = ? WHERE id = ?');
        $stmt->execute([$isApproved ? 1 : 0, $id]);
    }

    public static function isAdmin(int $id): bool
    {
        $row = self::findById($id);
        return $row !== null && ($row['role'] ?? '') === 'admin';
    }

    /** Doctor with approved flag (for dashboard / messaging APIs). */
    public static function isApprovedDoctor(int $id): bool
    {
        $row = self::findById($id);
        if ($row === null || ($row['role'] ?? '') !== 'doctor') {
            return false;
        }
        return (int) ($row['is_approved'] ?? 1) === 1;
    }

    /** True if another user (not $excludeId) already has this phone. */
    public static function phoneTakenByOther(int $excludeId, string $phone): bool
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id FROM users WHERE phone = ? AND id != ? LIMIT 1');
        $stmt->execute([$phone, $excludeId]);
        return $stmt->fetch() !== false;
    }

    public static function emailTakenByOther(int $excludeId, string $email): bool
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT id FROM users WHERE email = ? AND id != ? LIMIT 1');
        $stmt->execute([$email, $excludeId]);
        return $stmt->fetch() !== false;
    }

    public static function updateProfile(int $id, string $name, string $phone, string $email): void
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('UPDATE users SET name = ?, phone = ?, email = ? WHERE id = ?');
        $stmt->execute([$name, $phone, $email, $id]);
    }

    public static function updatePasswordHash(int $id, string $passwordHash): void
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('UPDATE users SET password = ? WHERE id = ?');
        $stmt->execute([$passwordHash, $id]);
    }

    public static function deleteById(int $id): void
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('DELETE FROM users WHERE id = ?');
        $stmt->execute([$id]);
    }

    /** Returns safe user array for JSON (no password). */
    public static function publicUser(array $row): array
    {
        return [
            'id' => (int) $row['id'],
            'name' => (string) $row['name'],
            'phone' => (string) $row['phone'],
            'email' => (string) ($row['email'] ?? ''),
            'role' => (string) ($row['role'] ?? 'patient'),
            'is_approved' => (int) ($row['is_approved'] ?? 1),
        ];
    }

    public static function isDoctor(int $id): bool
    {
        $row = self::findById($id);
        return $row !== null && ($row['role'] ?? 'patient') === 'doctor';
    }
}

