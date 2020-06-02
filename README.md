# AQUARIUM : The Laboratory Operating System

Aquarium allows a researcher to specify precisely how to perform an experimental protocol so that lab personnel will run the protocol the same way, every time.

Protocols, written in a Ruby DSL called Krill, encode how to manipulate Aquarium's inventory system (LIMS), compute formulae such as volumes, molarities, temperatures, and timing, as well as present lab technicians with images and detailed instructions.
Protocols define formal unit operation types with typed inputs and outputs – allowing the researcher to construct a complex workflow by linking an output sample of one protocol to an input of another using the Aquarium graphical workflow designer.

Protocols and processes are scheduled and presented to technicians on touchscreen monitors placed throughout the lab.
Every step is logged: who performed the step, which items were used, what data was gathered by which instruments, and how long it took -- data that can be used to debug and improve the experiment.
More importantly, Aquarium provides a complete, executable description of the results obtained – one that could be used by another lab running Aquarium to reproduce the result.

Aquarium is the operating system of the [UW BIOFAB](http://www.uwbiofab.org), a service of the [Klavins Lab](http://klavinslab.org) at the University of Washington.

## Users

Users should start at [Aquarium.bio](http://www.aquarium.bio).

## Developers

Developers should start with the [developer documentation](http://klavinslab.org/aquarium/development/).
