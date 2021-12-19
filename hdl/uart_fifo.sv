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
module uart_fifo #(
  parameter SIZE        = 8,
  parameter ADDR_WIDTH  = $clog2(SIZE)
  )  (
  input               clk       ,  // Clock
  input               reset_n   ,  // Asynchronous reset active low
  input         [7:0] data_in   ,
  input               write     ,
  input               read      ,
  output logic  [7:0] data_out  ,
  output logic        full      ,
  output logic        empty     ,
  output logic        error     
);

logic [7:0] fifo [SIZE - 1 : 0];
logic [ADDR_WIDTH - 1 : 0] ptr_rd;
logic [ADDR_WIDTH - 1 : 0] ptr_wr;

always_comb begin : proc_
  if(write & ~full) begin
    fifo[ptr_wr] = data_in;
  end
  else if(read & ~empty) begin
    data_out = fifo[ptr_rd];
  end
end



always_comb begin : proc_
  if(reset_n) begin
    for (int i = 0; i < SIZE; i++) begin
      fifo[i] = 0;
    end
  end
end

always_ff @(posedge clk or negedge reset_n) begin : proc_addr
  if(~reset_n) begin
    ptr_rd <= 0;
    ptr_wr <= 0;
    // for (int i = 0; i < SIZE; i++) begin
    //   fifo[i] <= 0;
    // end
  end
  else begin
    case(read,write)
      2'b01: begin
        if (~empty) begin
          ptr_wr <= ptr_wr + 1;
        end else begin
          error <= 1;
        end
      end
      2'b10: begin
        if (~full) begin
          ptr_rd <= ptr_rd + 1;
        end else begin
          error <= 1;
        end
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