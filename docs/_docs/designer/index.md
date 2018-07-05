---
title: Workflow Designer
layout: docs
permalink: /designer/
---

# Plan Designer

The plan designer allows you to string together operatons to be applied to your samples. You can create complex experimental workflows, a.k.a. plans, with dozens of steps, associate specific samples and items from the inventory with their inputs, send the output of one operation to the input of another, estimate how much your plan will clost, monitor the progress of your plan as it is executed, and more. This document describes how to use every feature of the plan designer. It uses the operation types in Cloning workflow, which is included in the distrubition of Aquarium, as examples. Once you add your own operation types (using the Developer), you should be able manipulate them the same way. Besides the existence of the Cloning workflow in the designer, this document assumes you have populated the inventory with samples and items that can bs used for the inputs of plans. If not, you will need to add such inventory and reload the Designer.

<!-- TOC -->

## Table of Contents

- [Designer](#plan-designer)
    - [Table of Contents](#table-of-contents)
    - [Loading the Designer](*loading-the-designer)
    - [Manipulating plans](*manipulating-plans)
    - [Building new plans](*building-new-plans)
    - [Using modules](*using-modules)
    - [Using templates](*using-templates)
    - [Launching plans](*launching-plans)
    - [Viewing progress](*viewing-progress)
    - [Data associated with a plan](*data-associated-with-a-plan)
    - [Editing plans](*editing-plans)

## Loading the Designer

**Click on "Designer" on the main menu bar**: This should bring up the designer view, with the "Plans" tab highlighted on the left and the "Under Construction" folder of plans opened.

**Edit an existing plan**: In the Plans view, open a plan, click on the menu on the upper right of the opened plan, and choose "Edit/Design". This should bring up the designer view with the plan you chose already open. The "Plans" tab should be highlighted, the folder containing the plan should be open, and the plan id and number of the plan should be highlighted in orange.



## Manipulating plans

**Create a new plan**: Click on the `New` icon on the upper right of the designer. If you have an existing plan open, the designer will ask if you would like to save it first. Click Yes or No. The new plan will be empty and titled "Untitled Plan". At this point, the plan exists only in your browser, and has not been saved. Navigating away from it before saving it will discard your work.

**Rename a plan**: The name of the plan appears at the top of designer in an editable input box. You can change the name to whatever you want. The new name will not be saved unless you click the `Save` icon.

**Save a plan**: Click the `Save` icon. Your plan will be given an ID number, which shown next to the plan's name. The plan ID and name will also show up at the top of the Unsorted folder on the left when the `Plans` tab is selected, and it will be highlighted in orange, indicating that the plan is open.

**Open a plan**: All of your plans are listed in the folders on the left when the `Plans` tab is selected. New plans are automatically put in the "Under Construction" folder. Once a plan is launched (see below), it will be moved to the "Unsorted" folder. Other folders may be present as well. To open a folder and find a plan you would like to open, click the triangles next to the folder names to open them. To open an existing plan, click on the name of the plan in the list. To open a plan, click on the name. You will be prompted to save whatever plan is currently open before the plan you clicked on is loaded. Only one plan at a time can be open in the designer.

**Copy a plan**: To make a copy of a plan, open it and then click the `Copy` icon on the upper right of the designer. This will make a new plan, with a new ID, with the same name as the existing plan but with `(copy)` appened to the name. It will close the source plan and open the new plan. If any operations in the source plan are active, the copies of those operations in the new plan will be put back into the "planning" stage. 

**Delete a plan**: Only plans that have not been launched can be deleted. You can either click the &times; symbol next to the plan's name in the "Under Construction" folder, or you can open the plan and click the `Trashcan` icon. A dialog box asking if you are sure you would like to delete the plan should be presented to you.

**Move a plan**: Any plan that has been launched (i.e. it is not in the "Under Construction" folder) can be moved to another folder. To do so, select the plan (or plans) you would like to move by clicking in the checkbox next to the name of the plan and then clicking the &#8680; icon. Choose the destination folder from the dropdown menu showing names of existing folders, or choose "New Folder" to create a new folder with the selected plans it in.

**View/Edit another user's plans**: If you are in the `admin` group, you can view and edit another user's plans by choosing their user name from the list of user names at the bottom of the left sidebar when the "Plans" tab is selected. When acting as another user, the left sidebar will show the name of that user highlighted in yellow.


## Building new plans

**Add operations**:

**Associate samples and items**:

Note: The Designer page needs to be reloaded for it to see new samples. New items should show up if you simply reload the plan (using the Reload button in the main menu). If not, try saving your plan and reloading the page. 

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



## Viewing progress

**Understanding plan status**: 

**Reloading plans**:

**Running an operation as a technician**:

**Running an operation non-interactively**:





## Data associated with a plan

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


