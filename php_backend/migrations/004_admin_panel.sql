-- Admin panel: doctor approval + admin role support.
-- 1) If `is_approved` already exists, skip the ADD COLUMN line (duplicate column error).
-- 2) Ensure `role` column allows value `admin` (VARCHAR is fine; if ENUM, add `admin` to the ENUM).
-- 3) Promote your first admin manually, e.g.:
--    UPDATE users SET role = 'admin', is_approved = 1 WHERE id = 1;

ALTER TABLE users
  ADD COLUMN is_approved TINYINT(1) NOT NULL DEFAULT 1
  COMMENT '1=approved; new doctors register as 0 until approved'
  AFTER role;

-- Optional: mark existing doctors as already approved
-- UPDATE users SET is_approved = 1 WHERE role = 'doctor';
