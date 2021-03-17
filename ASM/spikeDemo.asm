;//
;// Author:  Jerry D. Harthcock
;// Version:  1.22  May 3, 2020
;// Copyright (C) 2020.  All rights reserved.
;//
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                                                                                                                    //
;//                                                 SYMPL Open-Source                                                  //
;//                          HedgeHog Fused Spiking Neural Network Emulator/Compute Engine                             //
;//                                    Evaluation and Product Development License                                      //
;//                                                                                                                    //
;//                                                                                                                    //
;// Open-source means:  this source code and this instruction set ("this IP") may be freely downloaded, copied,        //
;// modified, distributed and used in accordance with the terms and conditons of the licenses provided herein.         //
;//                                                                                                                    //
;// Provided that you comply with all the terms and conditions set forth herein, Jerry D. Harthcock ("licensor"),      //
;// the original author and exclusive copyright owner of this HedgeHog Fused Spiking Neural Network Emulator/Compute   //
;// Engine, including related development software ("this IP"), hereby grants recipient of this IP ("licensee"),       //
;// a world-wide, paid-up, non-exclusive license to implement this IP within the programmable fabric of Xilinx Kintex  //
;// Ultra Plus brand FPGAs--only--and used only for the purposes of evaluation, education, and development of end      //
;// products and related development tools.                                                                            //
;//                                                                                                                    //
;// Furthermore, limited to the purposes of prototyping, evaluation, characterization and testing of implementations   //
;// in a hard, custom or semi-custom ASIC, any university or institution of higher education may have their            //
;// implementation of this IP produced for said limited purposes at any foundary of their choosing provided that such  //
;// prototypes do not ever wind up in commercial circulation, with this license extending to such foundary and is in   //
;// connection with said academic pursuit under the supervision of said university or institution of higher education. //
;//                                                                                                                    //
;// Any copying, distribution, customization, modification, or derivative work of this IP must include an exact copy   //
;// of this license and original copyright notice at the very top of each source file and any derived netlist, and,    //
;// in the case of binaries, a printed copy of this license and/or a text format copy in a separate file distributed   //
;// with said netlists or binary files having the file name, "LICENSE.txt".  You, the licensee, also agree not to      //
;// remove any copyright notices from any source file covered or distributed under this Evaluation and Product         //
;// Development License.                                                                                               //
;//                                                                                                                    //
;// LICENSOR DOES NOT WARRANT OR GUARANTEE THAT YOUR USE OF THIS IP WILL NOT INFRINGE THE RIGHTS OF OTHERS OR          //
;// THAT IT IS SUITABLE OR FIT FOR ANY PURPOSE AND THAT YOU, THE LICENSEE, AGREE TO HOLD LICENSOR HARMLESS FROM        //
;// ANY CLAIM BROUGHT BY YOU OR ANY THIRD PARTY FOR YOUR SUCH USE.                                                     //
;//                                                                                                                    //
;// Licensor reserves all his rights, including, but in no way limited to, the right to change or modify the terms     //
;// and conditions of this Evaluation and Product Development License anytime without notice of any kind to anyone.    //
;// By using this IP for any purpose, licensee agrees to all the terms and conditions set forth in this Evaluation     //
;// and Product Development License.                                                                                   //
;//                                                                                                                    //
;// This Evaluation and Product Development License does not include the right to sell products that incorporate       //
;// this IP or any IP derived from this IP. If you would like to obtain such a license, please contact Licensor.       //
;//                                                                                                                    //
;// Licensor can be contacted at:  SYMPL.gpu@gmail.com or Jerry.Harthcock@gmail.com                                    //
;//                                                                                                                    //
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


           CPU  "SYMPL64.TBL"
           HOF  "bin32"
           WDLN 8


expTimeBuff:   equ  0x00102000     ;  0x00110000-0x00117FFF  exponentiated time (for possible use with SoftMax, etc)
slopeBuff:     equ  0x00101000     ;  0x00108000-0x0010FFFF  slope (direction and amount from previous) buffer
errBuff:       equ  0x00100000     ;  0x00100000-0x00107FFF  error (distance from firing threshold) buffer
dendBuff:      equ  0x000C0000     ;  0x000C0000-0x000FFFFF  dendrite front-end result buffer
ratesMem:      equ  0x00080000     ;  0x00080000-0x0008FFFF  charging rates memory
binWeightsMem: equ  0x00040000     ;  0x00040000-0x0007FFFF  binary floating-point weights memory
threshMem:     equ  0x00018000     ;  0x00018000-0x0001FFFF  binary floating-point thresholds memory
accumSums:     equ  0x00010000     ;  0x00010000-0x00017FFF  accumulated sums memory
spikeOutMem:   equ  0x00008000     ;  0x00008000-0x0000FFFF  spike output/result storage memory
SNNinput:      equ  0x00004000     ;  0x00004000-0x00004FFF  SNN spike train target input
spikeSrcMem:   equ  0x00002000     ;  0x00002000-0x00003FFF  spike train source storage

_1.25:         equ  0x3F40         ;  binary7/8 representation of 1.25 decimal                  
_2.5:          equ  0x4040         ;  binary7/8 representation of 2.5 decimal  
_3.0:          equ  0x4080         ;                
_3.5:          equ  0x40C0         ;                
_3.75:         equ  0x40E0         ;                
_4.0:          equ  0x4100         ;  binary7/8 representation of 4.00 decimal

            org     0x0              

Constants:  
prog_entry: DFL     0, initialize      ;entry point for this program
prog_len:   DFL     0, progend         ;the present convention is location 0x00001 is the program/thread length

            org     $         ;default interrupt vector locations
done:       _       _1:setDVNCZ = _1:#DoneBit          ;set Done bit
            _       _4:PCC = (_1:0x00, 0, $)           ;s/w break here  (note: $ is current PC)
initialize: _       _1:clrDVNCZ = _1:#DoneBit          ;clear the Done bit to tell the world we are now busy
            _       _4:AR0 = _4:#ratesMem              ;point to input 0 charge rates memory
            _       _2:REPEAT = _2:#63                 ;initialize all input charge rates to the value 6
            _       _1:*AR0++[1] = _1:#6               ;6=roughly 16-tick input charge rate
            _       _4:AR1 = _4:#threshMem             ;point to input 0 threshold memory
            _       _2:REPEAT = _2:#7                  ;initialize all input thresholds to the value 1.25
;            _       _2:*AR1++[1] = _2:#_2.25           ;something slightly more than 2.0
;            _       _2:*AR1++[1] = _2:#_4.0            ;something around 4.0
;            _       _2:*AR1++[1] = _2:#_3.5            ;something around 3.0
            _       _2:*AR1++[1] = _2:#_3.75            ;something around 3.0
            
pushSpikes: 
          ;  _       _4:AR2 = _4:#binWeightsMem         ;point to weights vector
            _       _4:AR3 = _4:#spikeSrcMem           ;point to input spike train source buffer location
            _       _4:AR4 = _4:#SNNinput              ;point to SNN spike train target input
            _       _2:REPEAT = _2:#31                 ;input spike train is 16 ticks deep in this example
            ACT     _1:*AR4++[1] = (_1:*AR3++[1], _128:0) ;push the spike train and 
                                                       ;specified weights,rates, thresholdsinto SNN input
            _
            _  s4:PC = _4:#done           ;go back to done--unconditional load of PC with absolute address
            _
            _
progend:

          end
            
