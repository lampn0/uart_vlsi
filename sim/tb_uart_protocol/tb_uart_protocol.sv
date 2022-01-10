`timescale 1ns/1ns

module tb_uart_protocol_2 #(
    parameter   DATA_SIZE       =   8,
                SIZE_FIFO       =   8,
                BIT_COUNT_SIZE  =   $clog2(DATA_SIZE+1),
                SYS_FREQ        =   100000000,
                BAUD_RATE       =   9600,
                CLOCK           =   SYS_FREQ/BAUD_RATE,
                SAMPLE          =   16,
                BAUD_DVSR       =   SYS_FREQ/(SAMPLE*BAUD_RATE)
)();
logic                       clk                 ;
logic                       reset_n;
// Device 1 drive pins
logic                       write_data_1        ;
logic                       read_data_1         ;
logic                       serial_data_in_1    ;
logic   [DATA_SIZE-1:0]     bus_data_in_1       ;
logic   [DATA_SIZE-1:0]     bus_data_out_1      ;
logic                       serial_data_out_1   ;
logic   [7:0]               TX_status_register_1;
logic   [7:0]               RX_status_register_1;
// Device 2 drive pins
logic                       write_data_2        ;
logic                       read_data_2         ;
logic   [DATA_SIZE-1:0]     bus_data_in_2       ;
logic   [DATA_SIZE-1:0]     bus_data_out_2      ;
logic   [7:0]               TX_status_register_2;
logic   [7:0]               RX_status_register_2;

uart_protocol #(
    .DATA_SIZE  (DATA_SIZE      ),
    .SIZE_FIFO  (SIZE_FIFO      ),
    .SYS_FREQ   (SYS_FREQ       ),
    .BAUD_RATE  (BAUD_RATE      ),
    .SAMPLE     (SAMPLE         )
)
uart_protocol_1(
    .clk                (clk                    ),
    .reset_n            (reset_n                ),
    .read_data          (read_data_1            ),
    .write_data         (write_data_1           ),
    .serial_data_in     (serial_data_in_1       ),
    .serial_data_out    (serial_data_out_1      ),
    .RX_status_register (RX_status_register_1   ),
    .TX_status_register (TX_status_register_1   ),
    .bus_data_in        (bus_data_in_1          ),
    .bus_data_out       (bus_data_out_1         )
);

uart_protocol #(
    .DATA_SIZE  (DATA_SIZE      ),
    .SIZE_FIFO  (SIZE_FIFO      ),
    .SYS_FREQ   (SYS_FREQ       ),
    .BAUD_RATE  (BAUD_RATE      ),
    .SAMPLE     (SAMPLE         )
)
uart_protocol_2(
    .clk                (clk                    ),
    .reset_n            (reset_n                ),
    .read_data          (read_data_2            ),
    .write_data         (write_data_2           ),
    .serial_data_in     (serial_data_in_2       ),
    .serial_data_out    (serial_data_out_2      ),
    .RX_status_register (RX_status_register_2   ),
    .TX_status_register (TX_status_register_2   ),
    .bus_data_in        (bus_data_in_2          ),
    .bus_data_out       (bus_data_out_2         )
);

assign serial_data_in_2 = serial_data_out_1;

always #5 clk = ~clk;

// assign bus_data_in_2 = bus_data_out_2;

initial begin
    // Set initial running conditions
    clk = 0;
    reset_n = 1;

    repeat(2) @(negedge clk);
    reset_n = 0;

    @(negedge clk);
    reset_n = 1;

    @(negedge clk);
    bus_data_in_1 = $random();
    write_data_1 = 1;
    write_data_2 = 0;
    read_data_2 = 1;
    read_data_1 = 0;

    @(negedge clk);
    write_data_1 = 0;

    repeat(2) @(negedge clk);
    bus_data_in_1 = $random();
    write_data_1 = 1;
    write_data_2 = 0;

    repeat(10) @(negedge clk);
    write_data_2 = 1;

    @(negedge clk);
    // bus_data_in_1 = $random();

    @(negedge clk);
    write_data_1 = 0;
    write_data_2 = 0;

    repeat(220000) @(negedge clk);
    write_data_2 = 1;
    // read_data_2 = 1;
    repeat(10) 

    repeat(200000) @(negedge clk);

    $finish;
end

endmodule : tb_uart_protocol_2