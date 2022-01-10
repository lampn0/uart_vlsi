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
//    Date: 08:26:49 08/01/22
//-----------------------------------------------------------------------------------------------------------
module uart_protocol #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
            SYS_FREQ        = 100000000,
            BAUD_RATE       = 9600,
            CLOCK           = SYS_FREQ/BAUD_RATE,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )  (
  input                             clk               ,  // Clock
  input                             reset_n           ,  // Asynchronous reset active low
  input                             write_data        ,
  input                             read_data         ,
  input                             serial_data_in    ,
  input         [DATA_SIZE - 1 : 0] bus_data_in       ,
  output  logic [DATA_SIZE - 1 : 0] bus_data_out      ,
  output  logic                     serial_data_out   ,
  output  logic [            7 : 0] TX_status_register,
  output  logic [            7 : 0] RX_status_register
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic                     clock     ;
logic                     sample_clk;
logic [DATA_SIZE - 1 : 0] tx_data_in;
logic [DATA_SIZE - 1 : 0] rx_data_out;
logic                     tx_start_n;
logic                     tx_done;
logic                     tx_full;
logic                     tx_empty;
logic                     rx_start_n;
logic                     rx_done;
logic                     rx_full;
logic                     rx_empty;
logic                     stop_error;
logic                     break_error;
logic                     parity_error;
logic                     overflow_error;

enum logic [1:0] {
  IDLE      = 2'b01,
  CHECK     = 2'b10
} state, next_state;

logic write_fifo_receiver;

assign tx_start_n = tx_empty;
assign rx_start_n = rx_full;

// ===============================================---------------------
//   |   5'b0  | empty | full  | error_write_data  | <== Status Register
//   ===============================================---------------------
assign TX_status_register = {5'b0,tx_done,tx_empty,tx_full};

// =====================================================================================================================--------------------
//   | rx_done | overflow_error | stop_error | break_error | parity_error | empty | full  | error_write_data  | <== Status Register
//   =====================================================================================================================---------------------
assign RX_status_register = {1'b0,rx_done,
                            overflow_error,
                            stop_error,
                            break_error,
                            parity_error,
                            rx_empty,
                            rx_full};

// -------------------------------------------------------------
// Generator Clock
// -------------------------------------------------------------
uart_generator_clock #(SYS_FREQ,BAUD_RATE,CLOCK,SAMPLE,BAUD_DVSR)
uart_generator_clock (
  .clk       (clk       ),
  .reset_n   (reset_n   ),
  .clock     (clock     ),
  .sample_clk(sample_clk)
  );

// -------------------------------------------------------------
// Transmitter
// -------------------------------------------------------------
uart_transmitter #(
  .DATA_SIZE (DATA_SIZE))
uart_transmitter(
  .clk            (clock          ),
  .reset_n        (reset_n        ),
  .tx_start_n     (tx_start_n     ),
  .data_in        (tx_data_in     ),
  .serial_data_out(serial_data_out),
  .tx_done        (tx_done        )
  );

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo_transmitter(
  .clk     (clk         ),
  .reset_n (reset_n     ),
  .data_in (bus_data_in ),
  .data_out(tx_data_in  ),
  .write   (write_data  ),
  .read    (tx_done     ),
  .full    (tx_full     ),
  .empty   (tx_empty    )
  );

// -------------------------------------------------------------
// Receiver
// -------------------------------------------------------------


uart_receiver #(
  .DATA_SIZE (DATA_SIZE))
uart_receiver(
  .clk           (sample_clk    ),
  .reset_n       (reset_n       ),
  .rx_start_n    (rx_start_n    ),
  .serial_data_in(serial_data_in),
  .data_out      (rx_data_out   ),
  .rx_done       (rx_done       ),
  .parity_error  (parity_error  ),
  .stop_error    (stop_error    ),
  .break_error   (break_error   ),
  .overflow_error(overflow_error)
  );

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo_receiver(
  .clk     (clk         ),
  .reset_n (reset_n     ),
  .data_in (rx_data_out ),
  .data_out(bus_data_out),
  .write   (write_fifo_receiver     ),
  .read    (read_data   ),
  .full    (rx_full        ),
  .empty   (rx_empty       )
  );



always_ff @(posedge clk or negedge reset_n) begin : fsm 
  if (~reset_n) begin
    state <= IDLE;
  end
  else state <= next_state;  
end

always_comb begin : fsm_output
  case(state)
    IDLE: begin
      if (rx_done) begin
        write_fifo_receiver = 1;
        next_state = CHECK;
      end
      else begin
        write_fifo_receiver = 0;
        next_state = IDLE;
      end
    end
    CHECK: begin
      write_fifo_receiver = 0;
      if (~rx_done) begin
        next_state = IDLE;
      end
      else next_state = CHECK;
    end
  endcase
end


endmodule : uart_protocol