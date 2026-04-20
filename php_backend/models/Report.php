<?php
/**
 * Report model – CRUD for AI scan reports.
 */
declare(strict_types=1);

namespace Models;

use Config\Database;
use PDO;

final class Report
{
    public static function create(int $userId, string $imagePath, string $result, float $confidence): int
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'INSERT INTO reports (user_id, image_path, result, confidence) VALUES (?, ?, ?, ?)'
        );
        $stmt->execute([$userId, $imagePath, $result, $confidence]);
        return (int) $pdo->lastInsertId();
    }

    public static function findById(int $id): ?array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM reports WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    /** Latest first */
    public static function findByUserId(int $userId): array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'SELECT id, user_id, image_path, result, confidence, created_at FROM reports WHERE user_id = ? ORDER BY created_at DESC'
        );
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }

    public static function delete(int $id): bool
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('DELETE FROM reports WHERE id = ?');
        $stmt->execute([$id]);
        return $stmt->rowCount() > 0;
    }

    /** All reports with patient name (for doctor dashboard). */
    public static function findAllWithPatient(): array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query(
            'SELECT r.id, r.user_id AS patient_id, r.image_path, r.result, r.confidence, r.created_at,
                    u.name AS patient_name
             FROM reports r
             INNER JOIN users u ON u.id = r.user_id
             ORDER BY r.created_at DESC'
        );
        return $stmt->fetchAll();
    }

    public static function countAll(): int
    {
        $pdo = Database::getConnection();
        return (int) $pdo->query('SELECT COUNT(*) FROM reports')->fetchColumn();
    }

    public static function countCreatedToday(): int
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT COUNT(*) FROM reports WHERE DATE(created_at) = CURDATE()');
        return (int) $stmt->fetchColumn();
    }

    /** @return array{result: string, count: int}|null */
    public static function mostCommonDiagnosisRow(): ?array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query(
            'SELECT result, COUNT(*) AS cnt FROM reports GROUP BY result ORDER BY cnt DESC LIMIT 1'
        );
        $row = $stmt->fetch();
        if ($row === false) {
            return null;
        }
        return [
            'result' => (string) $row['result'],
            'count' => (int) $row['cnt'],
        ];
    }
}
