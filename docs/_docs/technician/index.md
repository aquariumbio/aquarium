---
title: Technician Guide
layout: docs
permalink: /technician/
---
# Technician

When using Aquarium, a technicians primarily interacts with protocols, each of which will have their own details.

Aquarium does track which users runs which jobs as a technician, so technicians should login separately rather than using someone else's login.

## Running a Job

A job is scheduled from the [manager interface]({{ site.baseurl }}{% link _docs/manager/#scenario-starting-a-job %}), and results in a screen like this on the **Manager Tab**:

![jobs]({{ site.baseurl }}{% link _docs/technician/images/scheduled-job.png %})

Clicking on a pending job opens the technician interface for that job.
This page has a **start** button that will start the job.

![technician-start]({{ site.baseurl }}{% link _docs/technician/images/technician-start.png %})

At this point, the protocol runs and displays instructions on the screen.
When done with the instructions on the page, clicking **OK** at the top of the page will move the protocol to the next screen.

![running-job]({{ site.baseurl }}{% link _docs/technician/images/running-job.png %})

If you jumped ahead before finishing, you can move back with the arrows, or by selecting the protocol steps by clicking the names in the **Steps** list to the left.

This simple protocol only has one screen, so clicking **OK** results in the completion page being displayed.

![complete run]({{ site.baseurl }}{% link _docs/technician/images/complete-protocol.png %})

This page shows the different operations types that the user has previously completed.

## Technician Interface Features



![ops-list]({{ site.baseurl }}{% link _docs/technician/images/ops-list.png %})
![timer]({{ site.baseurl }}{% link _docs/technician/images/timer.png %})
![uploads-list]({{ site.baseurl }}{% link _docs/technician/images/uploads-list.png %})

