-- Initial Data for eGov Portal MySQL
-- Run this AFTER mysql-schema.sql

SET NAMES utf8mb4;

-- ============================================
-- Insert Default Admin User
-- ============================================
-- Username: admin
-- Password: admin123 (bcrypt encoded)
INSERT INTO `users` (`id`, `username`, `password`, `grade`, `email`, `name`, `email_verified`)
VALUES
  (UUID(), 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lF7C3Ie44PuV/qC62', 1, 'admin@forhim.kr', '관리자', TRUE);

-- ============================================
-- Insert Default Roles
-- ============================================
INSERT INTO `roles` (`id`, `name`) VALUES
  (UUID(), 'ADMIN'),
  (UUID(), 'USER'),
  (UUID(), 'PROJECT_MANAGER');

-- ============================================
-- Insert Default Permissions
-- ============================================
INSERT INTO `permissions` (`id`, `code`) VALUES
  (UUID(), 'PROJECT_CREATE'),
  (UUID(), 'PROJECT_READ'),
  (UUID(), 'PROJECT_UPDATE'),
  (UUID(), 'PROJECT_DELETE'),
  (UUID(), 'USER_MANAGE'),
  (UUID(), 'SYSTEM_ADMIN');

-- ============================================
-- Assign Permissions to ADMIN Role
-- ============================================
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `roles` r
CROSS JOIN `permissions` p
WHERE r.name = 'ADMIN';

-- ============================================
-- Assign ADMIN Role to Admin User
-- ============================================
INSERT INTO `user_role_assignments` (`id`, `user_id`, `role_id`, `tenant_id`, `valid_from`)
SELECT UUID(), u.id, r.id, UUID(), NOW()
FROM `users` u
CROSS JOIN `roles` r
WHERE u.username = 'admin' AND r.name = 'ADMIN';

-- ============================================
-- Insert Sample Tenant (Optional)
-- ============================================
-- This creates a default tenant for testing
-- Tenant ID will be used in projects

COMMIT;
