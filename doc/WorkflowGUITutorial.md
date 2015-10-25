# Workflow GUI Tutorial

## Prerequisites
 - Be always using Chrome.
 
## Selecting a Workflow

## Launching a Workflow

Now that the "Streak Plate" workflow has been carefully described, make sure you've saved, and click "Launch." You will be taken to a launch screen where you can build one or more [**threads**][threads]. Here, you'll see the inputs for both of our operations listed; these are essentially the inputs for the workflow. Each thread, in this case, corresponds to a single strain of yeast. Typically, someone performing an operation from this workflow in the lab will operate on many strains simultaneously. Let's say we have two different types of strain we want to clone, so we build two threads to launch in this workflow, one for each strain type.

Start typing "434: pMOD-8-pRPR1-gRNAc3" into both cells of the table, and select them in the drop-down when they appear. Then click "Add." Now do the same with "434: pMOD-8-pRPR1-gRNAc3."

![build_threads](images/workflow_tutorial/build_threads.png)

Note: To more fully understand what we're doing in this step, it is necessary to understand the differences between **sample types**, **samples**, and **items**. You can read up on them [here][sample types, samples, and items]. Here, the sample type is "Yeast Strain," the samples are "434: pMOD-8-pRPR1-gRNAc3" and "435: pMOD-8-pRPR1-gRNAc7," and the items are the physical strains in the lab located by the [M80 location wizard][location wizards]. We could, for example, build three threads each with the sample name "434: pMOD-8-pRPR1-gRNAc3," and the location wizard would try to find three different items of that sample when someone runs one of the operations of this workflow.

Note: The "Yeast Glycerol Stock" and "Streaked Yeast Plate" inputs must be of the same sample because the type of yeast strain (the sample) has not changed between the two operations "Streak Plate" and "Image Plate."

### To Debug or Not to Debug?

## Reading Errors

## Questions
 - Who is the intended audience? The "expert" should only have to link up operations, while the "programmer" will need to add inputs/outputs and write protocol code.
 - How's my definition of "thread"?
 - Is that a bug that we have to define the sample for both inputs?

[threads]: https://github.com/klavinslab/aquarium/blob/master/doc/WorkflowProtocolAPI.md#threads "Threads"
[sample types, samples, and items]: https://github.com/klavinslab/aquarium/blob/master/doc/Krill.md#items-objects-and-samples "Sample Types, Samples, and Items"
[location wizards]: https://github.com/klavinslab/aquarium/blob/master/doc/Location%20Wizard.md#location-wizards "Location Wizards"
