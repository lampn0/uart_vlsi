//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.uart_generator_clock.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 12/03/21
//-----------------------------------------------------------------------------------------------------------
module uart_generator_clock #(
  parameter SYS_FREQ  = 100000000,
  parameter BAUD_RATE = 9600,
  parameter CLOCK     = SYS_FREQ/BAUD_RATE,
  parameter SAMPLE    = 16,
  parameter BAUD_DVSR = SYS_FREQ/(SAMPLE*BAUD_RATE)
  ) (
  input         clk       , // Clock
  input         reset_n   , // Asynchronous reset active low
  output logic  clock     , // clk
  output logic  sample_clk  // sample_clk
);

  logic [$clog2(CLOCK    ) - 1 : 0] count_clk;
  logic [$clog2(BAUD_DVSR) - 1 : 0] count_sample_clk;

  always_ff @(posedge clk or negedge reset_n) begin : proc_count_clk
    if(~reset_n) begin
      count_clk <= 0;
    end else begin
      count_clk <= (count_clk == (CLOCK - 1) ? 0 : (count_clk + 1));;
    end
  end

  always_ff @(posedge clk or negedge reset_n) begin : proc_count_sample_clk
    if(~reset_n) begin
      count_sample_clk <= 0;
    end else begin
      count_sample_clk <= (count_sample_clk == (BAUD_DVSR - 1) ? 0 : (count_sample_clk + 1));
    end
  end

  always_ff @(posedge clk or negedge reset_n) begin : proc_clock
    if(~reset_n) begin
      clock <= 0;
    end 
    else if (count_clk == (CLOCK - 1)) begin
      clock <= ~clock;
    end
    else begin
      clock = clock;
    end
  end

    always_ff @(posedge clk or negedge reset_n) begin : proc_sample_clk
    if(~reset_n) begin
      sample_clk <= 0;
    end 
    else if (count_sample_clk == (BAUD_DVSR - 1)) begin
      sample_clk <= ~sample_clk;
    end
    else begin
      sample_clk = sample_clk;
    end
  end

endmodule : uart_generator_clock