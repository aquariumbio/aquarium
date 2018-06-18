---
layout: default
---

Aquarium is the software that runs the UW BIOFAB...

Aquarium gives you the means to specify, as precisely as possible, how to obtain an experimental result.
Researchers encode protocols in Krill, the Aquarium protocol language, specifying how to manipulate items in the Aquarium inventory (test tubes, regents, DNA samples,, 96 well plates, etc.) using a combination of formal statements, informal descriptions, and photographs. Protocols are parameterized by "tuning knobs" (such as incubation times or reagent concentrations) that can be varied when the protocols are scheduled. The researcher strings together protocols into processes, specifying how the output samples of one protocol become the inputs to other protocols, and how protocols can be scheduled, parallelized, and controlled.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took. The data can be used to debug and improve the experiment. More importantly it provides a complete, executable description of the results obtained -- one that could be used by another lab running Aquarium to reproduce the result.

# Documentation

* [Configuration](docs/configuration/)
* User Role Documentation:
  * [Manager](docs/manager/)
  * [Technician](docs/technician/)
  * [Researcher/Experiment Designer](docs/designer/)
  * [Protocol Developer](docs/protocol_developer/)
* [Development Documentation](docs/aquarium_development/)
