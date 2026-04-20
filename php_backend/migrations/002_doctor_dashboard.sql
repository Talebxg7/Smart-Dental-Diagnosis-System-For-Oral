-- Run once in phpMyAdmin on database `dentist` (or your DB name).
-- Adds user roles and report_messages for doctor–patient chat.

ALTER TABLE users
  ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'patient'
  COMMENT 'patient or doctor' AFTER email;

CREATE TABLE IF NOT EXISTS report_messages (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  report_id INT UNSIGNED NOT NULL,
  doctor_id INT UNSIGNED NULL,
  patient_id INT UNSIGNED NOT NULL,
  sender_role ENUM('doctor', 'patient') NOT NULL,
  message TEXT NOT NULL,
  appointment_date DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rm_report FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
  CONSTRAINT fk_rm_doctor FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_rm_patient FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
  KEY idx_rm_report_created (report_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
