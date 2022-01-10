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
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1)
  )();

logic                     clk            ;
logic                     reset_n        ;
logic                     tx_start_n     ;
logic [DATA_SIZE - 1 : 0] data_in        ;
logic                     serial_data_out;
logic                     tx_done        ;

uart_transmitter #(
  .DATA_SIZE (DATA_SIZE))
uart_transmitter(
  .clk            (clk            ),
  .reset_n        (reset_n        ),
  .data_in        (data_in        ),
  .tx_start_n     (tx_start_n     ),
  .serial_data_out(serial_data_out),
  .tx_done        (tx_done        )
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
  data_in = 11001011;
  tx_start_n = 0;
  repeat (11) @(negedge clk);
  data_in = $random();
  tx_start_n = 0;
  repeat (12) @(negedge clk);
  $finish;

end

endmodule : tb_uart_transmitter