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
module uart_control_receiver (
  input         clk               , // Clock
  input         reset_n           , // Asynchronous reset active low
  input         read_data         ,
  input         empty             ,
  input         full              ,
  input         bit_count         ,
  output  logic load_RX_shift_reg ,
  output  logic read             ,
  output  logic shift             ,
  output  logic clear             ,
  output  logic error_read_data   
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------

// -------------------------------------------------------------
// State Encoding
// -------------------------------------------------------------
enum logic [1:0] {
  IDLE    = 2'b01;
  SENDING = 2'b10;
} state, next_state;

// -------------------------------------------------------------
// Write Output Signal
// -------------------------------------------------------------
always_comb begin : proc_read_fifo
  if (empty) begin
    read = 0;
  end
  else begin
    read = read_data;
  end
  if (read_data & full) begin
    error_read_data = 1;
  end
  else begin
    error_read_data = 0;
  end
end

endmodule : uart_control_receiver