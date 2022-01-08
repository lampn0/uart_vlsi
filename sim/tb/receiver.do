onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_receiver/clk
add wave -noupdate /tb_uart_receiver/uart_receiver/clk
add wave -noupdate /tb_uart_receiver/uart_receiver/reset_n
add wave -noupdate /tb_uart_receiver/uart_receiver/serial_data_in
add wave -noupdate /tb_uart_receiver/uart_receiver/rx_start_n
add wave -noupdate /tb_uart_receiver/uart_receiver/data_out
add wave -noupdate /tb_uart_receiver/uart_receiver/rx_done
add wave -noupdate /tb_uart_receiver/uart_receiver/parity_error
add wave -noupdate /tb_uart_receiver/uart_receiver/stop_error
add wave -noupdate /tb_uart_receiver/uart_receiver/break_error
add wave -noupdate /tb_uart_receiver/uart_receiver/overflow_error
add wave -noupdate -radix binary /tb_uart_receiver/uart_receiver/RX_shift_reg
add wave -noupdate /tb_uart_receiver/uart_receiver/bit_count
add wave -noupdate /tb_uart_receiver/uart_receiver/sample_count
add wave -noupdate /tb_uart_receiver/uart_receiver/load_RX_shift_reg
add wave -noupdate /tb_uart_receiver/uart_receiver/inc_bit_count
add wave -noupdate /tb_uart_receiver/uart_receiver/clr_bit_count
add wave -noupdate /tb_uart_receiver/uart_receiver/inc_sample_count
add wave -noupdate /tb_uart_receiver/uart_receiver/clr_sample_count
add wave -noupdate /tb_uart_receiver/uart_receiver/shift
add wave -noupdate /tb_uart_receiver/uart_receiver/parity_check
add wave -noupdate /tb_uart_receiver/uart_receiver/RX_shift_reg_2_0
add wave -noupdate /tb_uart_receiver/uart_receiver/state
add wave -noupdate /tb_uart_receiver/uart_receiver/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1680 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2016 ns}
