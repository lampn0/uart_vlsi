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
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE)
  )  (
  input                             clk             , // Clock
  input                             reset_n         , // Asynchronous reset active low
  input                             read_data       ,
  input                             serial_data_in  ,
  output  logic [DATA_SIZE - 1 : 0] bus_data        ,
  output  logic [            7 : 0] status_register 
);

// -------------------------------------------------------------
// Signal Declaration
// -------------------------------------------------------------
logic [DATA_SIZE      + 1 : 0]  RX_shift_reg;
logic [BIT_COUNT_SIZE     : 0]  bit_count;
logic [3                  : 0]  sample_count;
logic [DATA_SIZE      - 1 : 0]  data_in;
logic                           load_RX_shift_reg;
logic                           sample_count_done1;
logic                           sample_count_done2;
logic                           bit_count_done;
logic                           inc_bit_count;
logic                           clr_bit_count;
logic                           inc_sample_count;
logic                           clr_sample_count;
logic                           read;
logic                           write;
logic                           shift;
logic                           clear;
logic                           full;
logic                           empty;
logic                           parity_check;
logic                           overflow_error;
logic                           break_error;
logic                           stop_error;
logic                           parity_error;
logic                           RX_shift_reg_2_0;
logic                           error_read_data;
logic                           read_not_ready_out;

assign status_register = {read_not_ready_out,
                          overflow_error,
                          stop_error,
                          break_error,
                          parity_error,
                          empty,
                          full,
                          error_read_data};
/*=====================================================================================================================--------------------
  | read_not_ready_out | overflow_error | stop_error | break_error | parity_error | empty | full  | error_write_data  | <== Status Register
  =====================================================================================================================---------------------
*/

uart_control_receiver
uart_control_receiver(
  .clk               (clk               ),
  .reset_n           (reset_n           ),
  .empty             (empty             ),
  .full              (full              ),
  .shift             (shift             ),
  .bit_count_done    (bit_count_done    ),
  .read              (read              ),
  .read_data         (read_data         ),
  .serial_data_in    (serial_data_in    ),
  .sample_count_done1(sample_count_done1),
  .sample_count_done2(sample_count_done2),
  .RX_shift_reg_2_0  (RX_shift_reg_2_0  ),
  .parity_check      (parity_check      ),
  .load_RX_shift_reg (load_RX_shift_reg ),
  .inc_sample_count  (inc_sample_count  ),
  .clr_sample_count  (clr_sample_count  ),
  .inc_bit_count     (inc_bit_count     ),
  .clr_bit_count     (clr_bit_count     ),
  .overflow_error    (overflow_error    ),
  .stop_error        (stop_error        ),
  .parity_error      (parity_error      ),
  .break_error       (break_error       ),
  .read_not_ready_out(read_not_ready_out),
  .error_read_data   (error_read_data   )
  );

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo_receiver(
  .clk     (clk              ),
  .reset_n (reset_n          ),
  .write   (load_RX_shift_reg),
  .empty   (empty            ),
  .full    (full             ),
  .data_in (data_in          ),
  .read    (read             ),
  .data_out(bus_data         )
  );


assign data_in = RX_shift_reg[8:1];

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

always_comb begin : proc_count_done
  bit_count_done = (bit_count == 9);
  sample_count_done1 = (sample_count == 7);
  sample_count_done2 = (sample_count == 15);
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
      RX_shift_reg <= {serial_data_in,RX_shift_reg[DATA_SIZE - 1 : 1]};
    end
    else begin
      RX_shift_reg <= RX_shift_reg;
    end
  end
end

endmodule : uart_receiver