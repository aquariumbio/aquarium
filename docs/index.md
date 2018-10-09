---
title: Aquarium
layout: default
---

# About

Aquarium allows a researcher to specify precisely how to perform an experimental protocol so that lab personnel will run the protocol the same way, every time.

Protocols encode how to manipulate Aquarium's inventory system (LIMS), compute formulae such as volumes, molarities, temperatures, and timing, as well as present lab technicians with images and detailed instructions.
Protocols also define formal unit operations with typed inputs and outputs – allowing the researcher to construct a complex workflow by linking an output sample of one protocol to an input of another using the Aquarium graphical workflow designer.

In the lab, protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took – data that can be used to debug and improve the experiment.
More importantly, Aquarium provides a complete, executable description of the results obtained – one that could be used by another lab running Aquarium to reproduce the result.

Aquarium is the operating system of the [UW BIOFAB](http://www.uwbiofab.org), a service of the [Klavins Lab](http://klavinslab.org) at the University of Washington.

# Documentation

- [Installation](installation/)
- [Concepts](concepts/)
- Research with Aquarium
  - Defining samples
  - [Designing plans (Designer)](designer/)
  - Viewing plan history (Plans)
  - [UW BIOFAB Protocols and Plans](biofab_protocols/)
- Lab Management
  - [Managing the lab (Manager)](manager/)
  - [Running jobs (Technician)](technician/)
- Aquarium Administration
  - [Managing users](users/)
  - [Managing budgets](budget_manager/)
- Lab Protocol Definition
  - [Defining Types](protocol_developer/types)
  - [Defining Location Wizards](protocol_developer/location)
  - [Developer Tools](protocol_developer/tools/)
  - [Protocol Tutorial](protocol_tutorial/)
  - Protocol Reference
    - [Data Associations](protocol_developer/associations/)
    - [Show Blocks](protocol_developer/show)
    - [Tables](protocol_developer/table)
  - [Protocol (Krill) API](api)
- [Trident Python API](http://klavinslab.org/trident)
- [Aquarium Development](aquarium_development/)

# [License](https://github.com/klavinslab/aquarium/blob/master/license.md)
