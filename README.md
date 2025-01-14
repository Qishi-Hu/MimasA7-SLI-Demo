# MimasA7-SLI-Demo

A demo version of the [MimasA7-SLI](https://github.com/Qishi-Hu/MimasA7-SLI) project. This version does not include the handshake protocol with the PC and camera, so it is not ready for integration with the customized PCB.

## Features

- **Pass-through Mode with Top-left Pixel Detetcion**: Works exactly as in the full version.
- **SD Pattern Generation Mode**:
  - Increments the frame index at every VSYNC (normal speed).
  - Increments the frame index every 32 VSYNC (1/32x speed).
- **Mode Selection**: Toggle between modes using two pushbuttons.

## Directory Structure
<pre>
├── README.md           # Overview of the repository  
├── Rev3_SD_HDMI_1.0.xpr    # Archive of the Vivado 2024.1 project  
├── Matlab/             # .m scripts and output files
├── Bitsrteam/          # Final bitstream files  
├── src_1/              # Source HDLand Matlab code  
├── sim_1/              # Test benches for simulation  
└── constr_1/           #  Xlinx Design Constarint  
</pre>
