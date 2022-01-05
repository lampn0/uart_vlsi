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
  input         serial_data_in    ,
  input         bit_count_done    ,
  input         sample_count_done1,
  input         sample_count_done2,
  input         empty             ,
  input         full              ,
  input         RX_shift_reg_2_0  ,
  input         parity_check      ,
  output  logic read              ,
  output  logic load_RX_shift_reg ,
  output  logic inc_sample_count  ,
  output  logic clr_sample_count  ,
  output  logic inc_bit_count     ,
  output  logic clr_bit_count     ,
  output  logic shift             ,
  output  logic overflow_error    ,
  output  logic stop_error        ,
  output  logic parity_error      ,
  output  logic break_error       ,
  output  logic read_not_ready_out,
  output  logic error_read_data   
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------


// -------------------------------------------------------------
// State Encoding
// -------------------------------------------------------------
enum logic [2:0] {
  IDLE      = 3'b001,
  STARTING  = 3'b010,
  RECEIVING = 3'b100
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
        if (sample_count_done1) begin
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
      if (sample_count_done2) begin
        if (bit_count_done) begin
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


endmodule : uart_control_receiver