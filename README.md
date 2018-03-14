AQUARIUM : The Laboratory Operating System
=========

About
---

Aquarium gives you the means specify, as precisely as possible, how to obtain an experimental result. Researchers encode protocols in Krill, specifying how to manipulate items in the Aquarium inventory (test tubes, regents, DNA samples,, 96 well plates, etc) using a combination of formal statements, informal descriptions, and photographs. Protocols are parameterized by "tuning knobs" (such as incubation times or reagent concentrations) that can be varied when the protocols are scheduled. The researcher strings together protocols into processes, specifying how the output samples of one protocol become the inputs to other protocols, and how protocols can be scheduled, parallelized, and controlled.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab. Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took. The data can be used to debug and improve the experiment. More importantly it provides a complete, executable description of the results obtained -- one that could be used by another lab running Aquarium to reproduce the result.

Aquarium is a product of the [Klavins Lab](http://klavinslab.org).

Installation
---

* [Installation](doc/Installation.md) : How to install Aquarium.
* [Dockerized Aquarium](https://github.com/klavinslab/aquadocked) : Makes Aquarium relatively easy to install and run.

User Documentation
---
 
* [Populating Inventory](https://www.youtube.com/watch?v=ydN51ew1JmI&feature=youtu.be) : Video describing how to manage and create samples.
* [Planning Experiments](https://www.youtube.com/watch?v=kYnDc8RIsNg&feature=youtu.be) : Video describing how to build an experimental workflow.
* [Building a Workflow](https://www.youtube.com/watch?v=xDrv4f2AZlM&feature=youtu.be) : Video / Old version 
* [Monitoring a Plan](https://www.youtube.com/watch?v=WCTmuz5yBAo&feature=youtu.be) : Video on how to track an experiment as it is being run.
* [Managing the Lab](http://todo.com) : TODO
* [Defining new Sample Types](http://todo.com) : TODO
* [Locations](doc/Locations.md) : Aquarium's freezer location system.

Documentation for Protocol Authors
---

* [Developer Interface](http://todo.com) : How to develop protocols using the Aquarium IDE.
* [Krill](doc/Krill.md) : How to write protocols in Ruby using Aquairum's Krill Library.
* [Operations](doc/Opertations.md) : How to handle operations in protocol code.
* [Data Associations](doc/DataAssociation.md) : How to associate data with items, operations, and plans.
* [Aquarium/Krill API Reference](http://klavinslab.org/aquarium-api/) : Detailed method reference.
