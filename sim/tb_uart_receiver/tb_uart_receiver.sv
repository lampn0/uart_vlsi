//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.tb_uart_receiver.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 12/03/21
//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns

module tb_uart_receiver #(
  parameter DATA_SIZE       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1)
  )();

logic                     clk           ;
logic                     sample_clk    ;
logic                     reset_n       ;
logic                     serial_data_in;
logic                     rx_start_n    ;
logic [DATA_SIZE - 1 : 0] data_out      ;
logic                     rx_done       ;
logic                     parity_error  ;
logic                     stop_error    ;
logic                     break_error   ;
logic                     overflow_error;

uart_receiver #(
  .DATA_SIZE (DATA_SIZE))
uart_receiver(
  .clk           (sample_clk    ),
  .reset_n       (reset_n       ),
  .rx_start_n    (rx_start_n    ),
  .serial_data_in(serial_data_in),
  .overflow_error(overflow_error),
  .break_error   (break_error   ),
  .stop_error    (stop_error    ),
  .parity_error  (parity_error  ),
  .rx_done       (rx_done       ),
  .data_out      (data_out      )
  );

always #5 sample_clk = ~sample_clk;
always #(16*5) clk = ~clk;

initial begin
  clk = 0;
  sample_clk = 0;
  reset_n = 1;
  @(negedge sample_clk);
  reset_n = 0;
  @(negedge sample_clk);
  reset_n = 1;
  @(negedge sample_clk);
  serial_data_in = 1;
  rx_start_n = 0;
  @(negedge clk);
  serial_data_in = 0;
  repeat (8) begin
    @(negedge clk);
    serial_data_in = $random();
  end
  @(negedge clk);
  serial_data_in = 1;
  repeat (2) @(negedge clk);
  // repeat (15) begin
  //   @(negedge clk);
  //   serial_data_in = $random();
  // end
  $finish;

end

endmodule : tb_uart_receiver