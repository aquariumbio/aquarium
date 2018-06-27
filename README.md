# AQUARIUM : The Laboratory Operating System

Aquarium gives you the means to specify, as precisely as possible, how to obtain an experimental result.
Researchers encode protocols in Krill, the Aquarium protocol language, specifying how to manipulate items in the Aquarium inventory (test tubes, regents, DNA samples, 96 well plates, etc.) using a combination of formal statements, informal descriptions, and photographs.
Protocols are parameterized by "tuning knobs" (such as incubation times or reagent concentrations) that can be varied when the protocols are scheduled.
The researcher strings together protocols into processes, specifying how the output samples of one protocol become the inputs to other protocols, and how protocols can be scheduled, parallelized, and controlled.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took. The data can be used to debug and improve the experiment.
More importantly it provides a complete, executable description of the results obtained -- one that could be used by another lab running Aquarium to reproduce the result.

## Documentation

- [Aquarium Project Pages](http://klavinslab.org/aquarium)
  - [Configuration](http://klavinslab.org/aquarium/configuration/)
  - [Concepts](http://klavinslab.org/aquarium/concepts/)
  - User Role Documentation:

    - [Manager](http://klavinslab.org/aquarium/manager/)
    - [Technician](http://klavinslab.org/aquarium/technician/)
    - [Workflow Designer](http://klavinslab.org/aquarium/designer/)
    - [Protocol Developer](http://klavinslab.org/aquarium/protocol_developer/)
  
  - Development Documentation

    - [Aquarium Development](http://klavinslab.org/aquarium/aquarium_development/)
    - [Protocol Tutorial](http://klavinslab.org/aquarium/protocol_tutorial/)
    - [Krill (Protocol) API](api)
    - [Trident Python API](https://github.com/klavinslab/trident)
  
- Videos

  - [Populating Inventory](https://www.youtube.com/watch?v=ydN51ew1JmI&feature=youtu.be) : Video describing how to manage and create samples.
  - [Planning Experiments](https://www.youtube.com/watch?v=kYnDc8RIsNg&feature=youtu.be) : Video describing how to build an experimental workflow.
  - [Building a Workflow](https://www.youtube.com/watch?v=xDrv4f2AZlM&feature=youtu.be) : Video / Old version
  - [Monitoring a Plan](https://www.youtube.com/watch?v=WCTmuz5yBAo&feature=youtu.be) : Video on how to track an experiment as it is being run.

Aquarium is a project of the [Klavins Lab](http://klavinslab.org).
