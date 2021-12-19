//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.tb_clock_generator.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 12/03/21
//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns
module tb_clock_generator #(
  parameter SYS_FREQ  = 100000000,
  parameter BAUD_RATE = 9600,
  parameter CLOCK     = SYS_FREQ/BAUD_RATE,
  parameter SAMPLE    = 16,
  parameter BAUD_DVSR = SYS_FREQ/(SAMPLE*BAUD_RATE)
  ) ();

logic clk       ;
logic reset_n   ;
logic clock     ;
logic sample_clk;

uart_generator_clock #(SYS_FREQ,BAUD_RATE,CLOCK,SAMPLE,BAUD_DVSR)
uart_generator_clock (
  .clk       (clk       ),
  .reset_n   (reset_n   ),
  .clock     (clock     ),
  .sample_clk(sample_clk)
  );

always #5 clk = ~clk;

initial begin
  clk = 0;
  reset_n = 1;
  @(negedge clk);
  reset_n = 0;
  @(negedge clk);
  reset_n = 1;
  repeat(100000) @(negedge clk);
  $finish;
end

endmodule : tb_clock_generator