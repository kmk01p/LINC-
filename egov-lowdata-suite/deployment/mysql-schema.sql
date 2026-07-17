-- MySQL Schema for eGov Portal
-- MySQL 8.0+ compatible

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables
DROP TABLE IF EXISTS `v_submissions_masked`;
DROP TABLE IF EXISTS `user_role_assignments`;
DROP TABLE IF EXISTS `sync_cursor`;
DROP TABLE IF EXISTS `submissions_raw`;
DROP TABLE IF EXISTS `role_permissions`;
DROP TABLE IF EXISTS `quality_flags`;
DROP TABLE IF EXISTS `project_integrations`;
DROP TABLE IF EXISTS `project_forms`;
DROP TABLE IF EXISTS `policies`;
DROP TABLE IF EXISTS `forms`;
DROP TABLE IF EXISTS `projects`;
DROP TABLE IF EXISTS `projects_biz`;
DROP TABLE IF EXISTS `app_user_role_assignments`;
DROP TABLE IF EXISTS `app_role_permissions`;
DROP TABLE IF EXISTS `app_roles`;
DROP TABLE IF EXISTS `app_permissions`;
DROP TABLE IF EXISTS `app_users`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `permissions`;
DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `form_templates`;

-- Quartz tables
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
DROP TABLE IF EXISTS `qrtz_triggers`;
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
DROP TABLE IF EXISTS `qrtz_locks`;
DROP TABLE IF EXISTS `qrtz_job_details`;

-- ============================================
-- Core Tables
-- ============================================

CREATE TABLE `users` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(100) NOT NULL,
  `grade` INT NOT NULL,
  `email` VARCHAR(255) DEFAULT NULL,
  `name` VARCHAR(100) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `email_verified` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `roles` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `name` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `permissions` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `code` VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `role_permissions` (
  `role_id` CHAR(36) NOT NULL,
  `permission_id` CHAR(36) NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `user_role_assignments` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `user_id` CHAR(36) NOT NULL,
  `role_id` CHAR(36) NOT NULL,
  `tenant_id` CHAR(36) NOT NULL,
  `project_id` CHAR(36) DEFAULT NULL,
  `valid_from` TIMESTAMP NOT NULL,
  `valid_to` TIMESTAMP NULL,
  `granted_by` CHAR(36) DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`granted_by`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Project Tables
-- ============================================

CREATE TABLE `projects` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `tenant_id` CHAR(36) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `country` VARCHAR(100) DEFAULT NULL,
  `sector` VARCHAR(100) DEFAULT NULL,
  `languages` TEXT DEFAULT NULL,
  `codebook` JSON DEFAULT NULL,
  `odk_project_uuid` CHAR(36) DEFAULT NULL,
  `odk_xml_form_id` VARCHAR(200) DEFAULT NULL,
  `odk_project_id` BIGINT DEFAULT NULL,
  `status` VARCHAR(50) DEFAULT 'DRAFT',
  `created_by` CHAR(36) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `projects_biz` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `tenant_id` CHAR(36) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `country` VARCHAR(100) DEFAULT NULL,
  `sector` VARCHAR(100) DEFAULT NULL,
  `languages` TEXT DEFAULT NULL,
  `codebook` JSON DEFAULT NULL,
  `odk_project_uuid` CHAR(36) DEFAULT NULL,
  `odk_xml_form_id` VARCHAR(200) DEFAULT NULL,
  `odk_project_id` BIGINT DEFAULT NULL,
  `status` VARCHAR(50) DEFAULT 'DRAFT',
  `created_by` CHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL COMMENT 'Soft delete timestamp',
  `deleted_by` CHAR(36) DEFAULT NULL,
  INDEX `idx_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `forms` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `xml_form_id` VARCHAR(200) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `submissions_raw` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `form_id` CHAR(36) NOT NULL,
  `submission_id` VARCHAR(200) NOT NULL UNIQUE,
  `payload` JSON NOT NULL,
  `submitted_at` TIMESTAMP NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`form_id`) REFERENCES `forms`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `quality_flags` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `submission_id` VARCHAR(200) DEFAULT NULL,
  `flag_type` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `details` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_project_submission_flag` (`project_id`, `submission_id`, `flag_type`),
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `policies` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `pseudonymization` BOOLEAN DEFAULT TRUE,
  `geo_precision` INT DEFAULT 2,
  `retention_months` INT DEFAULT 12,
  `export_allowed` BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sync_cursor` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `form_id` CHAR(36) NOT NULL,
  `last_updated_at` TEXT NOT NULL,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_project_form` (`project_id`, `form_id`),
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`form_id`) REFERENCES `forms`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- App Tables (Legacy)
-- ============================================

CREATE TABLE `app_users` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `grade` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `app_roles` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `name` VARCHAR(120) NOT NULL UNIQUE,
  `description` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `created_by` CHAR(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `app_permissions` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `code` VARCHAR(120) NOT NULL UNIQUE,
  `description` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `app_role_permissions` (
  `role_id` CHAR(36) NOT NULL,
  `permission_id` CHAR(36) NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `app_roles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `app_permissions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `app_user_role_assignments` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `user_id` CHAR(36) NOT NULL,
  `role_id` CHAR(36) NOT NULL,
  `tenant_id` CHAR(36) NOT NULL,
  `project_id` CHAR(36) DEFAULT NULL,
  `valid_from` TIMESTAMP NOT NULL,
  `valid_to` TIMESTAMP NULL,
  `granted_by` CHAR(36) NOT NULL,
  INDEX `idx_user_id` (`user_id`),
  FOREIGN KEY (`user_id`) REFERENCES `app_users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `app_roles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Other Tables
-- ============================================

CREATE TABLE `project_forms` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `template_name` VARCHAR(200) DEFAULT NULL,
  `version` VARCHAR(50) DEFAULT NULL,
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`project_id`) REFERENCES `projects_biz`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `project_integrations` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `project_id` CHAR(36) NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `payload` JSON DEFAULT NULL,
  FOREIGN KEY (`project_id`) REFERENCES `projects_biz`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `form_templates` (
  `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  `name` VARCHAR(150) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `json_spec` JSON NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `audit_logs` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `tenant_id` CHAR(36) DEFAULT NULL,
  `project_id` CHAR(36) DEFAULT NULL,
  `action` VARCHAR(200) NOT NULL,
  `status` VARCHAR(50) DEFAULT NULL,
  `message` TEXT DEFAULT NULL,
  `created_by` VARCHAR(100) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Quartz Scheduler Tables
-- ============================================

CREATE TABLE `qrtz_job_details` (
  `sched_name` VARCHAR(120) NOT NULL,
  `job_name` VARCHAR(200) NOT NULL,
  `job_group` VARCHAR(200) NOT NULL,
  `description` VARCHAR(250) DEFAULT NULL,
  `job_class_name` VARCHAR(250) NOT NULL,
  `is_durable` BOOLEAN NOT NULL,
  `is_nonconcurrent` BOOLEAN NOT NULL,
  `is_update_data` BOOLEAN NOT NULL,
  `requests_recovery` BOOLEAN NOT NULL,
  `job_data` BLOB DEFAULT NULL,
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`),
  INDEX `idx_qrtz_j_req_recovery` (`sched_name`, `requests_recovery`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `qrtz_triggers` (
  `sched_name` VARCHAR(120) NOT NULL,
  `trigger_name` VARCHAR(200) NOT NULL,
  `trigger_group` VARCHAR(200) NOT NULL,
  `job_name` VARCHAR(200) NOT NULL,
  `job_group` VARCHAR(200) NOT NULL,
  `description` VARCHAR(250) DEFAULT NULL,
  `next_fire_time` BIGINT DEFAULT NULL,
  `prev_fire_time` BIGINT DEFAULT NULL,
  `priority` INT DEFAULT NULL,
  `trigger_state` VARCHAR(16) NOT NULL,
  `trigger_type` VARCHAR(8) NOT NULL,
  `start_time` BIGINT NOT NULL,
  `end_time` BIGINT DEFAULT NULL,
  `calendar_name` VARCHAR(200) DEFAULT NULL,
  `misfire_instr` SMALLINT DEFAULT NULL,
  `job_data` BLOB DEFAULT NULL,
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`),
  INDEX `idx_qrtz_t_next_fire_time` (`sched_name`, `next_fire_time`),
  INDEX `idx_qrtz_t_state` (`sched_name`, `trigger_state`),
  FOREIGN KEY (`sched_name`, `job_name`, `job_group`)
    REFERENCES `qrtz_job_details`(`sched_name`, `job_name`, `job_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `qrtz_simple_triggers` (
  `sched_name` VARCHAR(120) NOT NULL,
  `trigger_name` VARCHAR(200) NOT NULL,
  `trigger_group` VARCHAR(200) NOT NULL,
  `repeat_count` BIGINT NOT NULL,
  `repeat_interval` BIGINT NOT NULL,
  `times_triggered` BIGINT NOT NULL,
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`),
  FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`)
    REFERENCES `qrtz_triggers`(`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `qrtz_cron_triggers` (
  `sched_name` VARCHAR(120) NOT NULL,
  `trigger_name` VARCHAR(200) NOT NULL,
  `trigger_group` VARCHAR(200) NOT NULL,
  `cron_expression` VARCHAR(120) NOT NULL,
  `time_zone_id` VARCHAR(80) DEFAULT NULL,
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`),
  FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`)
    REFERENCES `qrtz_triggers`(`sched_name`, `trigger_name`, `trigger_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `qrtz_fired_triggers` (
  `sched_name` VARCHAR(120) NOT NULL,
  `entry_id` VARCHAR(95) NOT NULL,
  `trigger_name` VARCHAR(200) NOT NULL,
  `trigger_group` VARCHAR(200) NOT NULL,
  `instance_name` VARCHAR(200) NOT NULL,
  `fired_time` BIGINT NOT NULL,
  `sched_time` BIGINT NOT NULL,
  `priority` INT NOT NULL,
  `state` VARCHAR(16) NOT NULL,
  `job_name` VARCHAR(200) DEFAULT NULL,
  `job_group` VARCHAR(200) DEFAULT NULL,
  `is_nonconcurrent` BOOLEAN DEFAULT NULL,
  `requests_recovery` BOOLEAN DEFAULT NULL,
  PRIMARY KEY (`sched_name`, `entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `qrtz_scheduler_state` (
  `sched_name` VARCHAR(120) NOT NULL,
  `instance_name` VARCHAR(200) NOT NULL,
  `last_checkin_time` BIGINT NOT NULL,
  `checkin_interval` BIGINT NOT NULL,
  PRIMARY KEY (`sched_name`, `instance_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `qrtz_locks` (
  `sched_name` VARCHAR(120) NOT NULL,
  `lock_name` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`sched_name`, `lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
