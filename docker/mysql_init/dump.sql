-- MySQL dump 10.13  Distrib 5.7.29, for Linux (x86_64)
--
-- Host: localhost    Database: production
-- ------------------------------------------------------
-- Server version	5.7.29

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

--
-- Table structure for table `account_logs`
--

DROP TABLE IF EXISTS `account_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `row1` int(11) DEFAULT NULL,
  `row2` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_account_log_associations_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_logs`
--

LOCK TABLES `account_logs` WRITE;
/*!40000 ALTER TABLE `account_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `labor_rate` float DEFAULT NULL,
  `markup_rate` float DEFAULT NULL,
  `operation_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accounts_on_budget_id` (`budget_id`),
  KEY `index_accounts_on_job_id` (`job_id`),
  KEY `index_accounts_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `allowable_field_types`
--

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
  KEY `index_allowable_field_types_on_field_type_id` (`field_type_id`),
  KEY `index_allowable_field_types_on_object_type_id` (`object_type_id`),
  KEY `index_allowable_field_types_on_sample_type_id` (`sample_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allowable_field_types`
--

LOCK TABLES `allowable_field_types` WRITE;
/*!40000 ALTER TABLE `allowable_field_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `allowable_field_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (1,'Welcome to Aquarium','If you are just starting Aquarium for the first time, you may need to add some content. Go to http://www.aquarium.bio/ and click on COMMUNITY and then Workflows to find protocols and workflows you can add to this instance of Aquarium. Enjoy!',1,'2018-12-21 17:58:04','2018-12-21 17:58:27');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `budgets`
--

DROP TABLE IF EXISTS `budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `overhead` float DEFAULT NULL,
  `contact` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `budgets`
--

LOCK TABLES `budgets` WRITE;
/*!40000 ALTER TABLE `budgets` DISABLE KEYS */;
INSERT INTO `budgets` VALUES (1,'My First Budget',NULL,'Joe','2018-07-17 22:10:05','2018-07-17 22:10:05','An example budget','joe@nasa.org','8675309');
/*!40000 ALTER TABLE `budgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `codes`
--

DROP TABLE IF EXISTS `codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `parent_id` int(11) DEFAULT NULL,
  `parent_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `codes`
--

LOCK TABLES `codes` WRITE;
/*!40000 ALTER TABLE `codes` DISABLE KEYS */;
INSERT INTO `codes` VALUES (1,'protocol','# Title: Inventory Purchase Protocol\n# Author: Eric Klavins\n# Date: May 31, 2016 \n\nneeds \"Standard Libs/Debug\"\n\nclass Protocol\n\n  include Debug\n\n  def labor_rate\n    Parameter.get_float(\'labor rate\')\n  end\n  \n  def main\n    if !operations.one?\n      show do\n        title \"Too many batched!\"\n        \n        note \"Right now, this protocol only supports one Direct Purchase at a time. Please re-batch in jobs of one.\"\n      end\n      \n      return {}\n    end\n    \n    \n    @object_types = ObjectType.all\n    @user = operations.first.user\n    user = @user # Can\'t put @user in show, because it would refer to the wrong object\n\n    result = show do\n      title \"Choose a budget\"\n      note \"User: #{user.name} (#{user.login})\"\n      select user.budget_info.collect { |bi| bi[:budget].name }, var: \"choice\", label: \"Choose a budget\", default: 0\n    end\n    \n    @budget = Budget.find_by_name(result[:choice])\n    @overhead = Parameter.get_float(\"markup rate\")\n    @transactions = []\n    \n    operations.first.plan.budget_id = @budget.id\n    operations.first.plan.save \n    \n    again = true\n    \n    while again \n    \n      result = show do\n        title \"Select Category\"\n        note \"Basics: tubes, tip boxes, ...\"\n        note \"Samples: media, ...\"\n        note \"Batched: Gibson Aliquots, plates, ...\"\n        select [ \"Basics\", \"Samples\", \"Batched\" ], var: \"choice\", label: \"Choose something\", default: 1\n      end\n      \n      case result[:choice]\n        when \"Basics\"then basic_chooser\n        when \"Samples\" then sample_chooser \n        when \"Batched\" then batched_chooser\n      end\n      \n      tab = [ [ \"Description\", \"Amount\" ] ]\n      tab += @transactions.collect do |t| \n        [\n          t[:description],\n          currency((1 + @overhead) * t[:amount])\n        ]\n      end\n      \n      result = show do\n        title  \"Summary\"\n        table tab if tab.length > 1 \n        note \"No purchases made\" unless tab.length > 1\n        select [ \"No\", \"Yes\" ], var: \"again\", label: \"Would you like to make another purchase?\", default: 0\n      end\n    \n      again = ( result[:again] == \"Yes\" )\n      \n    end\n    \n    operations.first.associate :transactions, @transactions\n    \n    return {}\n   end\n\n  def choose_object_from objects, number=false\n    result = show do\n      title \"Choose Object\"\n      select objects.collect { |ot| ot.name }, var: \"choice\", label: \"Choose object:\", default: 0\n      get \"number\", var: \"n\", label: \"How many?\", default: 5 if number\n    end\n\n    return objects.find { |b| b.name == result[:choice] } unless number\n    return [ objects.find { |b| b.name == result[:choice] }, result[:n] ] if number\n  end\n  \n  ###############################################################################################################\n  def basic_chooser \n    \n    basics = @object_types.select { |ot| basic? ot }      \n    ot = choose_object_from basics\n\n    error \"There seems to be a problem with the object you\'ve chosen.\" if ot.nil?\n\n    vol = {}\n  \n    m = ot.data_object[:materials]\n    l = ot.data_object[:labor]\n    u = ot.data_object[:unit] \n    vol[:n] = 1\n \n    vol = show do\n      title \"Choose Amount\"\n      get \"number\", var: \"n\", label: \"How many #{u.pluralize} of #{ot.name}?\", default: 5\n    end\n\n    message = \"Purchase #{vol[:n]} #{ot.name.pluralize}\"\n    if confirm message, currency((1+@overhead) * ((m* vol[:n])+(l * labor_rate* vol[:n])) ) \n      transaction = make_purchase message, m*vol[:n], l*vol[:n]\n    end        \n    \n  end\n\n  ###############################################################################################################\n  def sample_chooser \n   \n    samples = @object_types.select { |ot| sample? ot }   \n    ot = choose_object_from samples\n\n    error \"There seems to be a problem with the object you\'ve chosen.\" if ot.nil?\n\n    result = show do\n      title \"Choose Sample\"\n      select ot.data_object[:samples].collect { |s| s[:name] }, var: \"choice\", label: \"Choose sample\", default: 2\n    end\n    \n    descriptor = ot.data_object[:samples].find { |d| d[:name] == result[:choice] }\n    m = descriptor[:materials]\n    l = descriptor[:labor] \n    u = descriptor[:unit]\n    s = descriptor[:name] \n    vol = {}\n\n    items = Sample.find_by_name(s).items.reject { |i| i.deleted? }.reject {|i| i.object_type.name != ot.name }\n    \n    if items.length > 0\n      item = choose_item items, \"Choose #{ot.name} of #{s}\"\n\n      if ot.name.include?(\"Agar\")\n        vol[:n] = descriptor[:total_volume]\n      else\n        vol = show do\n          title \"Choose Volume\"\n          get \"number\", var: \"n\", label: \"How many #{u.pluralize} of #{s}?\", default: 5 \n          select [\"No\", \"Yes\"], var: \"delete\", label: \"Are you purchasing the whole container or is the container now empty?\", default: 0\n        end\n      end\n\n\n      cost = currency((1+@overhead)*((m* vol[:n])+(l * labor_rate* vol[:n]))) \n      message = \"Purchase #{ot.name} of #{s}, item #{item.id}\"\n      if confirm message, cost\n        take [item]\n        transaction = make_purchase message, m*vol[:n], l*vol[:n]\n        release [item]\n        if (descriptor[:delete] || vol[:delete] == \"Yes\")\n          item.mark_as_deleted\n        end\n      end\n    else\n      error \"There are no items of #{ot.name}/#{s} in stock\"\n    end \n  end    \n  ###############################################################################################################\n  def batched_chooser \n\n    collections = @object_types.select { |ot| batched? ot }\n    ot = choose_object_from collections\n\n    error \"There seems to be a problem with the object you\'ve chosen.\" if ot.nil?\n  \n    result = show do\n      title \"Choose sample type\" \n      select ot.data_object[:samples].collect { |s| s[:name] }, var: \"choice\", label: \"Choose sample\", default: 0\n    end\n  \n    descriptor = ot.data_object[:samples].find { |d| d[:name] == result[:choice] }\n    m = descriptor[:materials]\n    l = descriptor[:labor] \n    cost = currency((1+@overhead)*(m+(l*labor_rate)))\n  \n    s = Sample.find_by_name(descriptor[:name])\n    collections = ot.items.reject { |i| i.deleted? }.collect { |i| collection_from i }\n    # filter out collections based on user\'s sample input\n    collections.reject! { |c| c.matrix[0][0] != s.id }\n    cids = collections.collect { |c| c.id.to_s }\n  \n    if cids.length > 0\n  \n      result = show do \n        title \"Choose #{ot.name} and number of #{s.name.pluralize} (#{cost} each)\"\n        table [ [ \"id\", \"Location\", \"Number of Samples\" ] ] + (collections.collect { |i| [ \"#{i}\", i.location, i.num_samples ] } )\n        select cids, var: \"id\", label: \"Choose collection\", default: 0\n        get \"number\", var: \"n\", label: \"How many #{s.name.pluralize}?\", default: 2\n      end\n      \n      collection = collections.find { |c| c.id == result[:id].to_i }\n      \n      n = [ collection.num_samples, [ 1, result[:n]].max ].min\n      total_cost = currency((1+@overhead)*(n*m+(n*l* labor_rate)))\n      message = \"Purchase #{n} #{s.name.pluralize} from #{ot.name} #{collection.id}\"\n      \n      if confirm message, total_cost \n        take_samples collection, n\n        transaction = make_purchase message, n*m, n*l\n        release [collection]\n        if collection.num_samples == 0\n          collection.mark_as_deleted\n        end\n      end    \n    else\n      error \"There are no #{ot.name} in stock\"\n    end\n  end\n\n  def take_samples collection, n\n   \n    m = collection.matrix\n    x = 0\n  \n    (0..m.length-1).reverse_each do |i|\n      (0..m[i].length-1).reverse_each do |j|\n        if m[i][j] != -1 && x < n\n          m[i][j] = -1\n          x += 1\n        end\n      end\n    end\n  \n    collection.matrix = m\n    collection.save\n    take [collection]\n    \n  end\n\n  def error msg, details=nil\n    show do \n      title msg\n      note details if details\n      note \"Please report this problem to a BIOFAB lab manager.\"\n    end      \n  end\n\n  def confirm message, cost\n    result = show do \n      title message\n      note \"Cost: #{cost}\"\n      select [ \"Ok\", \"Cancel\" ], var: \"choice\", label: \"Ok to purchase?\", default: 0\n    end\n    return (result[:choice] == \"Ok\")\n  end\n\n  def choose_item items, message\n    options = (items.collect { |i| i.id.to_s })\n    result = show do \n      title message\n      note \"Please choose which item you would like to use: \"\n      select options, var: \"choice\", label: \"Choose item\", default: 0\n    end\n    Item.find(result[:choice])          \n  end\n\n\n  def make_purchase description, mat, lab\n    transaction = {\n      description: description,\n      amount: mat + lab * labor_rate,\n    }\n    \n    @transactions << transaction\n    \n    transaction\n  end\n\n  def valid_sample_descriptor s\n    val = s[:name]      && s[:name].class == String &&\n          s[:materials] && ( s[:materials].class == Float || s[:materials].class == Fixnum ) &&\n          s[:labor]     && ( s[:labor].class == Float     || s[:labor].class == Fixnum ) && \n          s[:unit]      && s[:unit].class == String &&\n          s[:total_volume] && (s[:total_volume].is_a?(Integer))\n    #error(\"Bad descriptor\", s.to_s) unless val #comment this out so user doesn\'t see it\n    val\n  end\n\n  def basic? ot\n    ot.handler != \"sample_container\" && ot.handler != \"collection\"  &&\n    ot.data_object[:materials] && ot.data_object[:labor] && ot.data_object[:unit]     \n  end\n\n  def sample? ot\n    ot.handler == \"sample_container\" && ot.data_object[:samples] && \n    ot.data_object[:samples].each { |s| return nil unless valid_sample_descriptor s }\n  end\n\n  def batched? ot\n    ot.handler == \"collection\" && ot.data_object[:samples] && \n    ot.data_object[:samples].each { |s| return nil unless (s[:materials] && s[:labor] && s[:unit]) }\n  end\n\n  def currency num\n    ActionController::Base.helpers.number_to_currency num\n  end  \n\nend\n',1,'OperationType','2020-01-24 16:50:00','2020-01-24 16:50:00',1),(2,'precondition','def precondition(op)\n  true\nend',1,'OperationType','2020-01-24 16:50:00','2020-01-24 16:50:00',1),(3,'cost_model','def cost(op)\n  trans = op.get(:transactions) || [{ amount: 0.1 }]\n  total_cost = trans.map { |t| t[:amount] }.sum\n  \n  { labor: 0, materials: total_cost }\nend',1,'OperationType','2020-01-24 16:50:00','2020-01-24 16:50:00',1),(4,'documentation','Documentation here. Start with a paragraph, not a heading or title, as in most views, the title will be supplied by the view.',1,'OperationType','2020-01-24 16:50:00','2020-01-24 16:50:00',1),(5,'test','',1,'OperationType','2020-01-24 16:50:00','2020-01-24 16:50:00',1),(6,'source','module Debug\n  def print_object obj\n    if [Numeric, String].any? { |c| obj.is_a? c }\n      obj\n    elsif [Array].any? { |c| obj.is_a? c }\n      obj.map { |item| print_object item }\n    elsif [Hash].any? { |c| obj.is_a? c }\n      Hash[obj.map { |k, v| [k, print_object(v)] }]\n    else\n      s = obj ? obj.id.to_s : \"\"\n      s += \" #{obj.name}\" if obj.class.method_defined? :name\n      s\n    end\n  end\n\n  def log_info *args\n    if debug\n      show do\n        title \"Debug slide (#{args.length} #{\"arg\".pluralize args.length})\"\n\n        args.each do |arg|\n          note \"#{arg.class}: #{print_object arg}\"\n        end\n      end\n    end\n  end\n\n    def inspect(object, ident=nil)\n        show do\n            title \"<span style=\\\"background-color:yellow\\\">INSPECTING #{ident} (#{object.class})</span>\"\n            if object.kind_of?(Array)\n              table object\n            else\n              note object.to_json\n            end\n        end\n    end\nend\n',1,'Library','2020-01-24 16:50:00','2020-01-24 16:50:00',1);
/*!40000 ALTER TABLE `codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `data_associations`
--

DROP TABLE IF EXISTS `data_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `upload_id` int(11) DEFAULT NULL,
  `object` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_data_associations_on_upload_id` (`upload_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data_associations`
--

LOCK TABLES `data_associations` WRITE;
/*!40000 ALTER TABLE `data_associations` DISABLE KEYS */;
/*!40000 ALTER TABLE `data_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_types`
--

DROP TABLE IF EXISTS `field_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ftype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `choices` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `array` tinyint(1) DEFAULT NULL,
  `required` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `parent_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `part` tinyint(1) DEFAULT NULL,
  `routing` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `preferred_operation_type_id` int(11) DEFAULT NULL,
  `preferred_field_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_types_on_sample_type_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_types`
--

LOCK TABLES `field_types` WRITE;
/*!40000 ALTER TABLE `field_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_values`
--

DROP TABLE IF EXISTS `field_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `child_sample_id` int(11) DEFAULT NULL,
  `child_item_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `field_type_id` int(11) DEFAULT NULL,
  `row` int(11) DEFAULT NULL,
  `column` int(11) DEFAULT NULL,
  `allowable_field_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_field_values_on_allowable_field_type_id` (`allowable_field_type_id`),
  KEY `index_field_values_on_field_type_id` (`field_type_id`),
  KEY `index_field_values_on_sample_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_values`
--

LOCK TABLES `field_values` WRITE;
/*!40000 ALTER TABLE `field_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
INSERT INTO `groups` VALUES (1,'admin','These users can use administrative functions (make users, etc)','2013-11-15 21:37:36','2013-11-15 21:37:36'),(235,'technicians','People who run jobs','2017-10-02 17:50:56','2017-10-02 17:50:56'),(236,'neptune','','2018-07-25 16:22:30','2018-07-25 16:22:30');
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

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
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `object_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `inuse` int(11) DEFAULT '0',
  `sample_id` int(11) DEFAULT NULL,
  `data` mediumtext COLLATE utf8_unicode_ci,
  `locator_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_items_on_object_type_id` (`object_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_associations`
--

DROP TABLE IF EXISTS `job_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `operation_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_associations`
--

LOCK TABLES `job_associations` WRITE;
/*!40000 ALTER TABLE `job_associations` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `arguments` text COLLATE utf8_unicode_ci,
  `state` longtext COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pc` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `submitted_by` int(11) DEFAULT NULL,
  `desired_start_time` datetime DEFAULT NULL,
  `latest_start_time` datetime DEFAULT NULL,
  `metacol_id` int(11) DEFAULT NULL,
  `successor_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libraries`
--

DROP TABLE IF EXISTS `libraries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `libraries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libraries`
--

LOCK TABLES `libraries` WRITE;
/*!40000 ALTER TABLE `libraries` DISABLE KEYS */;
INSERT INTO `libraries` VALUES (1,'Debug','Standard Libs','2020-01-24 16:50:00','2020-01-24 16:50:00');
/*!40000 ALTER TABLE `libraries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locators`
--

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locators`
--

LOCK TABLES `locators` WRITE;
/*!40000 ALTER TABLE `locators` DISABLE KEYS */;
/*!40000 ALTER TABLE `locators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `user_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entry_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memberships`
--

DROP TABLE IF EXISTS `memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=543 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memberships`
--

LOCK TABLES `memberships` WRITE;
/*!40000 ALTER TABLE `memberships` DISABLE KEYS */;
INSERT INTO `memberships` VALUES (541,1,1,'2017-10-02 16:21:25','2017-10-02 16:21:25'),(542,1,235,'2017-10-02 17:50:59','2017-10-02 17:50:59');
/*!40000 ALTER TABLE `memberships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_types`
--

DROP TABLE IF EXISTS `object_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `min` int(11) DEFAULT NULL,
  `max` int(11) DEFAULT NULL,
  `handler` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `safety` text COLLATE utf8_unicode_ci,
  `cleanup` text COLLATE utf8_unicode_ci,
  `data` text COLLATE utf8_unicode_ci,
  `vendor` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `unit` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cost` float DEFAULT NULL,
  `release_method` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `release_description` text COLLATE utf8_unicode_ci,
  `sample_type_id` int(11) DEFAULT NULL,
  `image` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rows` int(11) DEFAULT NULL,
  `columns` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_types`
--

LOCK TABLES `object_types` WRITE;
/*!40000 ALTER TABLE `object_types` DISABLE KEYS */;
INSERT INTO `object_types` VALUES (1,'__Part','Part of a collection',0,1,'sample_container','No safety information','No cleanup information','No data','No vendor information','2018-12-21 17:59:09','2018-12-21 17:59:09','part',0.01,'return','',NULL,'','',NULL,NULL),(2,'Orphan','Part of a collection',0,1,'part','No safety information','No cleanup information','No data','No vendor information','2018-12-21 17:59:09','2018-12-21 17:59:09','part',0.01,'return','',NULL,'','',NULL,NULL);
/*!40000 ALTER TABLE `object_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_types`
--

DROP TABLE IF EXISTS `operation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deployed` tinyint(1) DEFAULT NULL,
  `on_the_fly` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_operation_types_on_category_and_name` (`category`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_types`
--

LOCK TABLES `operation_types` WRITE;
/*!40000 ALTER TABLE `operation_types` DISABLE KEYS */;
INSERT INTO `operation_types` VALUES (1,'Direct Purchase','Misc.',1,1,'2020-01-24 16:50:00','2020-01-24 16:50:00');
/*!40000 ALTER TABLE `operation_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operations`
--

DROP TABLE IF EXISTS `operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operation_type_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_operations_on_operation_type_id` (`operation_type_id`),
  KEY `index_operations_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operations`
--

LOCK TABLES `operations` WRITE;
/*!40000 ALTER TABLE `operations` DISABLE KEYS */;
/*!40000 ALTER TABLE `operations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parameters`
--

DROP TABLE IF EXISTS `parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parameters`
--

LOCK TABLES `parameters` WRITE;
/*!40000 ALTER TABLE `parameters` DISABLE KEYS */;
INSERT INTO `parameters` VALUES (1,'email','joe@nasa.org','2018-10-31 22:44:56','2018-10-31 22:44:56',NULL,1),(2,'phone','8675309','2018-10-31 22:44:56','2018-10-31 22:44:56',NULL,1),(3,'biofab',NULL,'2018-10-31 22:44:56','2018-10-31 22:44:56',NULL,1),(4,'aquarium',NULL,'2018-10-31 22:44:56','2018-10-31 22:44:56',NULL,1),(5,'Make new samples private',NULL,'2018-10-31 22:44:56','2018-10-31 22:44:56',NULL,1),(6,'Lab Name',NULL,'2018-10-31 22:44:57','2018-10-31 22:44:57',NULL,1),(7,'email','joe@nasa.org','2018-10-31 22:45:00','2018-10-31 22:45:00',NULL,1),(8,'phone','8675309','2018-10-31 22:45:00','2018-10-31 22:45:00',NULL,1),(9,'biofab','true','2018-10-31 22:45:00','2018-10-31 22:45:00',NULL,1),(10,'aquarium','true','2018-10-31 22:45:00','2018-10-31 22:45:02',NULL,1),(11,'Make new samples private',NULL,'2018-10-31 22:45:00','2018-10-31 22:45:00',NULL,1),(12,'Lab Name',NULL,'2018-10-31 22:45:00','2018-10-31 22:45:00',NULL,1);
/*!40000 ALTER TABLE `parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `part_associations`
--

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
  UNIQUE KEY `index_part_associations_on_collection_id_and_row_and_column` (`collection_id`,`row`,`column`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `part_associations`
--

LOCK TABLES `part_associations` WRITE;
/*!40000 ALTER TABLE `part_associations` DISABLE KEYS */;
/*!40000 ALTER TABLE `part_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_associations`
--

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
  KEY `index_plan_associations_on_operation_id` (`operation_id`),
  KEY `index_plan_associations_on_plan_id` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_associations`
--

LOCK TABLES `plan_associations` WRITE;
/*!40000 ALTER TABLE `plan_associations` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plans`
--

DROP TABLE IF EXISTS `plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cost_limit` float DEFAULT NULL,
  `folder` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `layout` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_plans_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plans`
--

LOCK TABLES `plans` WRITE;
/*!40000 ALTER TABLE `plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample_types`
--

DROP TABLE IF EXISTS `sample_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample_types`
--

LOCK TABLES `sample_types` WRITE;
/*!40000 ALTER TABLE `sample_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `sample_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `samples`
--

DROP TABLE IF EXISTS `samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sample_type_id` int(11) DEFAULT NULL,
  `project` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `samples`
--

LOCK TABLES `samples` WRITE;
/*!40000 ALTER TABLE `samples` DISABLE KEYS */;
/*!40000 ALTER TABLE `samples` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20131029153603'),('20131029153634'),('20131111143554'),('20131111143621'),('20131113172448'),('20131113181345'),('20131119164152'),('20131119164208'),('20131122032927'),('20131223192901'),('20140131235419'),('20140404201838'),('20140404201900'),('20140404204258'),('20140408224245'),('20140428213241'),('20140507230919'),('20140508203643'),('20140513225335'),('20140616190537'),('20140714220057'),('20140907220135'),('20150124195318'),('20150124201744'),('20150129213358'),('20150129221830'),('20150212051010'),('20150212051027'),('20150213173621'),('20150222153442'),('20150326202149'),('20150405154727'),('20150515160553'),('20150515160619'),('20150719221125'),('20150719221226'),('20150719221253'),('20150719223053'),('20150720044538'),('20150828232337'),('20150923014954'),('20150923015030'),('20150923184243'),('20150924044044'),('20150926162327'),('20151027164741'),('20151029034310'),('20151118210640'),('20151203054202'),('20160128203950'),('20160128205317'),('20160128205943'),('20160129021809'),('20160129164244'),('20160129165100'),('20160330023703'),('20160330033810'),('20160330185947'),('20160330190634'),('20160411130601'),('20160411131711'),('20160412010529'),('20160427043024'),('20160427043546'),('20160429232330'),('20160429232408'),('20160429232434'),('20160430000308'),('20160430152749'),('20160514044605'),('20160526204339'),('20160607162741'),('20160615161649'),('20160720211005'),('20161113203042'),('20161219172133'),('20170330173426'),('20170421231924'),('20170426225719'),('20170504211619'),('20170504212208'),('20170604165355'),('20170627173019'),('20170725190809'),('20170729024546'),('20170806145525'),('20170813203843'),('20171103151518'),('20180509200425'),('20180529204642'),('20180809012224'),('20181221174622');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timings`
--

DROP TABLE IF EXISTS `timings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `days` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start` int(11) DEFAULT NULL,
  `stop` int(11) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timings`
--

LOCK TABLES `timings` WRITE;
/*!40000 ALTER TABLE `timings` DISABLE KEYS */;
/*!40000 ALTER TABLE `timings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uploads`
--

DROP TABLE IF EXISTS `uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uploads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) DEFAULT NULL,
  `upload_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `upload_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `upload_file_size` int(11) DEFAULT NULL,
  `upload_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uploads`
--

LOCK TABLES `uploads` WRITE;
/*!40000 ALTER TABLE `uploads` DISABLE KEYS */;
/*!40000 ALTER TABLE `uploads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_budget_associations`
--

DROP TABLE IF EXISTS `user_budget_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_budget_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `budget_id` int(11) DEFAULT NULL,
  `quota` float DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_budget_associations`
--

LOCK TABLES `user_budget_associations` WRITE;
/*!40000 ALTER TABLE `user_budget_associations` DISABLE KEYS */;
INSERT INTO `user_budget_associations` VALUES (1,1,1,1000,0,'2018-07-17 22:10:10','2018-07-17 22:10:10');
/*!40000 ALTER TABLE `user_budget_associations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `password_digest` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `index_users_on_remember_token` (`remember_token`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Joe Neptune','neptune','2013-06-16 17:26:54','2017-10-19 04:59:18','$2a$10$HxgxLX5/ITcYpII1InAL1.jUYAiHk/rMftHniPJVvauy43VDoo8yW','TYmoWfyV42AL7dSoYcgmug',1,'VHzz9IW3xnNx8O3cA_P0rKsUWmTVH_Qz9mHKqgE-hNI');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wires`
--

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wires`
--

LOCK TABLES `wires` WRITE;
/*!40000 ALTER TABLE `wires` DISABLE KEYS */;
/*!40000 ALTER TABLE `wires` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wizards`
--

DROP TABLE IF EXISTS `wizards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wizards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `specification` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wizards`
--

LOCK TABLES `wizards` WRITE;
/*!40000 ALTER TABLE `wizards` DISABLE KEYS */;
/*!40000 ALTER TABLE `wizards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workers`
--

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
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workers`
--

LOCK TABLES `workers` WRITE;
/*!40000 ALTER TABLE `workers` DISABLE KEYS */;
INSERT INTO `workers` VALUES (1,'publisher',NULL,'running','2018-11-16 16:09:14','2018-11-16 16:09:14'),(2,'publisher',NULL,'done','2018-11-16 16:10:31','2018-11-16 16:11:22'),(3,'publisher',NULL,'done','2018-11-16 16:11:16','2018-11-16 16:12:03'),(4,'publisher',NULL,'done','2018-11-16 16:15:00','2018-11-16 16:15:39'),(5,'publisher',NULL,'done','2018-11-16 16:16:19','2018-11-16 16:17:11'),(6,'publisher',NULL,'done','2018-11-16 16:19:23','2018-11-16 16:19:56'),(7,'publisher',NULL,'done','2018-11-16 17:45:28','2018-11-16 17:45:45'),(8,'publisher',NULL,'done','2018-11-16 17:48:08','2018-11-16 17:48:18'),(9,'publisher',NULL,'done','2018-11-16 18:43:18','2018-11-16 18:43:39'),(10,'publisher',NULL,'done','2018-11-16 18:46:03','2018-11-16 18:46:17'),(11,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON','error','2018-11-16 18:48:41','2018-11-16 18:48:47'),(12,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON','error','2018-11-16 18:54:15','2018-11-16 18:54:21'),(13,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON','error','2018-11-16 18:55:55','2018-11-16 18:56:00'),(14,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON','error','2018-11-16 19:01:31','2018-11-16 19:01:35'),(15,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON','error','2018-11-16 19:02:46','2018-11-16 19:02:51'),(16,'publisher',NULL,'running','2018-11-16 19:08:07','2018-11-16 19:08:07'),(17,'publisher',NULL,'running','2018-11-16 19:14:15','2018-11-16 19:14:15'),(18,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON: (erb):21:in `make_index\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 19:21:57','2018-11-16 19:22:02'),(19,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON: (erb):21:in `make_index\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 19:24:08','2018-11-16 19:24:14'),(20,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON: (erb):21:in `make_index\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 19:27:22','2018-11-16 19:27:28'),(21,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON: (erb):21:in `make_index\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 19:30:01','2018-11-16 19:30:07'),(22,'publisher','undefined method `join\' for nil:NilClass\nDid you mean?  JSON: (erb):21:in `make_index\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 19:33:00','2018-11-16 19:33:05'),(23,'publisher',NULL,'done','2018-11-16 19:34:25','2018-11-16 19:34:39'),(24,'publisher',NULL,'done','2018-11-16 19:35:54','2018-11-16 19:36:09'),(25,'publisher','undefined method `each\' for nil:NilClass: (erb):20:in `make_about_md\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 20:41:04','2018-11-16 20:41:09'),(26,'publisher','undefined method `each\' for nil:NilClass: (erb):20:in `make_about_md\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 20:45:28','2018-11-16 20:45:33'),(27,'publisher','undefined method `each\' for nil:NilClass: (erb):13:in `make_about_md\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `block in result\'','error','2018-11-16 20:47:12','2018-11-16 20:47:16'),(28,'publisher',NULL,'done','2018-11-16 20:48:39','2018-11-16 20:48:55'),(29,'publisher',NULL,'done','2018-11-16 20:53:35','2018-11-16 20:53:50'),(30,'publisher',NULL,'done','2018-11-16 20:54:37','2018-11-16 20:54:51'),(31,'publisher',NULL,'done','2018-11-16 20:55:41','2018-11-16 20:55:56'),(32,'publisher',NULL,'done','2018-11-16 21:58:44','2018-11-16 21:58:58'),(33,'publisher',NULL,'running','2018-11-16 22:02:27','2018-11-16 22:02:27'),(34,'publisher','undefined local variable or method `zipname\' for #<Aquadoc::Render:0x00007ffe86a82230>: (erb):5:in `make_about_md\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb.rb:861:in `eval\', /Users/ericklavins/.rvm/rubies/ruby-2.3.7/lib/ruby/2.3.0/erb','error','2018-11-16 22:07:51','2018-11-16 22:07:56'),(35,'publisher',NULL,'done','2018-11-16 22:09:37','2018-11-16 22:09:48'),(36,'publisher',NULL,'done','2018-11-16 22:12:31','2018-11-16 22:12:51'),(37,'publisher',NULL,'done','2018-11-16 22:17:24','2018-11-16 22:17:51'),(38,'publisher',NULL,'done','2018-11-16 22:22:22','2018-11-16 22:22:33'),(39,'publisher',NULL,'done','2018-11-27 23:09:12','2018-11-27 23:10:09'),(40,'publisher',NULL,'done','2018-11-27 23:28:01','2018-11-27 23:28:36'),(41,'publisher',NULL,'done','2018-11-27 23:30:47','2018-11-27 23:31:14'),(42,'publisher',NULL,'done','2018-11-27 23:34:57','2018-11-27 23:35:13'),(43,'publisher',NULL,'done','2018-11-27 23:36:23','2018-11-27 23:36:51'),(44,'publisher',NULL,'done','2018-11-27 23:41:27','2018-11-27 23:42:18'),(45,'publisher',NULL,'done','2018-12-12 18:29:44','2018-12-12 18:31:08'),(46,'publisher',NULL,'done','2018-12-17 21:35:41','2018-12-17 21:36:01'),(47,'publisher',NULL,'done','2018-12-17 21:45:33','2018-12-17 21:45:52'),(48,'publisher',NULL,'done','2018-12-17 22:15:09','2018-12-17 22:15:29'),(49,'publisher',NULL,'done','2018-12-17 22:30:15','2018-12-17 22:30:33'),(50,'publisher',NULL,'done','2018-12-17 22:37:31','2018-12-17 22:37:51'),(51,'publisher',NULL,'done','2018-12-17 22:48:07','2018-12-17 22:48:14'),(52,'publisher',NULL,'done','2018-12-17 23:11:22','2018-12-17 23:11:40');
/*!40000 ALTER TABLE `workers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-24  8:54:18
