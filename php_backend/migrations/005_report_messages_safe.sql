-- =============================================================================
-- Migration 005: Safe creation of report_messages table + user columns.
-- Run this in phpMyAdmin if the "View & Respond" page crashes.
-- This is SAFE to run even if migration 002/003/004 were already applied
-- (uses IF NOT EXISTS / IF NOT EXISTS column checks via ALTER IGNORE).
-- =============================================================================

USE dental_app;

-- 1) Add `role` column to users if it doesn't exist yet.
--    If it already exists, MySQL will raise a duplicate-column error; just ignore it.
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'patient'
  COMMENT 'patient, doctor, or admin' AFTER email;

-- 2) Add `is_approved` column to users if it doesn't exist yet.
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_approved TINYINT(1) NOT NULL DEFAULT 1
  COMMENT '1=approved; new doctors start as 0 until admin approves' AFTER role;

-- 3) Create the report_messages table (safe — does nothing if already exists).
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
