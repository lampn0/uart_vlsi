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
module uart_receiver #(
  parameter DATA_SIZE       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE)
  )  (
  input                             clk           , // Clock
  input                             reset_n       , // Asynchronous reset active low
  input                             serial_data_in,
  output  logic [DATA_SIZE - 1 : 0] data_out      ,
  output  logic                     rx_done       ,
  output  logic                     parity_error  ,
  output  logic                     stop_error    ,
  output  logic                     break_error   ,
  output  logic                     overflow_error,
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic [DATA_SIZE      : 0]  RX_shift_reg      ;
logic [BIT_COUNT_SIZE : 0]  bit_count         ;
logic [3              : 0]  sample_count      ;
logic                       load_RX_shift_reg ;
logic                       inc_bit_count     ;
logic                       clr_bit_count     ;
logic                       inc_sample_count  ;
logic                       clr_sample_count  ;
logic                       shift             ;
logic                       clear             ;
logic                       parity_check      ;
logic                       RX_shift_reg_2_0  ;
logic                       read_not_ready_out;

// assign status_register = {read_not_ready_out,
//                           overflow_error,
//                           stop_error,
//                           break_error,
//                           parity_error,
//                           empty,
//                           full,
//                           error_read_data};
// =====================================================================================================================--------------------
//   | read_not_ready_out | overflow_error | stop_error | break_error | parity_error | empty | full  | error_write_data  | <== Status Register
//   =====================================================================================================================---------------------


// -------------------------------------------------------------
// State Encoding
// -------------------------------------------------------------
enum logic [2:0] {
  IDLE      = 3'b001,
  STARTING  = 3'b010,
  RECEIVING = 3'b100
} state, next_state;

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
// FSM output signal
// -------------------------------------------------------------
always_comb begin : proc_output_fsm
  stop_error = 0;
  break_error = 0;
  overflow_error = 0;
  parity_error = 0;
  inc_sample_count = 0;
  clr_sample_count = 0;
  inc_bit_count = 0;
  clr_bit_count = 0;
  read_not_ready_out = 0;
  case (state)
    IDLE: begin
      if (full) begin
        overflow_error = 1'b1;
        next_state = IDLE;
      end
      else begin
        if (serial_data_in == 1'b0) begin
          next_state = STARTING;
        end
        else begin
          next_state = IDLE;
        end
      end
    end

    STARTING: begin
      if (serial_data_in == 1'b1) begin
        clr_sample_count = 1'b1;
        next_state = IDLE;
      end
      else begin
        if (sample_count == 7) begin
          clr_sample_count = 1'b1;
          next_state = STARTING;
        end
        else begin
          inc_sample_count = 1;
          next_state = RECEIVING;
        end
      end
    end

    RECEIVING: begin
      inc_sample_count = 1;
      if (sample_count == 15) begin
        if (bit_count == 9) begin
          read_not_ready_out = 1'b1;
          clr_sample_count = 1'b1;
          clr_bit_count = 1'b1;
          if (serial_data_in == 0) begin
            if (RX_shift_reg_2_0 == 0) begin
              break_error = 1'b1;
              next_state = IDLE;
            end
            else begin
              stop_error = 1'b1;
              next_state = IDLE;
            end
          end
          else begin
            if (parity_check) begin
              load_RX_shift_reg = 1'b1;
              next_state = IDLE;
            end
            else begin
              parity_error = 1'b1;
              next_state = IDLE;
            end
          end
        end
        else begin
          shift = 1;
          inc_bit_count = 1;
          clr_sample_count = 1;
          next_state = RECEIVING;
        end
      end
      else begin
        next_state = RECEIVING;
      end
    end
    default : next_state = IDLE;
  endcase
end


assign data_out = RX_shift_reg[7:0];

// -------------------------------------------------------------
// Counter
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_bit_counter
  if(~reset_n) begin
    bit_count <= 0;
  end
  else if(inc_bit_count) begin
    bit_count <= bit_count + 1'b1;
  end
  else if (clr_bit_count) begin
    bit_count <= 0;
  end
  else begin
    bit_count <= bit_count;
  end
end

always_ff @(posedge clk or negedge reset_n) begin : proc_sample_counter
  if(~reset_n) begin
    sample_count <= 0;
  end
  else if(inc_sample_count) begin
    sample_count <= sample_count + 1'b1;
  end
  else if (clr_sample_count) begin
    sample_count <= 0;
  end
  else begin
    sample_count <= sample_count;
  end
end

// -------------------------------------------------------------
// TX Shift Register
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_rx_shift_reg
  if(~reset_n) begin
    RX_shift_reg <= 0;
  end
  else begin
    if(shift) begin
      RX_shift_reg <= {serial_data_in,RX_shift_reg[DATA_SIZE : 1]};
    end
    else begin
      RX_shift_reg <= RX_shift_reg;
    end
  end
end

endmodule : uart_receiver