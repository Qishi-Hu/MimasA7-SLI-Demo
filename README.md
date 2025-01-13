# MimasA7-SLI-Demo

A demo version of the [MimasA7-SLI](https://github.com/Qishi-Hu/MimasA7-SLI) project. This version does not include the handshake protocol with the PC and camera, so it is not ready for integration with the customized PCB.

## Features

- **Pass-through Mode with Top-left Pixel Detetcion**: Works exactly as in the full version.
- **SD Pattern Generation Mode**:
  - Increments the frame index at every VSYNC (normal speed).
  - Increments the frame index every 32 VSYNC (1/32x speed).
- **Mode Selection**: Toggle between modes using two pushbuttons.
