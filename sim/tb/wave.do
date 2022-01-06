onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_transmitter/uart_transmitter/clk
add wave -noupdate /tb_uart_transmitter/uart_transmitter/reset_n
add wave -noupdate /tb_uart_transmitter/uart_transmitter/empty
add wave -noupdate -radix binary /tb_uart_transmitter/uart_transmitter/data_in
add wave -noupdate /tb_uart_transmitter/uart_transmitter/data_ready
add wave -noupdate -color Gold -format Literal /tb_uart_transmitter/uart_transmitter/serial_data_out
add wave -noupdate /tb_uart_transmitter/uart_transmitter/tx_done
add wave -noupdate -radix binary /tb_uart_transmitter/uart_transmitter/TX_shift_reg
add wave -noupdate -radix unsigned /tb_uart_transmitter/uart_transmitter/bit_count
add wave -noupdate /tb_uart_transmitter/uart_transmitter/bit_count_done
add wave -noupdate /tb_uart_transmitter/uart_transmitter/load_TX_shift_reg
add wave -noupdate /tb_uart_transmitter/uart_transmitter/start
add wave -noupdate /tb_uart_transmitter/uart_transmitter/shift
add wave -noupdate /tb_uart_transmitter/uart_transmitter/clear
add wave -noupdate /tb_uart_transmitter/uart_transmitter/bit_parity
add wave -noupdate /tb_uart_transmitter/uart_transmitter/state
add wave -noupdate /tb_uart_transmitter/uart_transmitter/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45 ns} 0} {{Cursor 2} {155 ns} 0}
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
WaveRestoreZoom {0 ns} {155 ns}
