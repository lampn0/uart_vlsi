//-----------------------------------------------------------------------------------------------------------
//    Copyright (C) 2021 by Dolphin Technology
//    All right reserved.
//
//    Copyright Notification
//    No part may be reproduced except as authorized by written permission.
//
//    Module: uart_protocol.uart_fifo.sv
//    Company: Dolphin Technology
//    Author: lampn0
//    Date: 15:14:49 12/03/21
//-----------------------------------------------------------------------------------------------------------
module uart_fifo #(
  parameter DATA_SIZE   = 8,
            SIZE_FIFO   = 8,
            ADDR_WIDTH  = $clog2(SIZE_FIFO)
  )  (
  input                             clk       , // Clock
  input                             reset_n   , // Asynchronous reset active low
  input         [DATA_SIZE - 1 : 0] data_in   ,
  input                             write     ,
  input                             read      ,
  output logic  [DATA_SIZE - 1 : 0] data_out  ,
  output logic                      full      ,
  output logic                      empty     
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic [DATA_SIZE  - 1 : 0] fifo [SIZE_FIFO : 0];
logic [ADDR_WIDTH - 1 : 0] ptr_rd;
logic [ADDR_WIDTH - 1 : 0] ptr_wr;

// -------------------------------------------------------------
// FIFO Data Buffer
// -------------------------------------------------------------
always_comb begin : proc_fifo_data
  if(reset_n) begin
    for (int i = 0; i < SIZE_FIFO; i++) begin
      fifo[i] = 0;
    end
  end
  else begin
    if(read & write) begin
      fifo[ptr_wr] = data_in;
      data_out = fifo[ptr_rd];
    end
    else if(read & ~write) begin
      data_out = fifo[ptr_rd];
    end
    else if(write & ~read) begin
      fifo[ptr_wr] = data_in;
    end
  end
end

// -------------------------------------------------------------
// Pointer
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_addr
  if(~reset_n) begin
    ptr_rd <= 0;
    ptr_wr <= 0;
  end
  else begin
    case({read,write})
      2'b01: begin
        ptr_wr <= ptr_wr + 1;
      end
      2'b10: begin
        ptr_rd <= ptr_rd + 1;
      end
      2'b11: begin
        ptr_wr <= ptr_wr + 1;
        ptr_rd <= ptr_rd + 1;
      end
      default begin
        ptr_wr <= ptr_wr;
        ptr_rd <= ptr_rd;
      end
    endcase // write,read
  end
end

// -------------------------------------------------------------
// Status FIFO
// -------------------------------------------------------------
always_comb begin : proc_status
  if(write && (ptr_wr == ptr_rd)) begin
    full = 1'b1;
  end
  else begin
    full = 0;
  end

  if(read && (ptr_wr == ptr_rd)) begin
    empty = 1'b1;
  end
  else begin
    empty = 0;
  end

end

endmodule : uart_fifo