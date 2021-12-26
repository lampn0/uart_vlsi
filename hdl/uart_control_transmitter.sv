//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.uart_control_transmitter.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 12/24/21
//-----------------------------------------------------------------------------------------------------------
module uart_control_transmitter (
  input         clk               , // Clock
  input         reset_n           , // Asynchronous reset active low
  input         write_data        ,
  input         empty             ,
  input         full              ,
  input         bit_count         ,
  output  logic load_TX_shift_reg ,
  output  logic write             ,
  output  logic shift             ,
  output  logic clear             ,
  output  logic serial_data_out   ,
  output  logic error_write_data  
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
// write output signal
// -------------------------------------------------------------
always_comb begin : proc_write_fifo
  if (full) begin
    write = 0;
  end
  else begin
    write = write_data;
  end
  if (write_data & full) begin
    error_write_data = 1;
  end
  else begin
    error_write_data = 0;
  end
end

// -------------------------------------------------------------
// FSM
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_state
  if(~reset_n) begin
    state <= IDLE;
  end else begin
    state <= next_state;
  end
end

// -------------------------------------------------------------
// FSM ouput signal
// -------------------------------------------------------------
always_comb begin : proc_output_fsm
  load_TX_shift_reg = 0;
  shift = 0;
  clear = 0;
  case (state)
    IDLE: begin
      if (~empty) begin
        load_TX_shift_reg = 1;
        next_state = SENDING;
      end
      else begin
        load_TX_shift_reg = 0;
        next_state = IDLE;
      end
    end
    SENDING: begin
      if (bit_count == 9) begin
        clear = 1;
        next_state = IDLE;
      end
      else begin
        shift = 1;
        next_state = SENDING;
      end
    end
    default : next_state = IDLE;
  endcase
end


endmodule : uart_control_transmitter