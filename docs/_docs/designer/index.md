---
title: Workflow Designer
layout: docs
permalink: /designer/
---

# Experimental Plan Designer

The plan designer allows you to string together operatons that should be applied to your samples. You can create complex experimental workflows, a.k.a. plans, with dozens of steps, associate specific samples and items from the inventory with their inputs, send the output of one operation to the input of another, estimate how much your plan will clost, monitor the progress of your plan as it is executed, and more. This document describes how to use every feature of the plan designer. It uses the operation types in Cloning workflow, which is included in the distrubition of Aquarium, as examples. Once you add your own operation types (using the Developer), you should be able manipulate them the same way. Besides the existence of the Cloning workflow in the designer, this document assumes you have populated the inventory with samples and items that can bs used for the inputs of plans. If not, you will need to add such inventory and reload the Designer.



## Loading the Designer

**Click on "Designer" on the main menu bar**: This should bring up the designer view, with the "Plans" tab highlighted on the left and the "Under Construction" folder of plans opened.

**Edit an existing plan**: In the Plans view, open a plan, click on the menu on the upper right of the opened plan, and choose "Edit/Design". This should bring up the designer view with the plan you chose already open. The "Plans" tab should be highlighted, the folder containing the plan should be open, and the plan id and number of the plan should be highlighted in orange.



## Creating, renaming, moving, saving, and deleting plans

**Create a new plan**:

**Rename a plan**:

**Save a plan**:

**Delete a plan**:

**Move a plan**:



## Building new plans

**Add operations**:

**Associate samples and items**:

Warning: The Designer page needs to be reloaded for it to see new samples. New items should show up if you simply reload the plan (using the Reload button in the main menu). If not, try saving your plan and reloading the page. 

**Associate parts of collections**:

**Add wires**:

**Use array inputs**:

**Adding predecessors and successors**:

**Seeing whether a plan is valid**:

**Annotating a plan with textboxes**:



## Using modules

**Creating and opening a module:**

**Editing the name and documentation for a module**:

**Adding inputs and outputs to a module:**




## Using templates

**Using system templates:**

**Creating your own templates:**

**Promoting and demoting templates:**



## Launching plans

**Fixing validation errors**:

**Calculating costs**:

**Choosing a budget**:

**Launching**:



## Viewing progress and testing plans in the Manager (Development/Nursery)

**Running an operation as a technician**:

**Running an operation non-interactively**:

**Reloading plans**:



## Viewing / Editing data associated with a plan

**Viewing and associating values and files with a plan**:

**Viewing and associating values and files with an operation**:

**Viewing and associating values and files with an item**:



## Editing plans

**Retrying operations**:

**Modifying a plan's connectivity**:

**Adding new operations**:

**Canceling an operation**:

**Modifying which items are used by an operation**:

**Stepping a plan**:


