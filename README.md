# AQUARIUM : The Laboratory Operating System

Aquarium allows a researcher to specify precisely how to perform an experimental protocol so that lab personnel will run the protocol the same way, every time.

Protocols, written in a Ruby DSL called Krill, encode how to manipulate Aquarium's inventory system (LIMS), compute formulae such as volumes, molarities, temperatures, and timing, as well as present lab technicians with images and detailed instructions.
Protocols define formal unit operation types with typed inputs and outputs – allowing the researcher to construct a complex workflow by linking an output sample of one protocol to an input of another using the Aquarium graphical workflow designer.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took -- data that can be used to debug and improve the experiment.
More importantly, Aquarium provides a complete, executable description of the results obtained – one that could be used by another lab running Aquarium to reproduce the result.

Aquarium is the operating system of the [UW BIOFAB](http://www.uwbiofab.org), a service of the [Klavins Lab](http://klavinslab.org) at the University of Washington.

## Versions and Releases

- The latest version is available [here](https://github.com/klavinslab/aquarium/releases/latest). If you would like to stay current with bug fixes, the [master](https://github.com/klavinslab/aquarium/tree/master) branch should almost always be stable and only a few commits ahead of the latest version.

## Documentation

- User documentation, including installation instructions, can be found at [aquarium.bio](http://www.aquarium.bio).
- Developer documentation can be found <a href="http://klavinslab.org/aquarium/development/">here</a>.
