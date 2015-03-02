# The Aquarium API

Third party applications can communicate with Aquarium through the Aquarium API through http-post and json. The API enables your application to query the Aquarium databased to retrieve information of inventory and jobs, as well as to insert new inventory (such as samples), start jobs, submit tasks, and more.

This document starts assuming you know how to send an HTTP POST request. If you need a refresher, see Appendix 2.

## Authentication

All requests sent to Aquarium need to include a valid login name and a key. Keys can be obtained via the Aquarium UI on the user's profile page. The simplest request to the API has the following form.

	{ 
      "login": "eric123",
	  "key": "FMCdd9bZ5swg85pSu5cPC2PbP3G8pvHNf8rgEOARNg8"
	}
	
## Request Format

All requests, beyond simply authenticating, have the following form.

	{ 
		"login": string,
		"key": string,
		"run": {
			"method": string
			"args": json
		}
	}

Essentially, this form requests that the API run the method indicated in the "method" field on the arguments indicated by the "args" field. The methods available are "find", "create", and "submit", which are described below.

**Note**: Future versions of the API will allow an array of methods to be run.

## Responses

The Aquarium API will respond to requests with a JSON object the following fields.

### <tt>result</tt>

The value of this field is either "ok" or "error".

### <tt>errors</tt>

The value of this field is an array of error messages that is present only if there are errors.

### <tt>warnings</tt>

The value of this field is an array of warnings, only present if something odd is detected.

### <tt>rows</tt>

An array of Aquarium objects resulting from the method run (see below).

## Inventory Queries

If "method" is "find", then the following arguments can be given.

**model**: Required. One of "user", "job", "task", "item", "sample", "sample_type" or "object_type". 

**where**: Optional. Specifies which rows to include. For example,


	"run" : {
		"method": "find",
		"args": { 
			"model": "item",
			"where": '{ "id": 123 }'
		}
	}
	
requests all items whose id is 123, which should result in no more than one item. If no "where" field is specified, the request returns all models (unless a limit is specified, as below).

**includes**: Which associations to include. For example,

    run: {
    	"method": "find",
    	"args": {
    		"model": "item",
        	"where": { "sample": { "name" "CFP_r" } },
       		"includes": "sample"
        }
    }
	
retrieves all items whose associated sample is named "CFP_r". Without the "includes" field, the request would fail because the sample associated with the item would not be included in the database query.

**limit**: How many rows to return. For example,

	run: {
    	method: "find",
	    args: {
    		model: :item,
    		limit: 32
        }
    }
    
Returns the first 32 items in the database.

## Inserting Inventory

## Submitting Tasks

## Submitting Jobs

# Appendix 1: Aquarium Datatypes

## object_type

## sample_type

## sample

## item

	"id": integer
	"location": string
	"quantity": integer
    "sample_id": integer
	"object_type_id": integer
	"created_at": date string
	"updated_at": date string
	"data": json
	"sample": associated sample (optional)
	"object_type": associated object_type (option)

## job

## task

## user

# Appendix 2: Connecting to the API Various Languages

## Ruby

## Python

## Javascript

## MATLAB
