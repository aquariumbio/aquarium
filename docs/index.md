---
title: Aquarium
layout: default
---

# About

Aquarium is the software that runs the [UW BIOFAB](http://www.uwbiofab.org), a service of the [Klavins Lab](http://klavinslab.org) at the University of Washington.

Aquarium allows you to specify precisely how to perform an experimental protocol so that lab personnel will run the protocol the same way, every time. Protocols encoded a specially designed Ruby DSL called Krill specify how to manipulate Aquarium's inventory system (LIMS), compute formulae such has volumes, molarities, temperatures, and timing, as well as present lab technicians with images and detailed instructions. Protocols define formal unit operation types with typed, parametrizable inputs and outputs, allowing a researcher to construct a complex workflow by linking an output sample of one protocol to an input of another using graphical Aquarium's workflow designer.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took -- data that can be used to debug and improve the experiment. More importantly, Aquarium provides a complete, executable description of the results obtained – one that could be used by another lab running Aquarium to reproduce the result.

# Documentation

- [Installation](configuration/installation/)
- [Configuration](configuration/)
- [Concepts](concepts/)
- User Role Documentation:
  - [Manager](manager/)
  - [Technician](technician/)
  - [Workflow Designer](designer/)
  - [Protocol Developer](protocol_developer/)
- Development Documentation:
  - [Aquarium Development](aquarium_development/)
  - [Protocol Tutorial](protocol_tutorial/)
  - [Krill (Protocol) API](api)
  - [Trident Python API](https://github.com/klavinslab/trident)

# The Code in on [GITHUB](https://github.com/klavinslab/aquarium)

# [License](https://github.com/klavinslab/aquarium/blob/master/license.md)
