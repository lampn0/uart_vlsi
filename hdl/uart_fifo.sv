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
//    Date: 08:26:49 01/08/22
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
logic [DATA_SIZE  - 1 : 0] fifo [SIZE_FIFO - 1 : 0];
logic [ADDR_WIDTH - 1 : 0] ptr_rd, ptr_rd_next, ptr_rd_succ;
logic [ADDR_WIDTH - 1 : 0] ptr_wr, ptr_wr_next, ptr_wr_succ;
logic                      wr_en ;
logic                      full_next, empty_next;

// -------------------------------------------------------------
// FIFO Data Buffer
// -------------------------------------------------------------
assign wr_en = write & ~full ;
assign rd_en = read & ~empty ;
assign data_out = fifo[ptr_rd];
always_ff @(posedge clk or negedge reset_n) begin : proc_fifo
  if(~reset_n) begin
    for (int i = 0; i < SIZE_FIFO; i++) begin
      fifo[i] <= 0;
    end
  end
  else if(wr_en & rd_en) begin
    fifo[ptr_wr] <= data_in;
  end
  else if(wr_en) begin
    fifo[ptr_wr] <= data_in;
  end
end

// -------------------------------------------------------------
// Pointer
// -------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin
  if(~reset_n) begin
    ptr_wr <= 0 ;
    ptr_rd <= 0 ;
    full <= 1'b0;
    empty <= 1'b1;
  end
  else begin
    ptr_wr <= ptr_wr_next ;
    ptr_rd <= ptr_rd_next ;
    full <= full_next     ;
    empty <= empty_next   ;
  end
end

always_comb begin
  ptr_wr_succ = ptr_wr + 1'b1;
  ptr_rd_succ = ptr_rd + 1'b1;
  ptr_rd_next = ptr_rd ;
  ptr_wr_next = ptr_wr ;
  full_next = full;
  empty_next = empty;
  case({write, read})
    2'b01: begin
      if(~empty) begin
        ptr_rd_next = ptr_rd_succ ;
        full_next = 1'b0;
        if(ptr_rd_succ == ptr_wr)
          empty_next = 1'b1;
      end
    end
    2'b10: begin
      if(~full) begin
        ptr_wr_next = ptr_wr_succ ;
        empty_next = 1'b0 ;
        if(ptr_wr_succ == ptr_rd)
          full_next = 1'b1;
      end
    end
    2'b11: begin
      ptr_wr_next = ptr_wr_succ ;
      ptr_rd_next = ptr_rd_succ ;
    end
  endcase
end

// -------------------------------------------------------------
// Status FIFO
// -------------------------------------------------------------

// always_comb begin : proc_status
//   if(write && (ptr_wr == ptr_rd)) begin
//     full = 1'b1;
//   end
//   else begin
//     full = 0;
//   end

//   if(read && (ptr_wr == ptr_rd)) begin
//     empty = 1'b1;
//   end
//   else begin
//     empty = 0;
//   end
// end

endmodule : uart_fifo