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
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_transmitter(
  .clk            (clock              ),
  .reset_n        (reset_n            ),
  .write_data     (write_data         ),
  .serial_data_out(serial_data_out    ),
  .bus_data       (bus_data_in        ),
  .status_register(TX_status_register )
  );

// -------------------------------------------------------------
// Transmitter
// -------------------------------------------------------------
uart_receiver #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_receiver(
  .clk            (sample_clk         ),
  .reset_n        (reset_n            ),
  .status_register(RX_status_register ),
  .bus_data       (bus_data_out       ),
  .read_data      (read_data          ),
  .serial_data_in (serial_data_in     )
  );

endmodule : uart_protocol