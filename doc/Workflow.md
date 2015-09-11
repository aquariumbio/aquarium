# Aquarium Workflows

## Inventory Specifications

An inventory specification is defined by a JSON object with the following form:

	{
		name: varname,
		is_part: true|false,
		is_shared: true|false,
		is_matrix: true|false,
		rows: number,
		columns: number,
		alternatives: [
			{
				sample_type: id,
				container: id,
				sample: id,
				item: id,
				row: number,
				column: number
			},
			...
		] 
	}
	
The name field defines the name of the inventory specification, which will be used as a variable name in the protocol corresponding to the operation for which the specification is an input or output. All true/false fields are optional and if one is absent it is considered to be false. The rows and columns fields need only be present if the is_matrix field is true.

The alternatives array lists an array of hashes, each of which defines a set of items or parts that can be used to meet the specification. The fields for each alternative are optional. They specify the sample type, container, or sample that an item meeting the specification must meet. If the item field is present, then an item meeting the specification must be that exact item. If the row and column fields are present, then the alternative can be satisfied by a part (see below) as long as the part's row and column match.

If is_part is true, then the specification must be met by a part and not an item. A part is defined by a collection and a particular x,y coordinate in that collection.

If is_matrix is true (and rows and columns are therefore defined), then the specification can only be met by a matrix of items (or parts if is_part is true) where each item (or part) is consistent with at least one of the alternatives listed.

## Operations

### Inputs

### Outputs

### Parameters

### Data

### Exceptions

## Workflows