// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

`include "caravel_netlists.v"
`include "spiflash.v"
`include "fabric_netlists.v"
`include "tie_array.v"

`define FPGA_SCANCHAIN_SIZE 1024

`define POWER_UP_TIME_PERIOD 100
`define SOC_RESET_TIME_PERIOD 2000
`define SOC_SETUP_TIME_PERIOD 200*2001
`define SOC_CLOCK_PERIOD 12.5
`define FPGA_CLOCK_PERIOD 12.5
// 360

module scff_test_post_pnr_caravel_autocheck_top_tb;
  reg clock;
  reg RSTB;
  reg power1, power2;
  reg power3, power4;

  wire gpio;
  wire [37:0] mprj_io;
  wire [6:0] checkbits;

  assign checkbits = mprj_io[10:4];
  
  // ----- Local wires for control ports of FPGA fabric -----
  reg [0:0] prog_clock_reg;
  wire [0:0] prog_clk;
  wire [0:0] prog_clock;
  reg [0:0] op_clock_reg;
  wire [0:0] op_clk;
  wire [0:0] op_clock;
  reg [0:0] prog_reset;
  reg [0:0] greset;

  // ---- Scan-chain head -----
  reg [0:0] sc_head;
  // ---- Scan-chain tail -----
  wire [0:0] sc_tail;


  // ----- Counters for error checking -----
  integer num_clock_cycles = 0; 
  integer num_errors = 0; 
  integer num_checked_points = 0; 

  // Indicate when SoC setup phase should be finished
  reg soc_setup_done = 0; 
  // Indicate when configuration should be finished
  reg scan_done = 0; 

  initial
    begin
      scan_done = 1'b0;
      soc_setup_done = 1'b0;
    end

  // ----- Begin raw programming clock signal generation -----
  initial
    begin
      prog_clock_reg[0] = 1'b0;
    end
  // ----- End raw programming clock signal generation -----

  // ----- Begin raw operating clock signal generation -----
  initial
    begin
      op_clock_reg[0] = 1'b0;
    end
  always
    begin
      #(`FPGA_CLOCK_PERIOD)  op_clock_reg[0] = ~op_clock_reg[0];
    end
// ----- End raw operating clock signal generation -----
// ----- Actual operating clock is triggered only when scan_done is enabled -----
  assign prog_clock[0] = prog_clock_reg[0] & ~greset;
  assign op_clock[0] = op_clock_reg[0] & ~greset;

  // ----- Begin programming reset signal generation -----
  initial
    begin
      prog_reset[0] = 1'b0;
    end

  // ----- End programming reset signal generation -----
  
  // ----- Begin operating reset signal generation -----
  // ----- Reset signal is disabled always -----
  initial
    begin
      greset[0] = 1'b1;
      wait(checkbits === 7'h4);
      $display("Test started.. ");
      #(2 * `FPGA_CLOCK_PERIOD)  greset[0] = 1'b0;
      wait(checkbits === 7'h0C);
      #5000;
      $display("Simulation ended successfuly..");
      $finish;
    end
  // ----- End operating reset signal generation -----
  
  // ----- Begin connecting global ports of FPGA fabric to stimuli -----
  assign op_clk[0] = op_clock[0];
  assign prog_clk[0] = prog_clock[0];
  // ----- End connecting global ports of FPGA fabric to stimuli -----
  // assign mprj_io[36] = op_clk;
  // assign mprj_io[37] = prog_clk;

  // External clock is used by default.  Make this artificially fast for the
  // simulation.  Normally this would be a slow clock and the digital PLL
  // would be the fast clock.

  always #(`SOC_CLOCK_PERIOD) clock <= (clock === 1'b0);

  initial begin
    clock = 0;
  end

  initial begin
		$dumpfile("io_ports.vcd");
		$dumpvars(0, scff_test_post_pnr_caravel_autocheck_top_tb);
	end

  initial begin
    RSTB <= 1'b0;
    soc_setup_done <= 1'b1;
    #(`SOC_RESET_TIME_PERIOD);
    RSTB <= 1'b1;      // Release reset
    soc_setup_done <= 1'b1; // We can start scff test
  end

  initial begin    // Power-up sequence
    power1 <= 1'b0;
    power2 <= 1'b0;
    power3 <= 1'b0;
    power4 <= 1'b0;
    #(`POWER_UP_TIME_PERIOD);
    power1 <= 1'b1;
    #(`POWER_UP_TIME_PERIOD);
    power2 <= 1'b1;
    #(`POWER_UP_TIME_PERIOD);
    power3 <= 1'b1;
    #(`POWER_UP_TIME_PERIOD);
    power4 <= 1'b1;
  end

  wire flash_csb;
  wire flash_clk;
  wire flash_io0;
  wire flash_io1;

  wire VDD3V3 = power1;
  wire VDD1V8 = power2;
  wire USER_VDD3V3 = power3;
  wire USER_VDD1V8 = power4;
  wire VSS = 1'b0;

  caravel uut (
    .vddio    (VDD3V3),
    .vssio    (VSS),
    .vdda    (VDD3V3),
    .vssa    (VSS),
    .vccd    (VDD1V8),
    .vssd    (VSS),
    .vdda1    (USER_VDD3V3),
    .vdda2    (USER_VDD3V3),
    .vssa1    (VSS),
    .vssa2    (VSS),
    .vccd1    (USER_VDD1V8),
    .vccd2    (USER_VDD1V8),
    .vssd1    (VSS),
    .vssd2    (VSS),
    .clock    (clock),
    .gpio     (gpio),
    .mprj_io  (mprj_io),
    .flash_csb(flash_csb),
    .flash_clk(flash_clk),
    .flash_io0(flash_io0),
    .flash_io1(flash_io1),
    .resetb    (RSTB)
  );

  spiflash #(
    .FILENAME("io_ports.hex")
  ) spiflash (
    .csb(flash_csb),
    .clk(flash_clk),
    .io0(flash_io0),
    .io1(flash_io1),
    .io2(),      // not used
    .io3()      // not used
  );

endmodule
`default_nettype wire
