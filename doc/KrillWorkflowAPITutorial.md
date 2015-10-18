# Krill Workflow API Tutorial

Note: Use Chrome.

## Starting a New Workflow
A **workflow** is a set of interconnected **operations**, each with a set of inputs and outputs, that collectively describe the inputs and outputs of the workflow. The important thing is that a workflow describes the *relationship* between bits of code known as [**protocols**][krill] (one contained within each operation), while the operations themselves are *input/output specifications* of protocols, code that programmers have written to define a set of instructions for someone in the lab. This tutorial covers everything you should need to know to specify operations, link them together, and launch and debug a workflow like a champ.

To create a new workflow, first navigate to the workflow index.

![new_workflow_index](images/workflow_tutorial/index.png)

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

#### Adding Exceptions

### Creating Another Operation

## Launching the Workflow
link to threads
### To Debug or Not to Debug?

## Reading Errors

## Editing Protocol Code
link to WorkflowProtocolAPI.md

## Questions
Who is the intended audience? The "expert" should only have to link up operations, while the "programmer" will need to add inputs/outputs and write protocol code.
NOTE: It's super handy for tutorials to be able to link to other tutorials and even handier for them to be able to link to certain headings ("Threads" in WorkflowProtocolAPI.md, for example). Is this possible with both potential "wiki methods"?
C:\Users\Garrett\Desktop\UW\Klavins Lab\Aquarium\Krill Workflow API Tutorial\Images

[Krill]: https://github.com/klavinslab/aquarium/blob/master/doc/Krill.md#authoring-protocols-for-aquarium "Authoring Protocols for Aquarium"
