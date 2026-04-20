<?php
declare(strict_types=1);

namespace Models;

use Config\Database;
use PDO;

final class ReportMessage
{
    public static function create(
        int $reportId,
        ?int $doctorId,
        int $patientId,
        string $senderRole,
        string $message,
        ?string $appointmentDateIso
    ): int {
        $pdo = Database::getConnection();
        $appt = null;
        if ($appointmentDateIso !== null && $appointmentDateIso !== '') {
            $ts = strtotime($appointmentDateIso);
            if ($ts !== false) {
                $appt = date('Y-m-d H:i:s', $ts);
            }
        }
        $stmt = $pdo->prepare(
            'INSERT INTO report_messages (report_id, doctor_id, patient_id, sender_role, message, appointment_date)
             VALUES (?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([$reportId, $doctorId, $patientId, $senderRole, $message, $appt]);
        return (int) $pdo->lastInsertId();
    }

    public static function findByReportId(int $reportId): array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'SELECT id, report_id, doctor_id, patient_id, sender_role, message, appointment_date, created_at
             FROM report_messages WHERE report_id = ? ORDER BY created_at ASC'
        );
        $stmt->execute([$reportId]);
        return $stmt->fetchAll();
    }

    public static function findAllForAdmin(): array
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query(
            'SELECT m.id, m.report_id, m.message, m.appointment_date, m.created_at,
                    COALESCE(du.name, \'—\') AS doctor_name,
                    pu.name AS patient_name
             FROM report_messages m
             INNER JOIN users pu ON pu.id = m.patient_id
             LEFT JOIN users du ON du.id = m.doctor_id
             ORDER BY m.created_at DESC'
        );
        return $stmt->fetchAll();
    }

    public static function deleteById(int $id): bool
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('DELETE FROM report_messages WHERE id = ?');
        $stmt->execute([$id]);
        return $stmt->rowCount() > 0;
    }
}
