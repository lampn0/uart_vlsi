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
  input                             clk                 ,  // Clock
  input                             reset_n             ,  // Asynchronous reset active low
  input                             write_data          ,
  input                             read_data           ,
  input                             serial_data_in      ,
  input         [DATA_SIZE - 1 : 0] bus_data_in         ,
  output  logic [DATA_SIZE - 1 : 0] bus_data_out        ,
  output  logic                     serial_data_out     ,
  output  logic [            7 : 0] TX_status_register  ,
  output  logic [            7 : 0] RX_status_register  
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic clock     ;
logic sample_clk;

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
  .clk            (clk            ),
  .reset_n        (reset_n        ),
  .tx_start_n     (tx_start_n     ),
  .data_in        (data_in        ),
  .serial_data_out(serial_data_out),
  .tx_done        (tx_done        )
  );

// -------------------------------------------------------------
// Receiver
// -------------------------------------------------------------
uart_receiver #(
  .DATA_SIZE (DATA_SIZE))
uart_receiver(
  .clk           (clk           ),
  .reset_n       (reset_n       ),
  .serial_data_in(serial_data_in),
  .data_out      (data_out      ),
  .rx_done       (rx_done       ),
  .parity_error  (parity_error  ),
  .stop_error    (stop_error    ),
  .break_error   (break_error   ),
  .overflow_error(overflow_error)
  );

endmodule : uart_protocol