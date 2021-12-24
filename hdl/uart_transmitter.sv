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
module uart_transmitter #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1)
  )  (
  input                 clk             , // Clock
  input                 reset_n         , // Asynchronous reset active low
  input                 write_data      ,
  output  logic         serial_data_out ,
  output  logic [7 : 0] status_register 
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic [DATA_SIZE      - 1 : 0]  TX_shift_reg;
logic [BIT_COUNT_SIZE - 1 : 0]  bit_count;
logic                           load_TX_shift_reg;
logic                           shift;
logic                           clear;
logic                           write;
logic                           full;
logic                           empty;
logic                           error_write_data;

assign status_register = {5{1'b0},empty,full,error_write_data};
/*===============================================---------------------
  |   5'b0  | empty | full  | error_write_data  | <== Status Register
  ===============================================---------------------
*/

uart_control_transmitter
uart_control_transmitter(
  .clk              (clk              ),
  .reset_n          (reset_n          ),
  .error_write_data (error_write_data ),
  .full             (full             ),
  .empty            (empty            ),
  .bit_count        (bit_count        ),
  .clear            (clear            ),
  .shift            (shift            ),
  .write_data       (write_data       ),
  .load_TX_shift_reg(load_TX_shift_reg),
  .write            (write            )
  );

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo_transmitter(
  .clk     (clk     ),
  .reset_n (reset_n ),
  .write   (write   ),
  .empty   (empty   ),
  .full    (full    ),
  .data_in (data_in ),
  .read    (read    ),
  .data_out(data_out)
  );

endmodule : uart_transmitter