//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.tb_uart_fifo.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 08:26:49 08/01/22
//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns
module tb_uart_fifo #(
  parameter DATA_SIZE   = 8,
            SIZE_FIFO   = 8,
            ADDR_WIDTH  = $clog2(SIZE_FIFO)
  )();

logic                      clk     ;
logic                      reset_n ;
logic  [DATA_SIZE - 1 : 0] data_in ;
logic                      write   ;
logic                      read    ;
logic  [DATA_SIZE - 1 : 0] data_out;
logic                      full    ;
logic                      empty   ;

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo(
  .clk     (clk     ),
  .reset_n (reset_n ),
  .data_in (data_in ),
  .read    (read    ),
  .write   (write   ),
  .data_out(data_out),
  .empty   (empty   ),
  .full    (full    )
  );

always #5 clk = ~clk;

initial begin
  clk = 0;
  reset_n = 1;
  write = 0;
  read = 0;
  data_in = 0;
  @(negedge clk);
  reset_n = 0;
  @(negedge clk);
  reset_n = 1;
  @(negedge clk);
  data_in = 8'h6C;
  write = 1;
  @(negedge clk);
  data_in = 8'hAF;
  @(negedge clk);
  data_in = 8'h64;
  read = 1;
  @(negedge clk);
  data_in =$random();
  read = 0;
  repeat(7) begin
    @(negedge clk);
    data_in = $random();
  end
  @(negedge clk);
  read = 1;
  write = 0;
  repeat(8) begin
    @(negedge clk);
  end
  read = 0;
  @(negedge clk);
  $finish;

end

endmodule : tb_uart_fifo