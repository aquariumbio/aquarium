# Plan Representation

Plans are represented differently in the front end and the back end. Mainly,
the front end adds fields that are useful for manipulating the user interface,
while the back end only represents those fields that are stored in the
database. Thus, when sending plans back and forth between the two ends,
the json representing the plans needs to be marshalled and serialized on
each side.

## Plan

```json
  {

    /* Common fields */

    id: INTEGER,
    name: STRING,
    status: STRING.
    user_id: INTEGER
    budget_id: INTEGER,
    cost_limit: FLOAT,

    /* Derived Fields */

    operations: LIST OF OPERATIONS
    wires: LIST OF WIRES,

    /* Front end fields */

    rid: INTEGER // Record ID, used by front end to keep track of objects

  }
```

## Operation

```json
  {

    /* Common fields */

    id: INTEGER,
    status: STRING,
    user_id: integer,
    x: FLOAT,
    y: FLOAT,
    operation_type_id: REFERENCE TO OPERATION TYPE

    /* Derived Fields */

    operation_type: OPERATION_TYPE,
    field_values: LIST OF FIELD VALUES

    /* Front end fields */

    rid: INTEGER // Record ID

    routing: {                 // describes the sample associated with the specified routing key
      key: SAMPLE_IDENTIFIER,  // and needs to be consistent with any field values whose field types
      ...                      // share that routing key
    },

    form: {                           // Describes which aft is being used for which i/o
      input: {                        // and needs to be consistent with the field value afts
        io_name: {
          aft_id: INTEGER
          aft: ALLOWABLE_FIELD_TYPE
        },
        ...
      },
      output: {
        io_name: {
          aft_id: INTEGER
          aft: ALLOWABLE_FIELD_TYPE
        },
        ...
      }
    }

  }
```

## Wire

```json
  {

    /* Common Fields */
    id: INTEGER,
    to_id: REFERENCE TO FIELD VALUE,
    from_id: REFERENCE TO FIELD VALUE,

    /* Front end fields */
    rid: INTEGER, // Record ID
    to: FIELD VALUE,
    from: FIELD_VALUE,
    to_op: OPERATION,
    from_op: OPERATION

  }
```

## OperationType

```json
  {

    /* Common Fields */
    id: INTEGER,
    name: STRING,
    category: STRING,
    deployed: BOOLEAN,
    on_the_fly: BOOLEAN,

    /* Derived Fields */
    field_types: LIST OF FIELD TYPES

    /* Front end Fields */
    rid: INTEGER ,// Record ID

  }
```

## FieldType

```json
  {

    /* Common Fields */

    id: INTEGER,
    parent_id: REFERENCE,
    parent_class: STRING,
    array: BOOLEAN,
    choices: STRING, // of the form string1, string2, ..., stringn
    name: STRING.
    required: BOOLEAN,
    ftype: STRING, // 'sample', 'number', or 'string'
    role: STRING,  // 'input' or 'output'
    part: BOOLEAN,
    routing: STRING,
    preferred_operation_type_id: REFERENCES
    preferred_field_type_id: REFERENCES

    /* Derived Fields */
    allowable_field_types: LIST OF FIELD_TYPES

    /* Front End Fields */
    rid: INTEGER // Record ID

  }
```

## AllowableFieldType

```json
  {

    /* Common Fields */
    id: INTEGER,
    sample_type_id: INTEGER,
    object_type_id: INTEGER,

    /* Derived Fields */
    sample_type: SAMPLE TYPE,
    object_type: OBJECT_TYPE

    /* Front End Fields */
    rid: INTEGER

  }
```

## FieldValue

```json
  {

    /* Common Fields */
    name: STRING,
    child_item_id: REFERENCE,
    child_sample_id: REFERENCE,
    value: STRING, // Numbers are represented as strings
    role: STRING,
    field_type_id: REFERENCES,
    row: INTEGER,
    column: INTEGER,
    allowable_field_type_id: REFERENCE,
    parent_class: STRING,
    parent_id: REFERENCE,

    /* Derived Fields */
    item: ITEM, // derived from child_item_id
    sample: SAMPLE, // derived from child_sample_id,
    allowable_field_type: ALLOWABLE_FIELD_TYPE
    field_type: FIELD_TYPE

    /* Front End Fields */
    rid: INTEGER

  }
```
