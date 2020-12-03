-- Valentina Studio --
-- MySQL dump --
-- ---------------------------------------------------------


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
-- ---------------------------------------------------------

-- CREATE DATABASE "aquarium_test" ----------------------------------
DROP DATABASE IF EXISTS `aquarium_test`;
CREATE DATABASE `aquarium_test` CHARACTER SET latin1 COLLATE latin1_swedish_ci;
GRANT ALL PRIVILEGES ON aquarium_test.* TO 'aquarium'@'%';
USE `aquarium_test`;
-- ---------------------------------------------------------


-- CREATE TABLE "account_logs" ---------------------------------
CREATE TABLE `account_logs`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`row1` Int( 11 ) NULL,
	`row2` Int( 11 ) NULL,
	`user_id` Int( 11 ) NULL,
	`note` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 1696;
-- -------------------------------------------------------------


-- CREATE TABLE "accounts" -------------------------------------
CREATE TABLE `accounts`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`transaction_type` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`amount` Float( 12, 0 ) NULL,
	`user_id` Int( 11 ) NULL,
	`budget_id` Int( 11 ) NULL,
	`category` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`job_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`description` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`labor_rate` Float( 12, 0 ) NULL,
	`markup_rate` Float( 12, 0 ) NULL,
	`operation_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 343482;
-- -------------------------------------------------------------


-- CREATE TABLE "allowable_field_types" ------------------------
CREATE TABLE `allowable_field_types`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`field_type_id` Int( 11 ) NULL,
	`sample_type_id` Int( 11 ) NULL,
	`object_type_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 3305;
-- -------------------------------------------------------------


-- CREATE TABLE "announcements" --------------------------------
CREATE TABLE `announcements`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`title` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`message` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`active` TinyInt( 1 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 22;
-- -------------------------------------------------------------


-- CREATE TABLE "ar_internal_metadata" -------------------------
CREATE TABLE `ar_internal_metadata`(
	`key` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`value` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `key` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------


-- CREATE TABLE "budgets" --------------------------------------
CREATE TABLE `budgets`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`overhead` Float( 12, 0 ) NULL,
	`contact` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`description` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`email` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`phone` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 87;
-- -------------------------------------------------------------


-- CREATE TABLE "codes" ----------------------------------------
CREATE TABLE `codes`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`content` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`parent_id` Int( 11 ) NULL,
	`parent_class` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`user_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 21839;
-- -------------------------------------------------------------


-- CREATE TABLE "data_associations" ----------------------------
CREATE TABLE `data_associations`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`parent_id` Int( 11 ) NULL,
	`parent_class` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`key` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`upload_id` Int( 11 ) NULL,
	`object` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 945690;
-- -------------------------------------------------------------


-- CREATE TABLE "field_types" ----------------------------------
CREATE TABLE `field_types`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`parent_id` Int( 11 ) NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`ftype` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`choices` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`array` TinyInt( 1 ) NULL,
	`required` TinyInt( 1 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`parent_class` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`role` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`part` TinyInt( 1 ) NULL,
	`routing` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`preferred_operation_type_id` Int( 11 ) NULL,
	`preferred_field_type_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 17489;
-- -------------------------------------------------------------


-- CREATE TABLE "field_values" ---------------------------------
CREATE TABLE `field_values`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`parent_id` Int( 11 ) NULL,
	`value` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`child_sample_id` Int( 11 ) NULL,
	`child_item_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`parent_class` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`role` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`field_type_id` Int( 11 ) NULL,
	`row` Int( 11 ) NULL,
	`column` Int( 11 ) NULL,
	`allowable_field_type_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 1075399;
-- -------------------------------------------------------------


-- CREATE TABLE "folder_contents" ------------------------------
CREATE TABLE `folder_contents`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`sample_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`folder_id` Int( 11 ) NULL,
	`workflow_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 9;
-- -------------------------------------------------------------


-- CREATE TABLE "folders" --------------------------------------
CREATE TABLE `folders`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`user_id` Int( 11 ) NULL,
	`parent_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 74;
-- -------------------------------------------------------------


-- CREATE TABLE "groups" ---------------------------------------
CREATE TABLE `groups`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`description` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 359;
-- -------------------------------------------------------------


-- CREATE TABLE "invoices" -------------------------------------
CREATE TABLE `invoices`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`year` Int( 11 ) NULL,
	`month` Int( 11 ) NULL,
	`budget_id` Int( 11 ) NULL,
	`user_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`status` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`notes` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 1733;
-- -------------------------------------------------------------


-- CREATE TABLE "items" ----------------------------------------
CREATE TABLE `items`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`location` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`quantity` Int( 11 ) NULL,
	`object_type_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`inuse` Int( 11 ) NULL DEFAULT 0,
	`sample_id` Int( 11 ) NULL,
	`data` MediumText CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`locator_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 463887;
-- -------------------------------------------------------------


-- CREATE TABLE "job_assignment_logs" --------------------------
CREATE TABLE `job_assignment_logs`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`job_id` Int( 11 ) NULL,
	`assigned_by` Int( 11 ) NULL,
	`assigned_to` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 103;
-- -------------------------------------------------------------


-- CREATE TABLE "job_associations" -----------------------------
CREATE TABLE `job_associations`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`job_id` Int( 11 ) NULL,
	`operation_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 164448;
-- -------------------------------------------------------------


-- CREATE TABLE "jobs" -----------------------------------------
CREATE TABLE `jobs`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`user_id` Int( 11 ) NULL,
	`arguments` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`state` LongText CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`path` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`pc` Int( 11 ) NULL,
	`group_id` Int( 11 ) NULL,
	`submitted_by` Int( 11 ) NULL,
	`desired_start_time` DateTime NULL,
	`latest_start_time` DateTime NULL,
	`metacol_id` Int( 11 ) NULL,
	`successor_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 117791;
-- -------------------------------------------------------------


-- CREATE TABLE "libraries" ------------------------------------
CREATE TABLE `libraries`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`category` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 324;
-- -------------------------------------------------------------


-- CREATE TABLE "locators" -------------------------------------
CREATE TABLE `locators`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`wizard_id` Int( 11 ) NULL,
	`item_id` Int( 11 ) NULL,
	`number` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 67779;
-- -------------------------------------------------------------


-- CREATE TABLE "logs" -----------------------------------------
CREATE TABLE `logs`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`job_id` Int( 11 ) NULL,
	`user_id` Int( 11 ) NULL,
	`entry_type` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`data` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 147772;
-- -------------------------------------------------------------


-- CREATE TABLE "memberships" ----------------------------------
CREATE TABLE `memberships`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`user_id` Int( 11 ) NULL,
	`group_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 815;
-- -------------------------------------------------------------


-- CREATE TABLE "object_types" ---------------------------------
CREATE TABLE `object_types`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`description` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`min` Int( 11 ) NULL,
	`max` Int( 11 ) NULL,
	`handler` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`safety` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`cleanup` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`data` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`vendor` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`unit` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`cost` Float( 12, 0 ) NULL,
	`release_method` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`release_description` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`sample_type_id` Int( 11 ) NULL,
	`image` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`prefix` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`rows` Int( 11 ) NULL,
	`columns` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 866;
-- -------------------------------------------------------------


-- CREATE TABLE "operation_types" ------------------------------
CREATE TABLE `operation_types`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`category` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`deployed` TinyInt( 1 ) NULL,
	`on_the_fly` TinyInt( 1 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ),
	CONSTRAINT `index_operation_types_on_category_and_name` UNIQUE( `category`, `name` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 834;
-- -------------------------------------------------------------


-- CREATE TABLE "operations" -----------------------------------
CREATE TABLE `operations`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`operation_type_id` Int( 11 ) NULL,
	`status` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`user_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`x` Float( 12, 0 ) NULL,
	`y` Float( 12, 0 ) NULL,
	`parent_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 292891;
-- -------------------------------------------------------------


-- CREATE TABLE "parameters" -----------------------------------
CREATE TABLE `parameters`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`key` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`value` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`description` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`user_id` Int( 11 ) NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 1714;
-- -------------------------------------------------------------


-- CREATE TABLE "part_associations" ----------------------------
CREATE TABLE `part_associations`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`part_id` Int( 11 ) NULL,
	`collection_id` Int( 11 ) NULL,
	`row` Int( 11 ) NULL,
	`column` Int( 11 ) NULL,
	`created_at` DateTime NULL,
	`updated_at` DateTime NULL,
	PRIMARY KEY ( `id` ),
	CONSTRAINT `index_part_associations_on_collection_id_and_row_and_column` UNIQUE( `collection_id`, `row`, `column` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 219324;
-- -------------------------------------------------------------


-- CREATE TABLE "permissions" ----------------------------------
CREATE TABLE `permissions`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`sort` Int( 11 ) NULL,
	`created_at` DateTime NULL,
	`updated_at` DateTime NULL,
	PRIMARY KEY ( `id` ),
	CONSTRAINT `index_permissions_on_name` UNIQUE( `name` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 7;
-- -------------------------------------------------------------


-- CREATE TABLE "plan_associations" ----------------------------
CREATE TABLE `plan_associations`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`plan_id` Int( 11 ) NULL,
	`operation_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 278343;
-- -------------------------------------------------------------


-- CREATE TABLE "plans" ----------------------------------------
CREATE TABLE `plans`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`user_id` Int( 11 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`budget_id` Int( 11 ) NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`status` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`cost_limit` Float( 12, 0 ) NULL,
	`folder` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`layout` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 40365;
-- -------------------------------------------------------------


-- CREATE TABLE "sample_types" ---------------------------------
CREATE TABLE `sample_types`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`description` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 97;
-- -------------------------------------------------------------


-- CREATE TABLE "samples" --------------------------------------
CREATE TABLE `samples`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`sample_type_id` Int( 11 ) NULL,
	`project` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`user_id` Int( 11 ) NULL,
	`description` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`data` Text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 34480;
-- -------------------------------------------------------------


-- CREATE TABLE "schema_migrations" ----------------------------
CREATE TABLE `schema_migrations`(
	`version` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	CONSTRAINT `unique_schema_migrations` UNIQUE( `version` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------


-- CREATE TABLE "timings" --------------------------------------
CREATE TABLE `timings`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`parent_id` Int( 11 ) NULL,
	`parent_class` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`days` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`start` Int( 11 ) NULL,
	`stop` Int( 11 ) NULL,
	`active` TinyInt( 1 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 147;
-- -------------------------------------------------------------


-- CREATE TABLE "uploads" --------------------------------------
CREATE TABLE `uploads`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`job_id` Int( 11 ) NULL,
	`upload_file_name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`upload_content_type` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`upload_file_size` Int( 11 ) NULL,
	`upload_updated_at` DateTime NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 42397;
-- -------------------------------------------------------------


-- CREATE TABLE "user_budget_associations" ---------------------
CREATE TABLE `user_budget_associations`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`user_id` Int( 11 ) NULL,
	`budget_id` Int( 11 ) NULL,
	`quota` Float( 12, 0 ) NULL,
	`disabled` TinyInt( 1 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 372;
-- -------------------------------------------------------------


-- CREATE TABLE "user_tokens" ----------------------------------
CREATE TABLE `user_tokens`(
	`user_id` Int( 11 ) NOT NULL,
	`token` VarChar( 128 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`ip` VarChar( 18 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`timenow` DateTime NOT NULL,
	PRIMARY KEY ( `ip`, `token` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------


-- CREATE TABLE "users" ----------------------------------------
CREATE TABLE `users`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`login` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`password_digest` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`remember_token` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`admin` TinyInt( 1 ) NULL DEFAULT 0,
	`key` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`permission_ids` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '.',
	PRIMARY KEY ( `id` ),
	CONSTRAINT `index_users_on_login` UNIQUE( `login` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 334;
-- -------------------------------------------------------------


-- CREATE TABLE "wires" ----------------------------------------
CREATE TABLE `wires`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`from_id` Int( 11 ) NULL,
	`to_id` Int( 11 ) NULL,
	`active` TinyInt( 1 ) NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 217845;
-- -------------------------------------------------------------


-- CREATE TABLE "wizards" --------------------------------------
CREATE TABLE `wizards`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`specification` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NOT NULL,
	`updated_at` DateTime NOT NULL,
	`description` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 28;
-- -------------------------------------------------------------


-- CREATE TABLE "workers" --------------------------------------
CREATE TABLE `workers`(
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`message` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`status` VarChar( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
	`created_at` DateTime NULL,
	`updated_at` DateTime NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB
AUTO_INCREMENT = 32;
-- -------------------------------------------------------------


-- CREATE INDEX "fk_rails_8e6656e8a4" --------------------------
CREATE INDEX `fk_rails_8e6656e8a4` USING BTREE ON `account_logs`( `row2` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_account_logs_on_row1" -------------------
CREATE INDEX `index_account_logs_on_row1` USING BTREE ON `account_logs`( `row1` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_account_log_associations_on_user_id" ----
CREATE INDEX `index_account_log_associations_on_user_id` USING BTREE ON `account_logs`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_accounts_on_budget_id" ------------------
CREATE INDEX `index_accounts_on_budget_id` USING BTREE ON `accounts`( `budget_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_accounts_on_job_id" ---------------------
CREATE INDEX `index_accounts_on_job_id` USING BTREE ON `accounts`( `job_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_accounts_on_operation_id" ---------------
CREATE INDEX `index_accounts_on_operation_id` USING BTREE ON `accounts`( `operation_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_accounts_on_user_id" --------------------
CREATE INDEX `index_accounts_on_user_id` USING BTREE ON `accounts`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_allowable_field_types_on_field_type_id" -
CREATE INDEX `index_allowable_field_types_on_field_type_id` USING BTREE ON `allowable_field_types`( `field_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_allowable_field_types_on_object_type_id"
CREATE INDEX `index_allowable_field_types_on_object_type_id` USING BTREE ON `allowable_field_types`( `object_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_allowable_field_types_on_sample_type_id"
CREATE INDEX `index_allowable_field_types_on_sample_type_id` USING BTREE ON `allowable_field_types`( `sample_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_data_associations_on_parent_class_and_parent_id"
CREATE INDEX `index_data_associations_on_parent_class_and_parent_id` USING BTREE ON `data_associations`( `parent_class`, `parent_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_data_associations_on_upload_id" ---------
CREATE INDEX `index_data_associations_on_upload_id` USING BTREE ON `data_associations`( `upload_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_field_types_on_parent_class_and_parent_id"
CREATE INDEX `index_field_types_on_parent_class_and_parent_id` USING BTREE ON `field_types`( `parent_class`, `parent_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_field_types_on_sample_type_id" ----------
CREATE INDEX `index_field_types_on_sample_type_id` USING BTREE ON `field_types`( `parent_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "fk_rails_319b222007" --------------------------
CREATE INDEX `fk_rails_319b222007` USING BTREE ON `field_values`( `child_item_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "fk_rails_e04e5b0273" --------------------------
CREATE INDEX `fk_rails_e04e5b0273` USING BTREE ON `field_values`( `child_sample_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_field_values_on_allowable_field_type_id"
CREATE INDEX `index_field_values_on_allowable_field_type_id` USING BTREE ON `field_values`( `allowable_field_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_field_values_on_field_type_id" ----------
CREATE INDEX `index_field_values_on_field_type_id` USING BTREE ON `field_values`( `field_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_field_values_on_parent_class_and_parent_id"
CREATE INDEX `index_field_values_on_parent_class_and_parent_id` USING BTREE ON `field_values`( `parent_class`, `parent_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_field_values_on_sample_id" --------------
CREATE INDEX `index_field_values_on_sample_id` USING BTREE ON `field_values`( `parent_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_invoices_on_budget_id" ------------------
CREATE INDEX `index_invoices_on_budget_id` USING BTREE ON `invoices`( `budget_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_invoices_on_user_id" --------------------
CREATE INDEX `index_invoices_on_user_id` USING BTREE ON `invoices`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_items_on_locator_id" --------------------
CREATE INDEX `index_items_on_locator_id` USING BTREE ON `items`( `locator_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_items_on_object_type_id" ----------------
CREATE INDEX `index_items_on_object_type_id` USING BTREE ON `items`( `object_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_items_on_sample_id" ---------------------
CREATE INDEX `index_items_on_sample_id` USING BTREE ON `items`( `sample_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_job_assignment_logs_on_assigned_by" -----
CREATE INDEX `index_job_assignment_logs_on_assigned_by` USING BTREE ON `job_assignment_logs`( `assigned_by` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_job_assignment_logs_on_assigned_to" -----
CREATE INDEX `index_job_assignment_logs_on_assigned_to` USING BTREE ON `job_assignment_logs`( `assigned_to` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_job_assignment_logs_on_job_id" ----------
CREATE INDEX `index_job_assignment_logs_on_job_id` USING BTREE ON `job_assignment_logs`( `job_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_job_associations_on_job_id" -------------
CREATE INDEX `index_job_associations_on_job_id` USING BTREE ON `job_associations`( `job_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_job_associations_on_operation_id" -------
CREATE INDEX `index_job_associations_on_operation_id` USING BTREE ON `job_associations`( `operation_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_jobs_on_group_id" -----------------------
CREATE INDEX `index_jobs_on_group_id` USING BTREE ON `jobs`( `group_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_jobs_on_user_id" ------------------------
CREATE INDEX `index_jobs_on_user_id` USING BTREE ON `jobs`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_locators_on_item_id" --------------------
CREATE INDEX `index_locators_on_item_id` USING BTREE ON `locators`( `item_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_locators_on_wizard_id" ------------------
CREATE INDEX `index_locators_on_wizard_id` USING BTREE ON `locators`( `wizard_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_logs_on_job_id" -------------------------
CREATE INDEX `index_logs_on_job_id` USING BTREE ON `logs`( `job_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_logs_on_user_id" ------------------------
CREATE INDEX `index_logs_on_user_id` USING BTREE ON `logs`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_memberships_on_group_id" ----------------
CREATE INDEX `index_memberships_on_group_id` USING BTREE ON `memberships`( `group_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_memberships_on_user_id" -----------------
CREATE INDEX `index_memberships_on_user_id` USING BTREE ON `memberships`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_operations_on_operation_type_id" --------
CREATE INDEX `index_operations_on_operation_type_id` USING BTREE ON `operations`( `operation_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_operations_on_user_id" ------------------
CREATE INDEX `index_operations_on_user_id` USING BTREE ON `operations`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_part_associations_on_part_id" -----------
CREATE INDEX `index_part_associations_on_part_id` USING BTREE ON `part_associations`( `part_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_plan_associations_on_operation_id" ------
CREATE INDEX `index_plan_associations_on_operation_id` USING BTREE ON `plan_associations`( `operation_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_plan_associations_on_plan_id" -----------
CREATE INDEX `index_plan_associations_on_plan_id` USING BTREE ON `plan_associations`( `plan_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_plans_on_budget_id" ---------------------
CREATE INDEX `index_plans_on_budget_id` USING BTREE ON `plans`( `budget_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_plans_on_user_id" -----------------------
CREATE INDEX `index_plans_on_user_id` USING BTREE ON `plans`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_samples_on_sample_type_id" --------------
CREATE INDEX `index_samples_on_sample_type_id` USING BTREE ON `samples`( `sample_type_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_samples_on_user_id" ---------------------
CREATE INDEX `index_samples_on_user_id` USING BTREE ON `samples`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_timings_on_parent_class_and_parent_id" --
CREATE INDEX `index_timings_on_parent_class_and_parent_id` USING BTREE ON `timings`( `parent_class`, `parent_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_uploads_on_job_id" ----------------------
CREATE INDEX `index_uploads_on_job_id` USING BTREE ON `uploads`( `job_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_user_budget_associations_on_budget_id" --
CREATE INDEX `index_user_budget_associations_on_budget_id` USING BTREE ON `user_budget_associations`( `budget_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_user_budget_associations_on_user_id" ----
CREATE INDEX `index_user_budget_associations_on_user_id` USING BTREE ON `user_budget_associations`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "fk_rails_e0a9c15abb" --------------------------
CREATE INDEX `fk_rails_e0a9c15abb` USING BTREE ON `user_tokens`( `user_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_users_on_remember_token" ----------------
CREATE INDEX `index_users_on_remember_token` USING BTREE ON `users`( `remember_token` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_wires_on_from_id" -----------------------
CREATE INDEX `index_wires_on_from_id` USING BTREE ON `wires`( `from_id` );
-- -------------------------------------------------------------


-- CREATE INDEX "index_wires_on_to_id" -------------------------
CREATE INDEX `index_wires_on_to_id` USING BTREE ON `wires`( `to_id` );
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_0fc0d85f00" ---------------------------
ALTER TABLE `account_logs`
	ADD CONSTRAINT `fk_rails_0fc0d85f00` FOREIGN KEY ( `row1` )
	REFERENCES `accounts`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_8e6656e8a4" ---------------------------
ALTER TABLE `account_logs`
	ADD CONSTRAINT `fk_rails_8e6656e8a4` FOREIGN KEY ( `row2` )
	REFERENCES `accounts`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_c91e200913" ---------------------------
ALTER TABLE `account_logs`
	ADD CONSTRAINT `fk_rails_c91e200913` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_17f7ad8fd1" ---------------------------
ALTER TABLE `accounts`
	ADD CONSTRAINT `fk_rails_17f7ad8fd1` FOREIGN KEY ( `budget_id` )
	REFERENCES `budgets`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_9910875b16" ---------------------------
ALTER TABLE `accounts`
	ADD CONSTRAINT `fk_rails_9910875b16` FOREIGN KEY ( `job_id` )
	REFERENCES `jobs`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_b1e30bebc8" ---------------------------
ALTER TABLE `accounts`
	ADD CONSTRAINT `fk_rails_b1e30bebc8` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_ba2f9f474f" ---------------------------
ALTER TABLE `accounts`
	ADD CONSTRAINT `fk_rails_ba2f9f474f` FOREIGN KEY ( `operation_id` )
	REFERENCES `operations`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_1d47761735" ---------------------------
ALTER TABLE `allowable_field_types`
	ADD CONSTRAINT `fk_rails_1d47761735` FOREIGN KEY ( `field_type_id` )
	REFERENCES `field_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_2bc0f30ee5" ---------------------------
ALTER TABLE `allowable_field_types`
	ADD CONSTRAINT `fk_rails_2bc0f30ee5` FOREIGN KEY ( `sample_type_id` )
	REFERENCES `sample_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_a968b4a54c" ---------------------------
ALTER TABLE `allowable_field_types`
	ADD CONSTRAINT `fk_rails_a968b4a54c` FOREIGN KEY ( `object_type_id` )
	REFERENCES `object_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_26226b25a9" ---------------------------
ALTER TABLE `data_associations`
	ADD CONSTRAINT `fk_rails_26226b25a9` FOREIGN KEY ( `upload_id` )
	REFERENCES `uploads`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_212ef5a639" ---------------------------
ALTER TABLE `field_values`
	ADD CONSTRAINT `fk_rails_212ef5a639` FOREIGN KEY ( `field_type_id` )
	REFERENCES `field_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_319b222007" ---------------------------
ALTER TABLE `field_values`
	ADD CONSTRAINT `fk_rails_319b222007` FOREIGN KEY ( `child_item_id` )
	REFERENCES `items`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_50fa557e81" ---------------------------
ALTER TABLE `field_values`
	ADD CONSTRAINT `fk_rails_50fa557e81` FOREIGN KEY ( `allowable_field_type_id` )
	REFERENCES `allowable_field_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_e04e5b0273" ---------------------------
ALTER TABLE `field_values`
	ADD CONSTRAINT `fk_rails_e04e5b0273` FOREIGN KEY ( `child_sample_id` )
	REFERENCES `samples`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_3d1522a0d8" ---------------------------
ALTER TABLE `invoices`
	ADD CONSTRAINT `fk_rails_3d1522a0d8` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_3dd4c64f3b" ---------------------------
ALTER TABLE `invoices`
	ADD CONSTRAINT `fk_rails_3dd4c64f3b` FOREIGN KEY ( `budget_id` )
	REFERENCES `budgets`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_6b7d1f696e" ---------------------------
ALTER TABLE `items`
	ADD CONSTRAINT `fk_rails_6b7d1f696e` FOREIGN KEY ( `sample_id` )
	REFERENCES `samples`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_a6ef7e6462" ---------------------------
ALTER TABLE `items`
	ADD CONSTRAINT `fk_rails_a6ef7e6462` FOREIGN KEY ( `object_type_id` )
	REFERENCES `object_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_d02c2a2df1" ---------------------------
ALTER TABLE `items`
	ADD CONSTRAINT `fk_rails_d02c2a2df1` FOREIGN KEY ( `locator_id` )
	REFERENCES `locators`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_3c67081d23" ---------------------------
ALTER TABLE `job_assignment_logs`
	ADD CONSTRAINT `fk_rails_3c67081d23` FOREIGN KEY ( `assigned_to` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_afd4527da7" ---------------------------
ALTER TABLE `job_assignment_logs`
	ADD CONSTRAINT `fk_rails_afd4527da7` FOREIGN KEY ( `job_id` )
	REFERENCES `jobs`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_cec96ca499" ---------------------------
ALTER TABLE `job_assignment_logs`
	ADD CONSTRAINT `fk_rails_cec96ca499` FOREIGN KEY ( `assigned_by` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_25efd65a81" ---------------------------
ALTER TABLE `job_associations`
	ADD CONSTRAINT `fk_rails_25efd65a81` FOREIGN KEY ( `job_id` )
	REFERENCES `jobs`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_8f590b1e09" ---------------------------
ALTER TABLE `job_associations`
	ADD CONSTRAINT `fk_rails_8f590b1e09` FOREIGN KEY ( `operation_id` )
	REFERENCES `operations`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_4928288085" ---------------------------
ALTER TABLE `jobs`
	ADD CONSTRAINT `fk_rails_4928288085` FOREIGN KEY ( `group_id` )
	REFERENCES `groups`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_df6238c8a6" ---------------------------
ALTER TABLE `jobs`
	ADD CONSTRAINT `fk_rails_df6238c8a6` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_64c3d29cac" ---------------------------
ALTER TABLE `locators`
	ADD CONSTRAINT `fk_rails_64c3d29cac` FOREIGN KEY ( `item_id` )
	REFERENCES `items`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_bb120b6235" ---------------------------
ALTER TABLE `locators`
	ADD CONSTRAINT `fk_rails_bb120b6235` FOREIGN KEY ( `wizard_id` )
	REFERENCES `wizards`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_81ff90ed92" ---------------------------
ALTER TABLE `logs`
	ADD CONSTRAINT `fk_rails_81ff90ed92` FOREIGN KEY ( `job_id` )
	REFERENCES `jobs`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_8fc980bf44" ---------------------------
ALTER TABLE `logs`
	ADD CONSTRAINT `fk_rails_8fc980bf44` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_99326fb65d" ---------------------------
ALTER TABLE `memberships`
	ADD CONSTRAINT `fk_rails_99326fb65d` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_aaf389f138" ---------------------------
ALTER TABLE `memberships`
	ADD CONSTRAINT `fk_rails_aaf389f138` FOREIGN KEY ( `group_id` )
	REFERENCES `groups`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_10e3ccbd52" ---------------------------
ALTER TABLE `operations`
	ADD CONSTRAINT `fk_rails_10e3ccbd52` FOREIGN KEY ( `operation_type_id` )
	REFERENCES `operation_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_63fbf4e94e" ---------------------------
ALTER TABLE `operations`
	ADD CONSTRAINT `fk_rails_63fbf4e94e` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_39a9c3d5bb" ---------------------------
ALTER TABLE `part_associations`
	ADD CONSTRAINT `fk_rails_39a9c3d5bb` FOREIGN KEY ( `part_id` )
	REFERENCES `items`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_f889cf647d" ---------------------------
ALTER TABLE `part_associations`
	ADD CONSTRAINT `fk_rails_f889cf647d` FOREIGN KEY ( `collection_id` )
	REFERENCES `items`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_5ca5742cd9" ---------------------------
ALTER TABLE `plan_associations`
	ADD CONSTRAINT `fk_rails_5ca5742cd9` FOREIGN KEY ( `plan_id` )
	REFERENCES `plans`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_c36597dd79" ---------------------------
ALTER TABLE `plan_associations`
	ADD CONSTRAINT `fk_rails_c36597dd79` FOREIGN KEY ( `operation_id` )
	REFERENCES `operations`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_45da853770" ---------------------------
ALTER TABLE `plans`
	ADD CONSTRAINT `fk_rails_45da853770` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_55f7cff6c3" ---------------------------
ALTER TABLE `plans`
	ADD CONSTRAINT `fk_rails_55f7cff6c3` FOREIGN KEY ( `budget_id` )
	REFERENCES `budgets`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_8e0800c2e2" ---------------------------
ALTER TABLE `samples`
	ADD CONSTRAINT `fk_rails_8e0800c2e2` FOREIGN KEY ( `sample_type_id` )
	REFERENCES `sample_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_d699eb2564" ---------------------------
ALTER TABLE `samples`
	ADD CONSTRAINT `fk_rails_d699eb2564` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_76093eb5d3" ---------------------------
ALTER TABLE `uploads`
	ADD CONSTRAINT `fk_rails_76093eb5d3` FOREIGN KEY ( `job_id` )
	REFERENCES `jobs`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_a2966bc54b" ---------------------------
ALTER TABLE `user_budget_associations`
	ADD CONSTRAINT `fk_rails_a2966bc54b` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_f1322363b9" ---------------------------
ALTER TABLE `user_budget_associations`
	ADD CONSTRAINT `fk_rails_f1322363b9` FOREIGN KEY ( `budget_id` )
	REFERENCES `budgets`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_e0a9c15abb" ---------------------------
ALTER TABLE `user_tokens`
	ADD CONSTRAINT `fk_rails_e0a9c15abb` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_1073ab769d" ---------------------------
ALTER TABLE `wires`
	ADD CONSTRAINT `fk_rails_1073ab769d` FOREIGN KEY ( `to_id` )
	REFERENCES `field_values`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE LINK "fk_rails_684cde68aa" ---------------------------
ALTER TABLE `wires`
	ADD CONSTRAINT `fk_rails_684cde68aa` FOREIGN KEY ( `from_id` )
	REFERENCES `field_values`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------


-- CREATE VIEW "view_job_operation_types" ----------------------
CREATE VIEW `view_job_operation_types`
AS select distinct `ja`.`job_id` AS `job_id`,`o`.`operation_type_id` AS `operation_type_id`,`ot`.`name` AS `name`,`ot`.`category` AS `category` from ((`job_associations` `ja` join `operations` `o` on((`o`.`id` = `ja`.`operation_id`))) join `operation_types` `ot` on((`ot`.`id` = `o`.`operation_type_id`)));
-- -------------------------------------------------------------


-- CREATE VIEW "view_job_associations" -------------------------
CREATE VIEW `view_job_associations`
AS select `ja`.`job_id` AS `job_id`,count(0) AS `n` from `job_associations` `ja` group by `ja`.`job_id`;
-- -------------------------------------------------------------


-- CREATE VIEW "view_job_assignment_logs" ----------------------
CREATE VIEW `view_job_assignment_logs`
AS select max(`job_assignment_logs`.`id`) AS `id` from `job_assignment_logs` group by `job_assignment_logs`.`job_id`;
-- -------------------------------------------------------------


-- CREATE VIEW "view_job_assignments" --------------------------
CREATE VIEW `view_job_assignments`
AS select `jal`.`id` AS `id`,`jal`.`job_id` AS `job_id`,`jal`.`assigned_by` AS `assigned_by`,`jal`.`assigned_to` AS `assigned_to`,`jal`.`created_at` AS `created_at`,`jal`.`updated_at` AS `updated_at`,`j`.`pc` AS `pc`,`ub`.`name` AS `by_name`,`ub`.`login` AS `by_login`,`ut`.`name` AS `to_name`,`ut`.`login` AS `to_login` from ((((`job_assignment_logs` `jal` join `view_job_assignment_logs` `vjal` on((`vjal`.`id` = `jal`.`id`))) join `jobs` `j` on((`j`.`id` = `jal`.`job_id`))) join `users` `ub` on((`ub`.`id` = `jal`.`assigned_by`))) join `users` `ut` on((`ut`.`id` = `jal`.`assigned_to`)));
-- -------------------------------------------------------------

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
-- ---------------------------------------------------------


