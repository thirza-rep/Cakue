-- =============================================================================
-- CAKUE DATABASE SCHEMA (MySQL 8.0)
SET NAMES utf8mb4;
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `cakue_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `cakue_db`;

-- -----------------------------------------------------------------------------
-- 1. CURRENCIES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `currencies` (
    `code` VARCHAR(10) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `symbol` VARCHAR(10) NOT NULL,
    `decimal_places` INT NOT NULL DEFAULT 2,
    `is_base` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` BIGINT NOT NULL,
    `updated_at` BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. USER PROFILES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_profiles` (
    `uuid` VARCHAR(36) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255),
    `avatar_url` TEXT,
    `is_active` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` BIGINT NOT NULL,
    `updated_at` BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. ACCOUNTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `accounts` (
    `uuid` VARCHAR(36) PRIMARY KEY,
    `user_uuid` VARCHAR(36),
    `name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(50) NOT NULL DEFAULT 'bank',
    `currency_code` VARCHAR(10) NOT NULL,
    `initial_balance` DOUBLE NOT NULL DEFAULT 0.0,
    `current_balance` DOUBLE NOT NULL DEFAULT 0.0,
    `color` VARCHAR(20),
    `icon` VARCHAR(50),
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` BIGINT NOT NULL,
    `updated_at` BIGINT NOT NULL,
    `deleted_at` BIGINT,
    `sync_status` VARCHAR(20) NOT NULL DEFAULT 'pending',
    CONSTRAINT `fk_accounts_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies`(`code`) ON DELETE CASCADE,
    CONSTRAINT `fk_accounts_user` FOREIGN KEY (`user_uuid`) REFERENCES `user_profiles`(`uuid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. CATEGORIES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
    `uuid` VARCHAR(36) PRIMARY KEY,
    `parent_uuid` VARCHAR(36),
    `name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(20) NOT NULL DEFAULT 'expense',
    `icon` VARCHAR(50),
    `color` VARCHAR(20),
    `is_system` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` BIGINT NOT NULL,
    `updated_at` BIGINT NOT NULL,
    CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_uuid`) REFERENCES `categories`(`uuid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. TRANSACTIONS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `transactions` (
    `uuid` VARCHAR(36) PRIMARY KEY,
    `user_uuid` VARCHAR(36) NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    `account_uuid` VARCHAR(36) NOT NULL,
    `to_account_uuid` VARCHAR(36),
    `category_uuid` VARCHAR(36),
    `amount` DOUBLE NOT NULL,
    `base_amount` DOUBLE NOT NULL,
    `exchange_rate` DOUBLE NOT NULL DEFAULT 1.0,
    `currency_code` VARCHAR(10) NOT NULL,
    `date` BIGINT NOT NULL,
    `note` TEXT,
    `merchant` VARCHAR(100),
    `receipt_image_path` TEXT,
    `is_recurring` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` BIGINT NOT NULL,
    `updated_at` BIGINT NOT NULL,
    `deleted_at` BIGINT,
    `sync_status` VARCHAR(20) NOT NULL DEFAULT 'pending',
    CONSTRAINT `fk_tx_account` FOREIGN KEY (`account_uuid`) REFERENCES `accounts`(`uuid`) ON DELETE CASCADE,
    CONSTRAINT `fk_tx_to_account` FOREIGN KEY (`to_account_uuid`) REFERENCES `accounts`(`uuid`) ON DELETE SET NULL,
    CONSTRAINT `fk_tx_category` FOREIGN KEY (`category_uuid`) REFERENCES `categories`(`uuid`) ON DELETE SET NULL,
    CONSTRAINT `fk_tx_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies`(`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. MONTHLY SUMMARIES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `monthly_summaries` (
    `uuid` VARCHAR(36) PRIMARY KEY,
    `user_uuid` VARCHAR(36) NOT NULL,
    `year_month` VARCHAR(7) NOT NULL,
    `total_income` DOUBLE NOT NULL DEFAULT 0.0,
    `total_expense` DOUBLE NOT NULL DEFAULT 0.0,
    `total_transfer` DOUBLE NOT NULL DEFAULT 0.0,
    `currency_code` VARCHAR(10) NOT NULL,
    `updated_at` BIGINT NOT NULL,
    UNIQUE KEY `uk_user_month_curr` (`user_uuid`, `year_month`, `currency_code`),
    CONSTRAINT `fk_summary_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies`(`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. BUDGETS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `budgets` (
    `uuid` VARCHAR(36) PRIMARY KEY,
    `user_uuid` VARCHAR(36) NOT NULL,
    `category_uuid` VARCHAR(36),
    `amount` DOUBLE NOT NULL,
    `period_type` VARCHAR(20) NOT NULL DEFAULT 'monthly',
    `created_at` BIGINT NOT NULL,
    `updated_at` BIGINT NOT NULL,
    CONSTRAINT `fk_budget_category` FOREIGN KEY (`category_uuid`) REFERENCES `categories`(`uuid`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. SYNC LOGS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sync_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `sync_time` BIGINT NOT NULL,
    `status` VARCHAR(20) NOT NULL,
    `records_synced` INT NOT NULL DEFAULT 0,
    `details` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- -----------------------------------------------------------------------------
CREATE INDEX `idx_tx_date` ON `transactions`(`date` DESC);
CREATE INDEX `idx_tx_account_date` ON `transactions`(`account_uuid`, `date` DESC);
CREATE INDEX `idx_tx_category_date` ON `transactions`(`category_uuid`, `date` DESC);
CREATE INDEX `idx_tx_user_date` ON `transactions`(`user_uuid`, `date` DESC);
CREATE INDEX `idx_summary_user_month` ON `monthly_summaries`(`user_uuid`, `year_month`);

-- -----------------------------------------------------------------------------
-- INITIAL SEED DATA (Currencies & Default Categories)
-- -----------------------------------------------------------------------------
INSERT INTO `currencies` (`code`, `name`, `symbol`, `decimal_places`, `is_base`, `created_at`, `updated_at`) VALUES
('IDR', 'Indonesian Rupiah', 'Rp', 0, 1, 1726354800000, 1726354800000),
('USD', 'US Dollar', '$', 2, 0, 1726354800000, 1726354800000),
('SGD', 'Singapore Dollar', 'S$', 2, 0, 1726354800000, 1726354800000),
('EUR', 'Euro', '€', 2, 0, 1726354800000, 1726354800000)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

-- Expense Parent Categories
INSERT INTO `categories` (`uuid`, `parent_uuid`, `name`, `type`, `icon`, `color`, `is_system`, `created_at`, `updated_at`) VALUES
('cat-food', NULL, 'Makanan & Minuman', 'expense', '🍽️', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-transport', NULL, 'Transportasi', 'expense', '🚗', '#6B87C7', 0, 1726354800000, 1726354800000),
('cat-shopping', NULL, 'Belanja', 'expense', '🛍️', '#CAC597', 0, 1726354800000, 1726354800000),
('cat-health', NULL, 'Kesehatan', 'expense', '💊', '#4CAF81', 0, 1726354800000, 1726354800000),
('cat-entertainment', NULL, 'Hiburan', 'expense', '🎬', '#A5B4E1', 0, 1726354800000, 1726354800000),
('cat-education', NULL, 'Pendidikan', 'expense', '📚', '#8FA87A', 0, 1726354800000, 1726354800000),
('cat-utilities', NULL, 'Tagihan & Utilitas', 'expense', '💡', '#FFC107', 0, 1726354800000, 1726354800000),
('cat-rent', NULL, 'Sewa & Properti', 'expense', '🏠', '#3E4F2C', 0, 1726354800000, 1726354800000),
('cat-other-exp', NULL, 'Lainnya', 'expense', '📦', '#ADADB8', 0, 1726354800000, 1726354800000)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

-- Expense Sub-Categories
INSERT INTO `categories` (`uuid`, `parent_uuid`, `name`, `type`, `icon`, `color`, `is_system`, `created_at`, `updated_at`) VALUES
('cat-breakfast', 'cat-food', 'Sarapan', 'expense', '☕', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-lunch', 'cat-food', 'Makan Siang', 'expense', '🍱', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-dinner', 'cat-food', 'Makan Malam', 'expense', '🍴', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-snack', 'cat-food', 'Camilan', 'expense', '🍿', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-coffee', 'cat-food', 'Kopi & Minuman', 'expense', '☕', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-fuel', 'cat-transport', 'BBM', 'expense', '⛽', '#6B87C7', 0, 1726354800000, 1726354800000),
('cat-parking', 'cat-transport', 'Parkir', 'expense', '🅿️', '#6B87C7', 0, 1726354800000, 1726354800000),
('cat-ride', 'cat-transport', 'Ride-sharing', 'expense', '🛵', '#6B87C7', 0, 1726354800000, 1726354800000),
('cat-clothes', 'cat-shopping', 'Pakaian', 'expense', '👕', '#CAC597', 0, 1726354800000, 1726354800000),
('cat-gadget', 'cat-shopping', 'Elektronik', 'expense', '📱', '#CAC597', 0, 1726354800000, 1726354800000),
('cat-electric', 'cat-utilities', 'Listrik', 'expense', '⚡', '#FFC107', 0, 1726354800000, 1726354800000),
('cat-internet', 'cat-utilities', 'Internet', 'expense', '📡', '#FFC107', 0, 1726354800000, 1726354800000),
('cat-phone', 'cat-utilities', 'Pulsa & Paket', 'expense', '📶', '#FFC107', 0, 1726354800000, 1726354800000)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

-- Income & Transfer Categories
INSERT INTO `categories` (`uuid`, `parent_uuid`, `name`, `type`, `icon`, `color`, `is_system`, `created_at`, `updated_at`) VALUES
('cat-salary', NULL, 'Gaji', 'income', '💼', '#4CAF81', 0, 1726354800000, 1726354800000),
('cat-freelance', NULL, 'Freelance', 'income', '💻', '#8FA87A', 0, 1726354800000, 1726354800000),
('cat-investment', NULL, 'Investasi', 'income', '📈', '#6B87C7', 0, 1726354800000, 1726354800000),
('cat-gift', NULL, 'Hadiah / THR', 'income', '🎁', '#FD7F65', 0, 1726354800000, 1726354800000),
('cat-other-inc', NULL, 'Pendapatan Lain', 'income', '💰', '#ADADB8', 0, 1726354800000, 1726354800000),
('cat-transfer', NULL, 'Transfer', 'transfer', '↔️', '#A5B4E1', 1, 1726354800000, 1726354800000)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

