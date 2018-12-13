---
title: Tracking Provenance
layout: docs
---

# Tracking Provenance in Protocols

The provenance of an item refers to its origins – how it came to be.
Traditionally, the concept has been used for art: you know that you have a painting by Picasso because you have documentation, the provenance, that traces ownership back to Picasso.
But the term has come to describe how something was created.
For instance, in technology, provenance refers to files, and can be complex descriptions of how a file was created and by whom.
These descriptions are commonly constructed using models based on the [PROV](https://www.w3.org/TR/prov-overview/) standard from W3C, which describes provenance in terms of entities, activities and agents.

## Aquarium Provenance

This document discusses a basic model of provenance for Aquarium that can be used to capture the origins of items and data files (aka, `uploads`).
See the [PROV Primer](https://www.w3.org/TR/prov-primer/) for discussion of the general concepts.

For this basic model, we define entities and activities as follows (ignoring agents at the moment)

- An _entity_ is an item, a collection, a part of a collection, or a file.
- An _activity_ is an operation or a job

In terms of relationships, we will only model those that trace backwards:

- the operation that generated an item (the item _generator_),
- the items from which an item was built (the items _sources_), and
- the items that are inputs to an operation (the operation _inputs_).

These are sufficient to construct the forward tracing relationships.

## Conventions for Provenance Construction

Models of the provenance of items and files can be derived from Aquarium provided the protocols are built in certain ways.
This assumes that provenance is constructed relative to a plan.

### Identifying activities

The only objects in Aquarium that represent activities are `Operations` or `Jobs`.
So, if there is a discrete activity that is responsible for creating an item or file, it needs to be implemented as an operation type

### Identifying item entities

###

- Using routing IDs – routing IDs are used in Aquarium to determine how inputs and outputs are related.
  The requirement is that the sample type of the inputs and outputs match.
  These can describe one-to-many relationships, so if an input is used in several outputs, it is OK to tag each output with the routing ID of the input.
  On the other hand, routing IDs are not needed if there isn't a direct relationship between inputs and outputs.

- Data file associations – for a file that is the result of a measurement, associate the file to the operation that generated it, and to the item that was measured.
  For collections, if the file captures measurements of a whole collection, then associate it with the collection; otherwise, associate it to the part item.
  If you want to have a file be accessible in other operations, use a plan blackboard.

- Items should have identified source items
