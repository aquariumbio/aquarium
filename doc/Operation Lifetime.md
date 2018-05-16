# Aquarium Operation Lifetime

## Operation Status

The status of an operation is one of the following.

**planning**:

**primed**:

**waiting**:

**pending**:

**scheduled**:

**running**:

**done**:

**error**:

## Transitions

The following actions change an operations's status.

## On the Fly Operations

To run a gel, you need to pour a gel.
How many gel lanes, and
thus how many gels, is not known until some number of run gel
operations are batched.
Once they are batched, then and only then should the same number of pour gel
operations also be batched.

If this is not done, then the manager would see a number of ready pour gels and a number of waiting run gels.
If they
pour a bunch of gels for a specific set of operations, then the pour gel job would associate operations with specific lanes in the pour gels.
The manager would then have to very carefully make sure to run exactly the same operations in the subsequent run gel.

Thus, specifying an operation type as "on the fly" will have the following effect.
When the Aquarium takes a step, the status of any "on the fly" operation whose predecessors are done (or that do not have predecessors) will be set to "primed".
Once its successor is batched, it's status will be set to "pending".
