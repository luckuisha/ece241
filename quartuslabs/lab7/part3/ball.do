# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in orjIIIr.v to working dir
# could also have multiple verilog files
vlog ball.v vga_adapter.v vga_address_translator.v vga_controller.v vgaPll.v

#load simulation using HexDecoder as the top level simulation module
vsim ball

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# SW[1] should control LED[0]
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
force {CLOCK_50} 0

run 1ns

# SW[1] should control LED[0]
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 0
force {CLOCK_50} 1

run 1ns

# SW[1] should control LED[0]
force {SW[0]} 1
force {SW[1]} 1
force {KEY[0]} 1
force {CLOCK_50} 1 0, 0 10ns -r 20 ns
run 99999999999 ns
