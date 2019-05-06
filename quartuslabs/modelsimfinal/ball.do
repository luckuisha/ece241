# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in orjIIIr.v to working dir
# could also have multiple verilog files
vlog test.v 

#load simulation using HexDecoder as the top level simulation module
vsim test

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}




# SW[1] should control LED[0]
force {KEY[0]} 1 0, 0 {2ns} -r 4ns
force {KEY[2]} 1 0, 0 {2ns} -r 4ns
force {KEY[1]} 0
force {KEY[3]} 0
force {CLOCK_50} 1 0, 0 {1ns} -r 2 ns
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 1
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 0
force {SW[9]} 0
run 1000ns

# SW[1] should control LED[0]
force {KEY[0]} 1 0, 0 {2ns} -r 4ns
force {KEY[2]} 1 0, 0 {2ns} -r 4ns
force {CLOCK_50} 1 0, 0 {1ns} -r 2 ns
force {SW[0]} 1
force {SW[7]} 0
force {SW[6]} 0

run 1000ns



# SW[1] should control LED[0]
force {KEY[0]} 1 0, 0 {2ns} -r 4ns
force {KEY[2]} 1 0, 0 {2ns} -r 4ns
force {CLOCK_50} 1 0, 0 {1ns} -r 2 ns
force {SW[9]} 1
run 500000 ns
