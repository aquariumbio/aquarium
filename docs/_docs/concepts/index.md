---
title: Aquarium Concepts
layout: docs
permalink: /concepts/
---

# Aquarium Concepts

This document introduces the basic concepts of Aquarium.
More details are given in relevant sections of the documentation.

## Items

Aquarium protocols manipulate items in the LIMS inventory.
An _item_ represents a physical entity in the lab.
For instance, this diagram represents a GFP-tagged plasmid in a glycerol stock in a eppendorf tube located in a freezer.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/items.png %}" width="50%">

Each item has three components representing these details: the sample, the object type, and the location.
For the example in the diagram, these are

- the plasmid puc19-GFP (the sample),
- in a glycerol stock in an eppendorf tube (the object type), and
- stored in a freezer (the location).

A _sample_ is effectively the class of entity for which the item is an instance, and has a _sample type_.
Here the sample is puc19-GFP, which has sample type of plasmid.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/samples.png %}" width="50%">

An item _location_ in Aquarium is a hierarchical description of where the item can be found.
For instance, the UW BIOFAB location `M20.1.5.49` is a location in a box in a -20C freezer as illustrated by this diagram:

<img src="{{ site.baseurl }}{% link _docs/concepts/images/location.png %}" width="50%">

## Operations

A protocol performed in Aquarium is represented as an _operation_.
Concretely, an operation is defined by an _operation type_ that indicates how the operation will be performed, and is defined by a protocol script that takes inputs and produces outputs.
This diagram illustrates an operation type for bacterial transformation, which takes DNA and competent cells as inputs and performs a transformation to produce transformed cells.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/operation-type.png %}" width="50%">

One of the key details of this operation type is that can be given different types of inputs as long as they are consistent with the type in the operation type.
In the diagram, the DNA input could be either a Maxiprep of Plasmid Library or a Miniprep of Plasmid Library.
The type of the output depends on the types of the inputs.

An _operation_ is a particular instance of an operation type with concrete inputs and outputs.
This is illustrated in this diagram, which The diagram shows the bacterial transformation operation where the inputs are identified with particular items that exist in the inventory.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/operation.png %}" width="50%">

An operation occurs in a _plan_, which is a set of operations with linked inputs and outputs.
The diagram shows the output of the bacterial transformation operation linked to an input of a colony PCR operation.

## Jobs

When plans are executed in Aquarium, similar operations are batched together as a _job_.
These operations may come from different plans of different researchers as illustrated here where three distinct plans have shared operations.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/planned-operations.png %}" width="50%">

Operations that are ready at the same time can be grouped into jobs by the manager.
Here the operations are batched into four jobs.
The manager can batch operations in to jobs as needed – in this case, the manager chose to create jobs 2 and 3 separately even though the operations have the same operation type.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/batched-jobs.png %}" width="50%">

Jobs are then scheduled and assigned to a technician to perform.

<img src="{{ site.baseurl }}{% link _docs/concepts/images/scheduled-jobs.png %}" width="50%">

## Operation States

After a plan is launched, the operations in the plan move through several states:

- _waiting_ – the operation is waiting for a predecessor in the plan to complete
- _pending_ – the operation is ready to be scheduled by a manager
- _scheduled_ – the job of the operation is ready to be started by a technician
- _running_ – the job of the operation is being run by a technician
- _complete_ – the jot of the operation has finished without error

In addition, operations may have other states depending on the definition of the operation type.
The most common relates to evaluation of the precondition of an operation. Each operation type has a precondition that must be true before an operation of that type can transition into pending.
Most preconditions are trivially true, meaning they can always be run, but some have more complex preconditions that may fail.
If the precondition of an operation fails, then the operation is put into the _delayed_ state.

Less common is the _deferred_ state.
This arises when an operation has a predecessor operation that has an _on-the-fly_ operation type.
An operation type is marked as being _on-the-fly_ if the number of operations of that type is used to determine the number of operations of a dependent operation type.
An example is running a gel: to run a gel, you need to pour a gel.
The operation type `Pour Gel` must be on-the-fly because it is not clear how many gels to pour until a job is formed of corresponding `Run Gel` operations.
Because of this relationship, the `Run Gel` operations must be batched before the `Pour Gel` operations can start, and will be _deferred_ until the `Pour Gel` operations complete.
