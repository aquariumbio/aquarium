# Aquarium Release Notes

## v2.1XX

1. `OperationType` names are now required to be unique within a category.
   Before running the migrations, also run the rake task
   `rake rename_optype_duplicates`, which will make a best guess about which of
   the operations with duplicate names should be renamed and update the table.
   
2. ...
   