# Krill Workflow API Tutorial

Note: Use Chrome.

## Starting a New Workflow
A **workflow** is a set of interconnected **operations**, each with a set of inputs and outputs, that collectively describe the inputs and outputs of the workflow. The important thing is that a workflow describes the *relationship* between bits of code known as [**protocols**][protocols] (one contained within each operation), while the operations themselves are *input/output specifications* of protocols, code that programmers have written to define a set of instructions for someone in the lab. This tutorial covers everything you should need to know to specify operations, link them together, and launch and debug a workflow like a champ.

To create a new workflow, first navigate to the workflow index.

![index](images/workflow_tutorial/index.png)

Now click "New"

[the next image]

If you decided you wanted to clone some yeast, the natural first step would be to streak a plate with some yeast strains. Our first workflow will describe just that, which means it will need only two operations: "Streak Plate" and "Image Plate," as in the diagram below:

[nifty workflow diagram]

Name and describe the workflow, and then be sure to save all of your hard work thus far.

![name_and_description](images/workflow_tutorial/name_and_description.png)

Note: Save often. 

### Creating an Operation

#### Specifying All the Things

#### Adding Inputs
name them carefully because these exact names are used in protocol code
#### Adding Outputs

#### Adding Parameters

#### Adding Data

#### Adding Exceptions

### Creating Another Operation

## Launching the Workflow

Now that the "Streak Plate" workflow has been carefully described, make sure you've saved, and click "Launch." You will be taken to a launch screen where you can build one or more [**threads**][threads]. Here, you'll see the inputs for both of our operations listed; these are essentially the inputs for the workflow. Each thread, in this case, corresponds to a single strain of yeast. Typically, someone performing an operation from this workflow in the lab will operate on many strains simultaneously. Let's say we have two different types of strain we want to clone, so we build two threads to launch in this workflow, one for each strain type. Start typing "434: pMOD-8-pRPR1-gRNAc3" into both cells of the table, and select them in the drop-down when they appear. Then click "Add." Now do the same with "434: pMOD-8-pRPR1-gRNAc3."

![build_threads](images/workflow_tutorial/build_threads.png)

Note: The "Yeast Glycerol Stock" and "Streaked Yeast Plate" inputs must be of the same sample type because the type of yeast strain (the sample type) has not changed between the two operations "Streak Plate" and "Image Plate."

Note: To more fully understand what we're doing in this step, it is necessary to understand the differences between **sample types**, **samples**, and **items**. You can read up on them [here][sample types, samples, and items]. Here, the sample type is "Yeast Strain," the samples are "434: pMOD-8-pRPR1-gRNAc3" and "435: pMOD-8-pRPR1-gRNAc7," and the items are the physical strains in the lab located by the [M80 location wizard][location wizards]. We could, for example, launch three threads each with the sample type "434: pMOD-8-pRPR1-gRNAc3," and the location wizard would try to find three different items of that sample type.

### To Debug or Not to Debug?

## Reading Errors

## Editing Protocol Code
link to WorkflowProtocolAPI.md

## Questions
Who is the intended audience? The "expert" should only have to link up operations, while the "programmer" will need to add inputs/outputs and write protocol code.
How's my definition of "thread"?

[protocols]: https://github.com/klavinslab/aquarium/blob/master/doc/Krill.md#authoring-protocols-for-aquarium "Authoring Protocols for Aquarium"
[threads]: https://github.com/klavinslab/aquarium/blob/master/doc/WorkflowProtocolAPI.md#threads "Threads"
[sample types, samples, and items]: https://github.com/klavinslab/aquarium/blob/master/doc/Krill.md#items-objects-and-samples "Sample Types, Samples, and Items"
[location wizards]: https://github.com/klavinslab/aquarium/blob/master/doc/Location%20Wizard.md#location-wizards "Location Wizards"
