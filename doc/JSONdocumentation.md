Let’s begin by looking at the JSON that that describes the workflow below:
![Fragment Construction Workflow](images/JSON/workflow_fragment_construction.jpeg)
##Workflow JSON 
The JSON below describes a workflow by listing its constituent operations and their locations in the workflow editor along with the timing information associated with each of them. These workflows are stored in the **workflow** table.
```json
{

	"operations": [{
		"id": 1,
		"x": 8,
		"y": 9,
		"timing": "immediately"
	},
	{
		"id": 2,
		"x": 7,
		"y": 110,
		"timing": "immediately"
	},
	{
		"id": 3,
		"x": 205,
		"y": 48,
		"timing": "1:00 after previous"
	},
],
	"description": "Use this workflow to amplify a fragment from a template using PCR; run it in a gel; extract it; and purify it."
}

```
The ‘id’ key-value pair in the JSON above refers to an individual operation. A workflow is comprised of several operation strung together in a logical manner. The ‘id’ field is a pointer to the operations table which contains more information about the operation in question. For e.g. the PCR operation above has the id 1.

![Fragment Construction Workflow](images/JSON/operation_pcr.png)

The specification for this operation is also made via the same workflow editor in the following manner

![Fragment Construction Workflow](images/JSON/operation_pcr_input_fwd.png)
##Operation JSON
The JSON corresponding this id number in the operations table is as given below
The skeletal structure of the JSON is as follows
```json
{
	"inputs": […..],
	"outputs": […],
	"parameters": [….],
	"data": […….],
	"exceptions": [],
	"id": 1,
	"name": "PCR",
	"protocol": "/aqualib/auto/.rb",
	"workflow": 1
}
```
Let’s go through these parts one by one

The inputs array lists properties associated with each input such as default sample_type and container. An entry of the input array associated with this specific operation is given below:
```json
{
		"name": "fwd",
		"description": "Forward Primer",
		"is_part": false,
		"is_matrix": false,
		"alternatives": [{
			"sample_type": "1: Primer",
			"container": "207: Primer Aliquot"}]
}
```
The strings “1: Primer" and "207: Primer Aliquot" are references to other entities within the Aquarium system. The string “1: Primer" is a reference to the sample_types table, specifically the sample_type with the id 1. The "207: Primer Aliquot" string is a reference to the object_types table.
The outputs array is similar in nature and reflects detailed properties related to the outputs associated with the operation. An entry from the output array associated with this operation is given below:
```json
{
"name": "fragment",
"description": "Description here",
"is_part": true,
"is_matrix": false,
"alternatives": [{
"sample_type": "4: Fragment",
"container": "440: Stripwell"]
}

```
##Workflow Process JSON
A user creates a Workflow process and attaches many threads to this process. The JSON corresponding to each process can be found in the workflow_processes table.

##Workflow Thread JSON
Let’s look at the final specification or the JSON for a Workflow Thread associated with a Workflow Process for the Workflow with the id 1.
```json
[{
	"name": "fwd",
	"sample": "564: GAL1m-Hom-PGK1-UEE-R"
},
{
	"name": "rev",
	"sample": "3440: pGRR-F7-r"
},
{
	"name": "template",
	"sample": "2611: 2u-prpr1-ST1sg1"
},
{
	"name": "ladder",
	"sample": "55: 100 bp Ladder"
},
{
	"name": "fragment",
	"sample": "702: pp2-pTEF1-tar-PS"
},
{
	"name": "tanneal",
	"value": 27.1
}]

```
In the above JSON, each value corresponding to string such as "564: GAL1m-Hom-PGK1-UEE-R" is a reference to a row in the samples table with the corresponding id number.
