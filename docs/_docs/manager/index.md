---
title: Manager Guide
layout: docs
permalink: /manager/
---

# Manager

_This document assumes that you have read the [Aquarium Concepts]({{ site.baseurl }}{% link _docs/concepts %}) document_

A manager uses Aquarium to determine which operations are run together as a job; to monitor and control jobs; and to help users with problematic plans.

## Table of Contents

<!-- TOC -->

- [Manager](#manager)
    - [Table of Contents](#table-of-contents)
    - [Relevant Views](#relevant-views)
        - [The Manager Tab](#the-manager-tab)
        - [The Plan Tab](#the-plan-tab)
        - [The Designer Tab](#the-designer-tab)
    - [Scenario: Monitoring lab activity](#scenario-monitoring-lab-activity)
    - [Scenario: Starting a job](#scenario-starting-a-job)
    - [Scenario: Correcting a bad plan](#scenario-correcting-a-bad-plan)
    - [other scenarios?](#other-scenarios)

<!-- /TOC -->

## Relevant Views

### The Manager Tab

The manager tab provides the information needed to manage lab operations as illustrated by this (redacted) screenshot of the manager tab for the UW BIOFAB production server.

![manager tab]({{ site.baseurl }}{% link _docs/manager/images/manager-view.png %})

This screenshot shows that there are five `Run Gel` operations (in the `Cloning` category) that are **pending**, or ready to execute.
(See [Starting a job](#scenario-starting-a-job) below for details on how run a job using these five operations.)

The controls at the left of the screen allow the manager to determine which operations are displayed on the right.
At the top left are display controls that include:

- **Switch User** – filter operations by user,
- **Active Jobs** – filter operations by jobs that are active, and
- **Activity Reports** – display job activity by date (in version X.X.X)

At the bottom left are the categories of the operation types available on this Aquarium instance.
The categories that currently have operations appear in black, and the rest are greyed-out.
The middle panel shows the operation status for the currently selected category.
Clicking on a number for a particular operation type and operation state shows the operations in the operations list panel to the right.

It is also possible to display completed operations by clicking the slider at the top of the operation status panel.

### The Plan Tab

### The Designer Tab

## Scenario: Monitoring lab activity

The left panel of the manager tab has two parts.
At the top are buttons that allows the manager to do common tasks they perform: switching to another user, displaying active jobs, and generating reports of activity.
At the bottom are buttons that control which categories of jobs are displayed in the right panel.
This example shows three categories _cloning_, _manager_ and _tutorial_neptune_ with the tutorial selected.
(These are the categories from the protocol development tutorial; in practice, there will be many more.)

![categories]({{ site.baseurl }}{% link _docs/manager/images/category-list.png %})

Once the category is selected, operation types will be displayed in the panel to the right of the buttons.
Unless the **Completed** slider is clicked, these will be operation types with currently active operations, otherwise those with completed operations will also be shown.
This example shows one operation type with an operation that is **pending**, which is the state of an operation that is ready to be performed by a technician.

![selected category]({{ site.baseurl }}{% link _docs/manager/images/selected-category.png %})

The operation states are explained in the [Aquarium Concepts]({{ site.baseurl }}{% link _docs/concepts/#operation-states %}) document.

## Scenario: Starting a job

From the Manager Tab, clicking the number in the pending spot will display all of the operations of the selected type and state.
These represent all of the jobs that can be selected and run as a job.

![selected operation]({{ site.baseurl }}{% link _docs/manager/images/selected-operation.png %})

Selecting the operations to be part of a job, and then clicking **run** starts the job

![jobs]({{ site.baseurl }}{% link _docs/manager/images/scheduled-job.png %})

Clicking the job id in this window will open the technician view that shows the job ready to start:

![technician-start]({{ site.baseurl }}{% link _docs/manager/images/technician-start.png %})

And, once the technician has started the job, the status will update in the operation status panel.

![changed status]({{ site.baseurl }}{% link _docs/manager/images/updated-status.png %})

## Scenario: Correcting a bad plan

## other scenarios?
