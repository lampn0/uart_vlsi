//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.uart_protocol.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 12/03/21
//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns

module tb_uart_transmitter #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1)
  )();

logic                     clk            ;
logic                     reset_n        ;
logic                     write_data     ;
logic [DATA_SIZE - 1 : 0] bus_data       ;
logic                     serial_data_out;
logic [            7 : 0] status_register;

uart_transmitter #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_transmitter(
  .clk            (clk            ),
  .reset_n        (reset_n        ),
  .write_data     (write_data     ),
  .serial_data_out(serial_data_out),
  .status_register(status_register),
  .bus_data       (bus_data       )
  );

always #5 clk = ~clk;

initial begin
  clk = 0;
  reset_n = 1;
  @(negedge clk);
  reset_n = 0;
  @(negedge clk);
  reset_n = 1;
  @(negedge clk);
  bus_data = $random();
  write_data = 1;
  @(negedge clk);
  bus_data = $random();
  @(negedge clk);
  write_data = 0;
  bus_data = $random();
  repeat (20) @(negedge clk);
  $finish;

end

endmodule : tb_uart_transmitter