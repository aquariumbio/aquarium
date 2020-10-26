/* NOTES

1. This script deletes all orphan rows in the database. 
   It is used to scrub the database before adding foreign keys. 
   For examle, if a {job}.user_id points to a user_id that is no longer in the database then that {job} must be deleted before the foreign key can be added.

2. Some relationships in Aquarium are not reinforced using foreign keys.
   Those references take the form of [ :parent_class, :parent_id ] where :parent_class identifies the table and :parent_id identifies the row in that table.  
   This script removes orphan rows for those as well.

parent_classes in the data_associations table
  Item            => items table
  Plan            => plans table
  Operation       => operations table
  Collection      => items table
  OperationType   => operation_types table


parent_classes in the field_types table
  SampleType      => sample_types table
  OperationType   => operation_types table


parent_classes in the field_values table
  Sample          => samples table
  Operation       => operations table
  NULL            => skip


parent_classes in the timings table
  OperationType   => operation_types table

3. The order in which these queries are run is important. 
   For example, if <child> points to <parent>, then we need to delete any orphan rows in <parent> before checking for orphan rows in <child>

4. The <items> table and <locators> table are double linked (item.locator_id points to a locator and locator.item_id points to an item).  
   For these tables we first remove all orphan locators not tied to items, then remove orphan items items, then remove any other locators where the item may have been deleted

*/

DELETE FROM jobs WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM jobs WHERE group_id is not null and group_id NOT IN (SELECT id FROM groups);
DELETE FROM operations WHERE operation_type_id is not null and operation_type_id NOT IN (SELECT id FROM operation_types);
DELETE FROM operations WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM accounts WHERE budget_id is not null and budget_id NOT IN (SELECT id FROM budgets);
DELETE FROM accounts WHERE job_id is not null and job_id NOT IN (SELECT id FROM jobs);
DELETE FROM accounts WHERE operation_id is not null and operation_id NOT IN (SELECT id FROM operations);
DELETE FROM accounts WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM account_logs WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM account_logs WHERE row1 is not null and row1 NOT IN (SELECT id FROM accounts);
DELETE FROM account_logs WHERE row2 is not null and row2 NOT IN (SELECT id FROM accounts);
delete from field_types where parent_class = 'SampleType' and parent_id not in (select id from sample_types);
delete from field_types where parent_class = 'OperationType' and parent_id not in (select id from operation_types);
DELETE FROM allowable_field_types WHERE field_type_id is not null and field_type_id NOT IN (SELECT id FROM field_types);
DELETE FROM allowable_field_types WHERE sample_type_id is not null and sample_type_id NOT IN (SELECT id FROM sample_types);
DELETE FROM allowable_field_types WHERE object_type_id is not null and object_type_id NOT IN (SELECT id FROM object_types);
DELETE FROM samples WHERE sample_type_id is not null and sample_type_id NOT IN (SELECT id FROM sample_types);
DELETE FROM samples WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM locators WHERE wizard_id is not null and wizard_id NOT IN (SELECT id FROM wizards);
DELETE FROM items WHERE sample_id is not null and sample_id NOT IN (SELECT id FROM samples);
DELETE FROM items WHERE locator_id is not null and locator_id NOT IN (SELECT id FROM locators);
DELETE FROM items WHERE object_type_id is not null and object_type_id NOT IN (SELECT id FROM object_types);
DELETE FROM locators WHERE item_id is not null and item_id NOT IN (SELECT id FROM items);
DELETE FROM uploads WHERE job_id is not null and job_id NOT IN (SELECT id FROM jobs);
DELETE FROM plans WHERE budget_id is not null and budget_id NOT IN (SELECT id FROM budgets);
DELETE FROM plans WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM data_associations WHERE upload_id is not null and upload_id NOT IN (SELECT id FROM uploads);
delete from data_associations where parent_class = 'Item' and parent_id not in (select id from items);
delete from data_associations where parent_class = 'Collection' and parent_id not in (select id from items);
delete from data_associations where parent_class = 'Plan' and parent_id not in (select id from plans);
delete from data_associations where parent_class = 'Operation' and parent_id not in (select id from operations);
delete from data_associations where parent_class = 'OperationType' and parent_id not in (select id from operation_types);
delete from field_values where parent_class = 'Sample' and parent_id is not null and parent_id not in (select id from samples);
delete from field_values where parent_class = 'Operation' and parent_id is not null and parent_id not in (select id from operations);
DELETE FROM field_values WHERE child_item_id is not null and child_item_id NOT IN (SELECT id FROM items);
DELETE FROM field_values WHERE child_sample_id is not null and child_sample_id NOT IN (SELECT id FROM samples);
DELETE FROM field_values WHERE allowable_field_type_id is not null and allowable_field_type_id NOT IN (SELECT id FROM allowable_field_types);
DELETE FROM field_values WHERE field_type_id is not null and field_type_id NOT IN (SELECT id FROM field_types);
DELETE FROM invoices WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM invoices WHERE budget_id is not null and budget_id NOT IN (SELECT id FROM budgets);
DELETE FROM job_associations WHERE job_id is not null and job_id NOT IN (SELECT id FROM jobs);
DELETE FROM job_associations WHERE operation_id is not null and operation_id NOT IN (SELECT id FROM operations);
DELETE FROM logs WHERE job_id is not null and job_id NOT IN (SELECT id FROM jobs);
DELETE FROM logs WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM memberships WHERE group_id is not null and group_id NOT IN (SELECT id FROM groups);
DELETE FROM memberships WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM part_associations WHERE collection_id is not null and collection_id NOT IN (SELECT id FROM items);
DELETE FROM part_associations WHERE part_id is not null and part_id NOT IN (SELECT id FROM items);
DELETE FROM plan_associations WHERE operation_id is not null and operation_id NOT IN (SELECT id FROM operations);
DELETE FROM plan_associations WHERE plan_id is not null and plan_id NOT IN (SELECT id FROM plans);
DELETE FROM user_budget_associations WHERE budget_id is not null and budget_id NOT IN (SELECT id FROM budgets);
DELETE FROM user_budget_associations WHERE user_id is not null and user_id NOT IN (SELECT id FROM users);
DELETE FROM wires WHERE from_id is not null and from_id NOT IN (SELECT id FROM field_values);
DELETE FROM wires WHERE to_id is not null and to_id NOT IN (SELECT id FROM field_values);
delete from timings where parent_class = 'OperationType' and parent_id not in (select id from operation_types);
