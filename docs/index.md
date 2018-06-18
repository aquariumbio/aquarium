---
layout: default
---

# About

Aquarium is the software that runs the [UW BIOFAB](http://www.uwbiofab.org) a service in the [Klavins Lab](http://klavinslab.org) at the University of Washington.

Aquarium makes it possible to specify how to obtain an experimental result in a lab.
Protocols encoded in the Aquarium protocol language specify how to manipulate items in the inventory, and describe the capabilities the lab provides to researchers.
Protocols are parameterized, allowing a researcher to construct a complex workflow by linking an output sample of one protocol to an input of another.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took.
The data can be used to debug and improve the experiment.
More importantly it provides a complete, executable description of the results obtained – one that could be used by another lab running Aquarium to reproduce the result.

# Documentation

* [Configuration](docs/configuration/)
* User Role Documentation:
  * [Manager](docs/manager/)
  * [Technician](docs/technician/)
  * [Researcher/Experiment Designer](docs/designer/)
  * [Protocol Developer](docs/protocol_developer/)
* Development Documentation
  * [Aquarium Development Guide](docs/aquarium_development/)
  * [API](docs/api)

# [License](https://github.com/klavinslab/aquarium/blob/master/license.md)
