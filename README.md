![](https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/HedgeHog_Logo.png )
## HedgeHog Fused Spiking Neural Network Emulator/Compute Engine for RISC-V
(April 25, 2023) The 1st and 2nd Divisional patents to parent US Patent No. US11275584-B2 have been officially issued at the USPTO.  A .pdf for each has been added to this repository for your convenience.  These .pdfs contain only the portions that are different from the original parent (i.e., face page with abstract and Claims pages.)  Here are the links:

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/US_11635957_B2_P1.pdf

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/US_11635956_B2_P1.pdf


(March 16, 2022) The Universal Floating-Point ISA (parent application) issued as US Patent No. US11275584B2.  It can be downloaded using the following link:

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/US-11275584-B2_I.pdf


(March 13, 2021) The Universal Floating-Point ISA specification specification is now published. It can be downloaded using the following link:

https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/Universal_ISA_Publication.pdf

(June 28, 2020) ASM folder now includes simple demo for 16x16 and 32x32 single layer SNN using untrained weights.  Original demo was only 8x8.  The test bench now defaults to 32x32, but you can still go back to 8x8 or 16x16 by removing comments.  To run the 32x32 demo, place the spikeDemo32x32.HEX and weights_32x32.txt files in the Vivado simulation working directory as explained below.  Also, a couple bugs were fixed in the SpiNNe RTL, so you will need to update with these files before running the 32x32 demo.

(May 3, 2020)   Created specifically for incorporation into a simplified mover “shell” version of the SYMPL 64-bit Universal Floating-Point Compute Engine, this memory-mapped Fused Spiking Neural Network (FSNN) is designed for ready implementation within the programmable fabric of Xilinx® Kintex® UltraTM Plus brand FPGAs. This implementation, including the SYMPL mover “shell” that houses it and makes it go, consumes only 33% of the LUTs in Xilinx's smallest Kintex Ultra Plus device and will clock at over 100MHz in the -3 speed grade.

![](https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/RISC_V_HedgeHog_Blk.png )

Dubbed the “HedgeHog” because it does this one thing so very well, it implements in hardware qty. (8) neuron membranes with qty. (8) programmable 128-tick input spike integrators each, 4096-tick real-time trace buffers for all dendrite output levels, all membrane output levels, slope computations, distance/error computations, time exponential computations, etc., such computations being done automatically in hardware using its qty. (72) multiply, (72) division, (88) addition, (72) exponential and (8) compare hardware (or equivalent) operators. Thus, clocking at 100MHz in a Xilinx Kintex Ultra Plus, it can perform roughly qty. (312) floating-point operations per clock cycle or roughly 31 billion floating-point operations per second. The Accumulate and Activate bits in the mover shell instruction set enable concatenation of these (8) neuron membranes to build layers with up to qty. (512) inputs and outputs each.
The real-time monitor and data exchange feature of the mover shell enables a RISC-V or other CPU to read and write from/to the HedgeHog resources as if ordinary memory.
The Verilog test bench available at the SYMPL HedgeHog repository at GitHub automatically converts human-readable decimal character sequences for weights and thresholds, enabling you to create your test data using Google Sheets online spreadsheet. When your test
run is complete, the test bench then automatically converts the binary formatted floating-point trace buffer results from each dendrite and membrane level to decimal character sequences before writing them to their respective output files, enabling you to view your results in numeric or graphic form using Google Sheets online spreadsheet. For examples of resulting graphs on data produced by the Verilog test bench simulations, refer to the “HedgeHog.pdf” document below.  If you are exploring or experimenting with spiking neural networks for FPGA embeddable AI applications using RISC-V as host CPU, then the SYMPL HedgeHog is for you. 

Here is a .pdf information sheet on the HedgeHog FSNN Emulator/Compute Engine:

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/HedgeHog.pdf 

## Simulating in Xilinx Vivado IDE
All the Verilog RTL source files that you will need are located in the “RTL", "ASM", "test bench", and "sim" folders at this repository.  The top level module is “HedgeHog.v”.  It is suggested that when creating your project in Vivado the first time, you select the Xilinx Kintex Ultra+ xcku5p-ffvd-900-3-e as your target device.  After creating your project in Vivado, you will need to click on the “Compile Order” tab, click on “HedgeHog” and slide it up to the top.  Under the "Sources" tab, at the bottom of the panel, click "hierarchy", then right-click on "HedgeHog" and select "Set as Top" if not already in bold font.  

The next step is to pull the “SpiNNe_tb.v” test bench file into Vivado as your stimulus.  Then slide down to "Simulation Sources">"sim_1" and do the same thing for the test bench, "SpiNNe_tb.v" as you did for "HedgeHog", setting it as "top" in the simulation sources. 

Once you've done that, click on “Run Simulation”.  After doing that, you will notice that the simulation fails.  This is because the simulation requires the “spikeDemo.HEX” program for the HedgeHog to execute. So to fix that, paste the “spikeDemo.HEX” file into the simulation working directory at:  C:\projectName\projectName .sim\sim_1\behav\xsim\ “spikeDemo.HEX” and assembly language source and object listing can be found in the “ASM” folder.  

Next, the demonstration simulation, which simply pushes a series of spikes into the HedgeHog, requires the “spike_trains.txt” spike input file and the “weights.txt” file located in the “sim” folder,  so paste  these two files in the same working directory that you placed the “spikeDemo .HEX” file.

Once you've done that, click on the “Run Simulation” button again to launch the simulation.

When the simulation is complete, you should be able to find seven new .txt files in the same working directory as a result of the simulation.  These are:
1) dendrite.txt, which contains decimal character floating-point representations of the contents of the HedgeHog dendrite trace buffer;
2) output levels.txt, which contains decimal character floating-point representations of the contents of the eight membranes' output level trace buffer;
3) slopeAmounts.txt, which contains decimal character floating-point representations of the contents of the slopes trace buffer;
4) errAmounts.txt, which contains the contents of the distance/error computations trace buffer;
5) exponentials.txt, which contains the contents of the time exponentials trace buffer;
6) softMax.txt, which contains the softMax computed for each membrane that fired; and
7) summation.txt, which contains the summation of all the time exponentials.

These files are in .txt form so they can be viewed and plotted using Google Sheets online spreadsheet.  Here is a link where you can view the results of this demo simulation run using Google Sheets:

https://docs.google.com/spreadsheets/d/1R1bdN-xH0Cou0wdah1Oj3k0VNP_2UTwp1fSHnL2JVNc/edit#gid=2851398 

For information on what the demonstration does, refer to the assembly language object listing in the “ASM” folder and the “SpiNNe_tb .v” test bench source code.

For information on the HedgeHog instruction set and assembler, refer to the SYMPL64.tbl instruction table located in the ASM folder.  You can also get even more detailed information by reviewing/downloading the “UFP_ISA.pdf” documentation here:

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/UFP_ISA.pdf

## Packages Omitted
You may quickly notice that the IEEE754-2008 floating-point operators, integer and logical operators, and XCUs have been omitted from this publication.  I omitted them mainly because the HedgeHog does not require them and I didn't want those evaluating the underlying ISA architecture to get lost in the details.  However, if you would like to evaluate them, please let me know and I'll see what I can do to get you set up with that.

Enjoy!
