-- =============================================================================
-- phpMyAdmin: paste the ENTIRE block below (must start with ALTER TABLE users).
-- Do NOT run only "ADD COLUMN ..." — that causes error #1064 near "ADD".
-- Run after migration 002 (so column `role` exists). If `is_approved` already
-- exists, skip this file (duplicate column error is OK to ignore).
-- =============================================================================

ALTER TABLE users
  ADD COLUMN is_approved TINYINT(1) NOT NULL DEFAULT 1
  COMMENT '1 = approved (e.g. moderation)'
  AFTER role;
