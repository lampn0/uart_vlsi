//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.tb_tx_rx.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 08:26:49 01/08/22
//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns
module tb_tx_rx #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
            SYS_FREQ        = 100000000,
            BAUD_RATE       = 9600,
            CLOCK           = SYS_FREQ/BAUD_RATE,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )();

logic                     clk             ;
logic                     reset_n         ;
logic                     clock           ;
logic                     sample_clk      ;

logic [DATA_SIZE - 1 : 0] bus_data_in     ;
logic [DATA_SIZE - 1 : 0] bus_data_out    ;
logic                     write_data      ;
logic                     read_data       ;

logic                     tx_start_n      ;
logic [DATA_SIZE - 1 : 0] tx_data_in      ;
logic                     serial_data_out ;
logic                     tx_done         ;
logic                     tx_full         ;
logic                     tx_empty        ;

logic                     serial_data_in  ;
logic                     rx_start_n      ;
logic [DATA_SIZE - 1 : 0] rx_data_out     ;
logic                     rx_done         ;
logic                     parity_error    ;
logic                     stop_error      ;
logic                     break_error     ;
logic                     overflow_error  ;
logic                     rx_full         ;
logic                     rx_empty        ;

logic write_fifo_receiver;

enum logic [1:0] {
  IDLE      = 2'b01,
  CHECK     = 2'b10
} state, next_state;

assign tx_start_n     = tx_empty;
assign rx_start_n     = rx_full;
assign serial_data_in = serial_data_out;

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
  .clk     (clk                 ),
  .reset_n (reset_n             ),
  .data_in (rx_data_out         ),
  .data_out(bus_data_out        ),
  .write   (write_fifo_receiver ),
  .read    (read_data           ),
  .full    (rx_full             ),
  .empty   (rx_empty            )
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
  bus_data_in = 8'b10110011;
  write_data = 1;
  @(negedge clk);
  bus_data_in = 8'b01011100;
  @(negedge clk);
  write_data = 0;
  repeat (1000) @(negedge clk);
  bus_data_in = 8'b10101110;
  write_data = 1;
  // repeat(7) begin
  //   @(negedge clk);
  //   bus_data_in = $random();
  // end
  @(negedge clk);
  write_data = 0;
  repeat (30000) @(negedge clk);
  read_data = 1;
  @(negedge clk);
  read_data = 0;
  repeat (30000) @(negedge clk);
  $finish;
end

endmodule : tb_tx_rx