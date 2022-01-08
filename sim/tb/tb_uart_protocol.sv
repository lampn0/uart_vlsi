//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.tb_uart_protocol.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 08:26:49 08/01/22
//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns
module tb_uart_protocol #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
            SYS_FREQ        = 100000000,
            BAUD_RATE       = 9600,
            CLOCK           = SYS_FREQ/BAUD_RATE,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )();
logic                     clk                 ;
logic                     reset_n             ;

logic                     write_data_1        ;
logic                     read_data_1         ;
logic                     serial_data_in_1    ;
logic [DATA_SIZE - 1 : 0] bus_data_in_1       ;
logic [DATA_SIZE - 1 : 0] bus_data_out_1      ;
logic                     serial_data_out_1   ;
logic [            7 : 0] TX_status_register_1;
logic [            7 : 0] RX_status_register_1;

logic                     write_data_2        ;
logic                     read_data_2         ;
logic [DATA_SIZE - 1 : 0] bus_data_in_2       ;
logic [DATA_SIZE - 1 : 0] bus_data_out_2      ;
logic [            7 : 0] TX_status_register_2;
logic [            7 : 0] RX_status_register_2;

/*===============================================---------------------
  |   5'b0  | empty | full  | error_write_data  | <== Status Register
  ===============================================---------------------
*/
uart_protocol #(
  .DATA_SIZE     (DATA_SIZE ),
  .SIZE_FIFO     (SIZE_FIFO ),
  .SYS_FREQ      (SYS_FREQ  ),
  .BAUD_RATE     (BAUD_RATE ),
  .SAMPLE        (SAMPLE    ))
uart_protocol_1(
  .clk               (clk                 ),
  .reset_n           (reset_n             ),
  .read_data         (read_data_1         ),
  .write_data        (write_data_1        ),
  .serial_data_in    (serial_data_in_1    ),
  .serial_data_out   (serial_data_out_1   ),
  .RX_status_register(RX_status_register_1),
  .TX_status_register(TX_status_register_1),
  .bus_data_in       (bus_data_in_1       ),
  .bus_data_out      (bus_data_out_1      )
  );

/*=====================================================================================================================--------------------
  | read_not_ready_out | overflow_error | stop_error | break_error | parity_error | empty | full  | error_write_data  | <== Status Register
  =====================================================================================================================---------------------
*/
uart_protocol #(
  .DATA_SIZE     (DATA_SIZE ),
  .SIZE_FIFO     (SIZE_FIFO ),
  .SYS_FREQ      (SYS_FREQ  ),
  .BAUD_RATE     (BAUD_RATE ),
  .SAMPLE        (SAMPLE    ))
uart_protocol_2(
  .clk               (clk                 ),
  .reset_n           (reset_n             ),
  .read_data         (read_data_2         ),
  .write_data        (write_data_2        ),
  .serial_data_in    (serial_data_out_1   ),
  .serial_data_out   (serial_data_in_1    ),
  .RX_status_register(RX_status_register_2),
  .TX_status_register(TX_status_register_2),
  .bus_data_in       (bus_data_in_2       ),
  .bus_data_out      (bus_data_out_2      )
  );

always #5 clk = ~clk;

initial begin
  clk = 0;
  reset_n = 1;
  repeat (2) @(negedge clk);
  reset_n = 0;
  @(negedge clk);
  reset_n = 1;
  @(negedge clk);
  bus_data_in_1 = $random();
  write_data_1 = 1;
  write_data_2 = 0;
  read_data_2 = 1;
  @(negedge clk);
  write_data_1 = 0;
  repeat (2) @(negedge clk);
  bus_data_in_2 = $random();
  bus_data_in_1 = $random();
  write_data_1 = 1;
  write_data_2 = 1;
  read_data_1 = 1;
  @(negedge clk);
  bus_data_in_2 = $random();
  bus_data_in_1 = $random();
  @(negedge clk);
  write_data_1 = 0;
  write_data_2 = 0;
  repeat (300000) @(negedge clk);
  $finish;
end


endmodule : tb_uart_protocol