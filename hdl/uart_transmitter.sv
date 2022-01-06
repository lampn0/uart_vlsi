//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.uart_transmitter.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 06/01/22
//-----------------------------------------------------------------------------------------------------------
module uart_transmitter #(
  parameter DATA_SIZE       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1)
  )  (
  input                             clk             , // Clock
  input                             reset_n         , // Asynchronous reset active low
  input                             tx_start_n      , // Empty signal from FIFO
  input         [DATA_SIZE - 1 : 0] data_in         , // Data from FIFO
  output  logic                     serial_data_out , // 
  output  logic                     tx_done           // 
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic [DATA_SIZE      + 1 : 0]  TX_shift_reg      ; // 
logic [BIT_COUNT_SIZE - 1 : 0]  bit_count         ; // 
logic                           bit_count_done    ; // 
logic                           load_TX_shift_reg ; // 
logic                           shift             ; // 
logic                           clear             ; // 
logic                           bit_parity        ; // 

// -------------------------------------------------------------
// State Encoding
// -------------------------------------------------------------
enum logic [1:0] {
  IDLE      = 3'b01,
  SENDING   = 3'b10
} state, next_state;

// assign status_register = {5'b0,empty,full,error_write_data};
// ===============================================---------------------
//   |   5'b0  | empty | full  | error_write_data  | <== Status Register
//   ===============================================---------------------

assign bit_parity = ^data_in;
assign serial_data_out = TX_shift_reg[0];
assign tx_done = bit_count_done;

// -------------------------------------------------------------
// FSM
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_state
  if(~reset_n) begin
    state <= IDLE;
  end
  else begin
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
      if (~tx_start_n) begin
        load_TX_shift_reg = 1;
        next_state = SENDING;
      end
      else begin
        load_TX_shift_reg = 0;
        next_state = IDLE;
      end
    end
    SENDING: begin
      if (bit_count_done) begin
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


// -------------------------------------------------------------
// Counter
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_counter
  if(~reset_n) begin
    bit_count <= 0;
  end
  else if(shift) begin
    bit_count <= bit_count + 1'b1;
  end
  else if (clear) begin
    bit_count <= 0;
  end
  else begin
    bit_count <= bit_count;
  end
end

always_comb begin : proc_count_done
  bit_count_done = (bit_count == 4'd10);
end

// -------------------------------------------------------------
// TX Shift Register
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_tx_shift_reg
  if(~reset_n) begin
    TX_shift_reg <= {(DATA_SIZE+2){1'b1}};
  end
  else if(load_TX_shift_reg) begin
    TX_shift_reg <= {bit_parity,data_in,1'b0};
  end
  else if (shift) begin
    TX_shift_reg <= {1'b1,TX_shift_reg[DATA_SIZE+1:1]};
  end
  else begin
    TX_shift_reg <= TX_shift_reg;
  end
end

endmodule : uart_transmitter