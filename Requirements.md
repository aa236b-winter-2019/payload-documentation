# Payload Subsystem Requirements

1. The payload shall conform to the mechanical specifications of the PC/104 Specification v2.6.
2. Materials used shall be compliant with the outgassing specifications in the CubeSat Design Specification rev. 13.
3. The payload shall include a single-board computer capable of running GNURadio.
4. The payload shall include a software-defined radio with a frequency stability of a 0.5 ppm or better capable of receiving signals from 400-440 MHz.
5. The payload shall include a GPS receiver for precision timing and orbit determination.
6. The payload interface with the motherboard shall include regulated power, a UART serial data connection between the single-board computer and the ARM microcontroller, and a master enable pin to that completely powers off the payload when pulled low.
7. A port to allow programming of the single-board computer shall be accessible from the outside of the spacecraft.
