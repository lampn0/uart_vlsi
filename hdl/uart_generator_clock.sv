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
module uart_generator_clock #(
  parameter SYS_FREQ  = 100000000,
  parameter BAUD_RATE = 9600,
  parameter BAUD_DVSR = SYS_FREQ/(16*BAUD_RATE)
  ) (
  input clk    ,  // Clock
  input reset_n,  // Asynchronous reset active low
  output logic tick
);

  logic [$clog2()]

endmodule : uart_generator_clock