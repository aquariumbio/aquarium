
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `account_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `row1` int(11) DEFAULT NULL,
  `row2` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `note` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_8e6656e8a4` (`row2`) USING BTREE,
  KEY `index_account_logs_on_row1` (`row1`) USING BTREE,
  KEY `index_account_log_associations_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_0fc0d85f00` FOREIGN KEY (`row1`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_8e6656e8a4` FOREIGN KEY (`row2`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_c91e200913` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1813 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_type` varchar(255) DEFAULT NULL,
  `amount` float(12,0) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text,
  `labor_rate` float(12,0) DEFAULT NULL,
  `markup_rate` float(12,0) DEFAULT NULL,
  `operation_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accounts_on_budget_id` (`budget_id`) USING BTREE,
  KEY `index_accounts_on_job_id` (`job_id`) USING BTREE,
  KEY `index_accounts_on_operation_id` (`operation_id`) USING BTREE,
  KEY `index_accounts_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_17f7ad8fd1` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_9910875b16` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_b1e30bebc8` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_ba2f9f474f` FOREIGN KEY (`operation_id`) REFERENCES `operations` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=409079 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `allowable_field_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `allowable_field_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_type_id` int(11) DEFAULT NULL,
  `sample_type_id` int(11) DEFAULT NULL,
  `object_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_allowable_field_types_on_field_type_id` (`field_type_id`) USING BTREE,
  KEY `index_allowable_field_types_on_object_type_id` (`object_type_id`) USING BTREE,
  KEY `index_allowable_field_types_on_sample_type_id` (`sample_type_id`) USING BTREE,
  CONSTRAINT `fk_rails_1d47761735` FOREIGN KEY (`field_type_id`) REFERENCES `field_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_2bc0f30ee5` FOREIGN KEY (`sample_type_id`) REFERENCES `sample_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_a968b4a54c` FOREIGN KEY (`object_type_id`) REFERENCES `object_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3220 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `message` text,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `overhead` float(12,0) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `content` text,
  `parent_id` int(11) DEFAULT NULL,
  `parent_class` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21157 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `data_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_class` varchar(255) DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL,
  `upload_id` int(11) DEFAULT NULL,
  `object` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_data_associations_on_parent_class_and_parent_id` (`parent_class`,`parent_id`) USING BTREE,
  KEY `index_data_associations_on_upload_id` (`upload_id`) USING BTREE,
  CONSTRAINT `fk_rails_26226b25a9` FOREIGN KEY (`upload_id`) REFERENCES `uploads` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1043508 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `field_type_sorts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_type_sorts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ftype` varchar(255) DEFAULT NULL,
  `sort` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `field_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `ftype` varchar(255) DEFAULT NULL,
  `choices` varchar(255) DEFAULT NULL,
  `array` tinyint(1) DEFAULT NULL,
  `required` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_class` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `part` tinyint(1) DEFAULT NULL,
  `routing` varchar(255) DEFAULT NULL,
  `preferred_operation_type_id` int(11) DEFAULT NULL,
  `preferred_field_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_types_on_parent_class_and_parent_id` (`parent_class`,`parent_id`) USING BTREE,
  KEY `index_field_types_on_sample_type_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=23778 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `field_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `value` text,
  `child_sample_id` int(11) DEFAULT NULL,
  `child_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `parent_class` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `field_type_id` int(11) DEFAULT NULL,
  `row` int(11) DEFAULT NULL,
  `column` int(11) DEFAULT NULL,
  `allowable_field_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_rails_319b222007` (`child_item_id`) USING BTREE,
  KEY `fk_rails_e04e5b0273` (`child_sample_id`) USING BTREE,
  KEY `index_field_values_on_allowable_field_type_id` (`allowable_field_type_id`) USING BTREE,
  KEY `index_field_values_on_field_type_id` (`field_type_id`) USING BTREE,
  KEY `index_field_values_on_parent_class_and_parent_id` (`parent_class`,`parent_id`) USING BTREE,
  KEY `index_field_values_on_sample_id` (`parent_id`) USING BTREE,
  CONSTRAINT `fk_rails_212ef5a639` FOREIGN KEY (`field_type_id`) REFERENCES `field_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_319b222007` FOREIGN KEY (`child_item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_50fa557e81` FOREIGN KEY (`allowable_field_type_id`) REFERENCES `allowable_field_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_e04e5b0273` FOREIGN KEY (`child_sample_id`) REFERENCES `samples` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1241869 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `folder_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `folder_id` int(11) DEFAULT NULL,
  `workflow_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=369 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `id_strings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `id_strings` (
  `id` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `year` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  KEY `index_invoices_on_budget_id` (`budget_id`) USING BTREE,
  KEY `index_invoices_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_3d1522a0d8` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_3dd4c64f3b` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1733 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(255) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `object_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `inuse` int(11) DEFAULT '0',
  `sample_id` int(11) DEFAULT NULL,
  `data` mediumtext,
  `locator_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_items_on_locator_id` (`locator_id`) USING BTREE,
  KEY `index_items_on_object_type_id` (`object_type_id`) USING BTREE,
  KEY `index_items_on_sample_id` (`sample_id`) USING BTREE,
  CONSTRAINT `fk_rails_6b7d1f696e` FOREIGN KEY (`sample_id`) REFERENCES `samples` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_a6ef7e6462` FOREIGN KEY (`object_type_id`) REFERENCES `object_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_d02c2a2df1` FOREIGN KEY (`locator_id`) REFERENCES `locators` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=513655 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `job_assignment_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_assignment_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `assigned_by` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_job_assignment_logs_on_assigned_by` (`assigned_by`) USING BTREE,
  KEY `index_job_assignment_logs_on_assigned_to` (`assigned_to`) USING BTREE,
  KEY `index_job_assignment_logs_on_job_id` (`job_id`) USING BTREE,
  CONSTRAINT `fk_rails_3c67081d23` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_afd4527da7` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_cec96ca499` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `job_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `operation_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_job_associations_on_job_id` (`job_id`) USING BTREE,
  KEY `index_job_associations_on_operation_id` (`operation_id`) USING BTREE,
  CONSTRAINT `fk_rails_25efd65a81` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_8f590b1e09` FOREIGN KEY (`operation_id`) REFERENCES `operations` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=200908 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `arguments` text,
  `state` longtext,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `path` varchar(255) DEFAULT NULL,
  `pc` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `submitted_by` int(11) DEFAULT NULL,
  `desired_start_time` datetime DEFAULT NULL,
  `latest_start_time` datetime DEFAULT NULL,
  `metacol_id` int(11) DEFAULT NULL,
  `successor_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_jobs_on_group_id` (`group_id`) USING BTREE,
  KEY `index_jobs_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_4928288085` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_df6238c8a6` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=124651 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `libraries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=212 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `locators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wizard_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locators_on_item_id` (`item_id`) USING BTREE,
  KEY `index_locators_on_wizard_id` (`wizard_id`) USING BTREE,
  CONSTRAINT `fk_rails_64c3d29cac` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rails_bb120b6235` FOREIGN KEY (`wizard_id`) REFERENCES `wizards` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=72995 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `entry_type` varchar(255) DEFAULT NULL,
  `data` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_logs_on_job_id` (`job_id`) USING BTREE,
  KEY `index_logs_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_81ff90ed92` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_8fc980bf44` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=147772 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_memberships_on_group_id` (`group_id`) USING BTREE,
  KEY `index_memberships_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_99326fb65d` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_aaf389f138` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=854 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `object_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `min` int(11) DEFAULT NULL,
  `max` int(11) DEFAULT NULL,
  `handler` varchar(255) DEFAULT NULL,
  `safety` text,
  `cleanup` text,
  `data` text,
  `vendor` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `cost` float(12,0) DEFAULT NULL,
  `release_method` varchar(255) DEFAULT NULL,
  `release_description` text,
  `sample_type_id` int(11) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `prefix` varchar(255) DEFAULT NULL,
  `rows` int(11) DEFAULT NULL,
  `columns` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=866 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `operation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `deployed` tinyint(1) DEFAULT NULL,
  `on_the_fly` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_operation_types_on_category_and_name` (`category`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=752 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operation_type_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `x` float(12,0) DEFAULT NULL,
  `y` float(12,0) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_operations_on_operation_type_id` (`operation_type_id`) USING BTREE,
  KEY `index_operations_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_10e3ccbd52` FOREIGN KEY (`operation_type_id`) REFERENCES `operation_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_63fbf4e94e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=346267 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1190 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `parameters_bak`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameters_bak` (
  `id` int(11) NOT NULL DEFAULT '0',
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `part_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `part_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `part_id` int(11) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `row` int(11) DEFAULT NULL,
  `column` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_part_associations_on_collection_id_and_row_and_column` (`collection_id`,`row`,`column`),
  KEY `index_part_associations_on_part_id` (`part_id`) USING BTREE,
  CONSTRAINT `fk_rails_39a9c3d5bb` FOREIGN KEY (`part_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_f889cf647d` FOREIGN KEY (`collection_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=240065 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `sort` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_permissions_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `plan_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_id` int(11) DEFAULT NULL,
  `operation_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_plan_associations_on_operation_id` (`operation_id`) USING BTREE,
  KEY `index_plan_associations_on_plan_id` (`plan_id`) USING BTREE,
  CONSTRAINT `fk_rails_5ca5742cd9` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_c36597dd79` FOREIGN KEY (`operation_id`) REFERENCES `operations` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=331928 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `cost_limit` float(12,0) DEFAULT NULL,
  `folder` varchar(255) DEFAULT NULL,
  `layout` text,
  PRIMARY KEY (`id`),
  KEY `index_plans_on_budget_id` (`budget_id`) USING BTREE,
  KEY `index_plans_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_45da853770` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_55f7cff6c3` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=40912 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sample_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `sample_type_id` int(11) DEFAULT NULL,
  `project` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `data` text,
  `search_text` text,
  `item_ids` text,
  PRIMARY KEY (`id`),
  KEY `index_samples_on_sample_type_id` (`sample_type_id`) USING BTREE,
  KEY `index_samples_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_8e0800c2e2` FOREIGN KEY (`sample_type_id`) REFERENCES `sample_types` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_d699eb2564` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=36429 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `timings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_class` varchar(255) DEFAULT NULL,
  `days` varchar(255) DEFAULT NULL,
  `start` int(11) DEFAULT NULL,
  `stop` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_timings_on_parent_class_and_parent_id` (`parent_class`,`parent_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `upload_file_name` varchar(255) DEFAULT NULL,
  `upload_content_type` varchar(255) DEFAULT NULL,
  `upload_file_size` int(11) DEFAULT NULL,
  `upload_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_uploads_on_job_id` (`job_id`) USING BTREE,
  CONSTRAINT `fk_rails_76093eb5d3` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=46467 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_budget_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_budget_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `quota` float(12,0) DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_budget_associations_on_budget_id` (`budget_id`) USING BTREE,
  KEY `index_user_budget_associations_on_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `fk_rails_a2966bc54b` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_f1322363b9` FOREIGN KEY (`budget_id`) REFERENCES `budgets` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=409 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_profiles_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_87a6352e58` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1808 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_tokens` (
  `user_id` int(11) NOT NULL,
  `token` varchar(128) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `ip` varchar(18) NOT NULL,
  `timenow` datetime NOT NULL,
  PRIMARY KEY (`ip`,`token`),
  KEY `fk_rails_e0a9c15abb` (`user_id`),
  CONSTRAINT `fk_rails_e0a9c15abb` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `login` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `password_digest` varchar(255) DEFAULT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `key` varchar(255) DEFAULT NULL,
  `permission_ids` varchar(255) DEFAULT '.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `index_users_on_remember_token` (`remember_token`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=345 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `view_inventories`;
/*!50001 DROP VIEW IF EXISTS `view_inventories`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_inventories` (
  `id` tinyint NOT NULL,
  `item_id` tinyint NOT NULL,
  `item_location` tinyint NOT NULL,
  `item_date` tinyint NOT NULL,
  `item_type_id` tinyint NOT NULL,
  `item_type` tinyint NOT NULL,
  `collection_id` tinyint NOT NULL,
  `row` tinyint NOT NULL,
  `column` tinyint NOT NULL,
  `collection_location` tinyint NOT NULL,
  `collection_date` tinyint NOT NULL,
  `collection_type_id` tinyint NOT NULL,
  `collection_type` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `view_job_assignments`;
/*!50001 DROP VIEW IF EXISTS `view_job_assignments`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_job_assignments` (
  `id` tinyint NOT NULL,
  `job_id` tinyint NOT NULL,
  `assigned_by` tinyint NOT NULL,
  `assigned_to` tinyint NOT NULL,
  `created_at` tinyint NOT NULL,
  `updated_at` tinyint NOT NULL,
  `pc` tinyint NOT NULL,
  `by_name` tinyint NOT NULL,
  `by_login` tinyint NOT NULL,
  `to_name` tinyint NOT NULL,
  `to_login` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `view_job_associations`;
/*!50001 DROP VIEW IF EXISTS `view_job_associations`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_job_associations` (
  `job_id` tinyint NOT NULL,
  `n` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `view_job_operation_types`;
/*!50001 DROP VIEW IF EXISTS `view_job_operation_types`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_job_operation_types` (
  `job_id` tinyint NOT NULL,
  `pc` tinyint NOT NULL,
  `created_at` tinyint NOT NULL,
  `updated_at` tinyint NOT NULL,
  `operation_type_id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `category` tinyint NOT NULL,
  `deployed` tinyint NOT NULL,
  `id` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `view_samples`;
/*!50001 DROP VIEW IF EXISTS `view_samples`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_samples` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `project` tinyint NOT NULL,
  `created_at` tinyint NOT NULL,
  `item_ids` tinyint NOT NULL,
  `sample_type_id` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `user_name` tinyint NOT NULL,
  `login` tinyint NOT NULL,
  `ft_id` tinyint NOT NULL,
  `ft_type` tinyint NOT NULL,
  `ft_sort` tinyint NOT NULL,
  `ft_name` tinyint NOT NULL,
  `fv_id` tinyint NOT NULL,
  `fv_value` tinyint NOT NULL,
  `child_sample_id` tinyint NOT NULL,
  `child_sample_name` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `view_samples_`;
/*!50001 DROP VIEW IF EXISTS `view_samples_`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_samples_` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `description` tinyint NOT NULL,
  `created_at` tinyint NOT NULL,
  `item_ids` tinyint NOT NULL,
  `sample_type_id` tinyint NOT NULL,
  `sample_type` tinyint NOT NULL,
  `user_name` tinyint NOT NULL,
  `login` tinyint NOT NULL,
  `ft_id` tinyint NOT NULL,
  `ft_type` tinyint NOT NULL,
  `ft_sort` tinyint NOT NULL,
  `ft_name` tinyint NOT NULL,
  `fv_id` tinyint NOT NULL,
  `fv_value` tinyint NOT NULL,
  `child_sample_id` tinyint NOT NULL,
  `child_sample_name` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `view_users`;
/*!50001 DROP VIEW IF EXISTS `view_users`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `view_users` (
  `id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `login` tinyint NOT NULL,
  `permission_ids` tinyint NOT NULL,
  `email` tinyint NOT NULL,
  `phone` tinyint NOT NULL,
  `lab_agreement` tinyint NOT NULL,
  `aquarium_agreement` tinyint NOT NULL,
  `new_samples_private` tinyint NOT NULL,
  `lab_name` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `wires`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from_id` int(11) DEFAULT NULL,
  `to_id` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wires_on_from_id` (`from_id`) USING BTREE,
  KEY `index_wires_on_to_id` (`to_id`) USING BTREE,
  CONSTRAINT `fk_rails_1073ab769d` FOREIGN KEY (`to_id`) REFERENCES `field_values` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_rails_684cde68aa` FOREIGN KEY (`from_id`) REFERENCES `field_values` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=268234 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `wizards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wizards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `specification` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `workers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50001 DROP TABLE IF EXISTS `view_inventories`*/;
/*!50001 DROP VIEW IF EXISTS `view_inventories`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_inventories` AS select `s`.`id` AS `id`,`i`.`id` AS `item_id`,`i`.`location` AS `item_location`,`i`.`created_at` AS `item_date`,`ot`.`id` AS `item_type_id`,`ot`.`name` AS `item_type`,`pa`.`collection_id` AS `collection_id`,`pa`.`row` AS `row`,`pa`.`column` AS `column`,`ii`.`location` AS `collection_location`,`ii`.`created_at` AS `collection_date`,`ott`.`id` AS `collection_type_id`,`ott`.`name` AS `collection_type` from (((((`samples` `s` join `items` `i` on((`i`.`sample_id` = `s`.`id`))) join `object_types` `ot` on(((`ot`.`id` = `i`.`object_type_id`) and (`ot`.`handler` = 'sample_container')))) left join `part_associations` `pa` on((`pa`.`part_id` = `i`.`id`))) left join `items` `ii` on((`ii`.`id` = `pa`.`collection_id`))) left join `object_types` `ott` on((`ott`.`id` = `ii`.`object_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_job_assignments`*/;
/*!50001 DROP VIEW IF EXISTS `view_job_assignments`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_job_assignments` AS select `jal`.`id` AS `id`,`jal`.`job_id` AS `job_id`,`jal`.`assigned_by` AS `assigned_by`,`jal`.`assigned_to` AS `assigned_to`,`jal`.`created_at` AS `created_at`,`jal`.`updated_at` AS `updated_at`,`j`.`pc` AS `pc`,`ub`.`name` AS `by_name`,`ub`.`login` AS `by_login`,`ut`.`name` AS `to_name`,`ut`.`login` AS `to_login` from ((((`aquarium_development`.`job_assignment_logs` `jal` join (select max(`aquarium_development`.`job_assignment_logs`.`id`) AS `id` from `aquarium_development`.`job_assignment_logs` group by `aquarium_development`.`job_assignment_logs`.`job_id`) `ij` on((`ij`.`id` = `jal`.`id`))) join `aquarium_development`.`jobs` `j` on((`j`.`id` = `jal`.`job_id`))) join `aquarium_development`.`users` `ub` on((`ub`.`id` = `jal`.`assigned_by`))) join `aquarium_development`.`users` `ut` on((`ut`.`id` = `jal`.`assigned_to`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_job_associations`*/;
/*!50001 DROP VIEW IF EXISTS `view_job_associations`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_job_associations` AS select `ja`.`job_id` AS `job_id`,count(0) AS `n` from `job_associations` `ja` group by `ja`.`job_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_job_operation_types`*/;
/*!50001 DROP VIEW IF EXISTS `view_job_operation_types`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_job_operation_types` AS select distinct `j`.`id` AS `job_id`,`j`.`pc` AS `pc`,`j`.`created_at` AS `created_at`,`j`.`updated_at` AS `updated_at`,`ot`.`id` AS `operation_type_id`,`ot`.`name` AS `name`,`ot`.`category` AS `category`,`ot`.`deployed` AS `deployed`,concat(`j`.`id`,'-',`ot`.`id`) AS `id` from (((`jobs` `j` join `job_associations` `ja` on((`ja`.`job_id` = `j`.`id`))) join `operations` `o` on((`o`.`id` = `ja`.`operation_id`))) join `operation_types` `ot` on((`ot`.`id` = `o`.`operation_type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_samples`*/;
/*!50001 DROP VIEW IF EXISTS `view_samples`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_samples` AS select `s`.`id` AS `id`,`s`.`name` AS `name`,`s`.`description` AS `description`,`s`.`project` AS `project`,`s`.`created_at` AS `created_at`,`s`.`item_ids` AS `item_ids`,`s`.`sample_type_id` AS `sample_type_id`,`st`.`name` AS `sample_type`,`u`.`name` AS `user_name`,`u`.`login` AS `login`,`ft`.`id` AS `ft_id`,`ft`.`ftype` AS `ft_type`,`fts`.`sort` AS `ft_sort`,`ft`.`name` AS `ft_name`,`fv`.`id` AS `fv_id`,`fv`.`value` AS `fv_value`,`fv`.`child_sample_id` AS `child_sample_id`,`ss`.`name` AS `child_sample_name` from ((((((`samples` `s` join `sample_types` `st` on((`st`.`id` = `s`.`sample_type_id`))) join `users` `u` on((`u`.`id` = `s`.`user_id`))) left join `field_types` `ft` on(((`ft`.`parent_id` = `s`.`sample_type_id`) and (`ft`.`parent_class` = 'SampleType')))) left join `field_type_sorts` `fts` on((`fts`.`ftype` = `ft`.`ftype`))) left join `field_values` `fv` on(((`fv`.`parent_id` = `s`.`id`) and (`fv`.`parent_class` = 'Sample') and (`fv`.`field_type_id` = `ft`.`id`)))) left join `samples` `ss` on((`ss`.`id` = `fv`.`child_sample_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_samples_`*/;
/*!50001 DROP VIEW IF EXISTS `view_samples_`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_samples_` AS select `s`.`id` AS `id`,`s`.`name` AS `name`,`s`.`description` AS `description`,`s`.`created_at` AS `created_at`,`s`.`item_ids` AS `item_ids`,`s`.`sample_type_id` AS `sample_type_id`,`st`.`name` AS `sample_type`,`u`.`name` AS `user_name`,`u`.`login` AS `login`,`ft`.`id` AS `ft_id`,`ft`.`ftype` AS `ft_type`,`fts`.`sort` AS `ft_sort`,`ft`.`name` AS `ft_name`,`fv`.`id` AS `fv_id`,`fv`.`value` AS `fv_value`,`fv`.`child_sample_id` AS `child_sample_id`,`ss`.`name` AS `child_sample_name` from ((((((`samples` `s` join `sample_types` `st` on((`st`.`id` = `s`.`sample_type_id`))) join `users` `u` on((`u`.`id` = `s`.`user_id`))) left join `field_types` `ft` on(((`ft`.`parent_id` = `s`.`sample_type_id`) and (`ft`.`parent_class` = 'SampleType')))) left join `field_type_sorts` `fts` on((`fts`.`ftype` = `ft`.`ftype`))) left join `field_values` `fv` on(((`fv`.`parent_id` = `s`.`id`) and (`fv`.`parent_class` = 'Sample') and (`fv`.`field_type_id` = `ft`.`id`)))) left join `samples` `ss` on((`ss`.`id` = `fv`.`child_sample_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP TABLE IF EXISTS `view_users`*/;
/*!50001 DROP VIEW IF EXISTS `view_users`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aquarium`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_users` AS select `u`.`id` AS `id`,`u`.`name` AS `name`,`u`.`login` AS `login`,`u`.`permission_ids` AS `permission_ids`,`up_email`.`value` AS `email`,`up_phone`.`value` AS `phone`,`up_lab`.`value` AS `lab_agreement`,`up_aquarium`.`value` AS `aquarium_agreement`,`up_private`.`value` AS `new_samples_private`,`up_labname`.`value` AS `lab_name` from ((((((`users` `u` left join `user_profiles` `up_email` on(((`up_email`.`user_id` = `u`.`id`) and (`up_email`.`key` = 'email')))) left join `user_profiles` `up_phone` on(((`up_phone`.`user_id` = `u`.`id`) and (`up_phone`.`key` = 'phone')))) left join `user_profiles` `up_lab` on(((`up_lab`.`user_id` = `u`.`id`) and (`up_lab`.`key` = 'lab_agreement')))) left join `user_profiles` `up_aquarium` on(((`up_aquarium`.`user_id` = `u`.`id`) and (`up_aquarium`.`key` = 'aquarium_agreement')))) left join `user_profiles` `up_private` on(((`up_private`.`user_id` = `u`.`id`) and (`up_private`.`key` = 'new_samples_private')))) left join `user_profiles` `up_labname` on(((`up_labname`.`user_id` = `u`.`id`) and (`up_labname`.`key` = 'lab_name')))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20201030000000'),
('20201218000000'),
('20201218000010'),
('20210301000000'),
('20210301000010'),
('20210301000020'),
('20210601000000'),
('20210601000010');


