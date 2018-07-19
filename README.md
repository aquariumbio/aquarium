# AQUARIUM : The Laboratory Operating System

Aquarium allows a researcher to specify precisely how to perform an experimental protocol so that lab personnel will run the protocol the same way, every time.

Protocols are written in a Ruby DSL called Krill, and encode how to manipulate Aquarium's inventory system (LIMS), compute formulae such as volumes, molarities, temperatures, and timing, as well as present lab technicians with images and detailed instructions.
Protocols define formal unit operation types with typed inputs and outputs – allowing the researcher to construct a complex workflow by linking an output sample of one protocol to an input of another using the Aquarium graphical workflow designer.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took -- data that can be used to debug and improve the experiment.
More importantly, Aquarium provides a complete, executable description of the results obtained – one that could be used by another lab running Aquarium to reproduce the result.

Aquarium is the operating system of the [UW BIOFAB](http://www.uwbiofab.org), a service of the [Klavins Lab](http://klavinslab.org) at the University of Washington.

## Versions and Releases

- The latest version is available [here](https://github.com/klavinslab/aquarium/releases/latest). If you would like to stay current with bug fixes, the [master](https://github.com/klavinslab/aquarium/tree/master) branch should always be stable and only a few commits ahead of the latest version. If you would like to play with the latest new features or help develop Aquarium, check out the [staging](https://github.com/klavinslab/aquarium/tree/staging) branch.  

## Documentation

- [Aquarium Project Pages](http://klavinslab.org/aquarium)
  - [Installation](http://klavinslab.org/aquarium/configuration/installation/)
  - [Configuration](http://klavinslab.org/aquarium/configuration/)
  - [Concepts](http://klavinslab.org/aquarium/concepts/)
  - User Role Documentation:
    - [Manager](http://klavinslab.org/aquarium/manager/)
    - [Technician](http://klavinslab.org/aquarium/technician/)
    - [Workflow Designer](http://klavinslab.org/aquarium/designer/)
    - [Protocol Developer](http://klavinslab.org/aquarium/protocol_developer/)
  - Development Documentation:
    - [Aquarium Development](http://klavinslab.org/aquarium/aquarium_development/)
    - [Protocol Tutorial](http://klavinslab.org/aquarium/protocol_tutorial/)
    - [Krill (Protocol) API](http://klavinslab.org/aquarium/api)
    - [Trident Python API](https://github.com/klavinslab/trident)
- Videos
  - [Populating Inventory](https://www.youtube.com/watch?v=ydN51ew1JmI&feature=youtu.be) : Video describing how to manage and create samples.
  - [Planning Experiments](https://www.youtube.com/watch?v=kYnDc8RIsNg&feature=youtu.be) : Video describing how to build an experimental workflow.
  - [Building a Workflow](https://www.youtube.com/watch?v=xDrv4f2AZlM&feature=youtu.be) : Video / Old version
  - [Monitoring a Plan](https://www.youtube.com/watch?v=WCTmuz5yBAo&feature=youtu.be) : Video on how to track an experiment as it is being run.

Aquarium is a [Klavins Lab](http://klavinslab.org) project.
