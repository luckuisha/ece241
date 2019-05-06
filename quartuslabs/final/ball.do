# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in orjIIIr.v to working dir
# could also have multiple verilog files
vlog aiball.v

#load simulation using HexDecoder as the top level simulation module
vsim ball

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}




# SW[1] should control LED[0]
force {KEY[0]} 1 0, 0 {2ns} -r 4ns
force {KEY[2]} 1 0, 0 {2ns} -r 4ns
force {CLOCK_50} 1 0, 0 {1ns} -r 2 ns
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[5]} 1
force {SW[4]} 1
force {resetn} 1
force {resetGamen} 1
run 8ns

# SW[1] should control LED[0]
force {KEY[0]} 1 0, 0 {2ns} -r 4ns
force {KEY[2]} 1 0, 0 {2ns} -r 4ns
force {CLOCK_50} 1 0, 0 {1ns} -r 2 ns
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 1
force {SW[5]} 0
force {SW[4]} 0
force {resetn} 1
force {resetGamen} 1
run 8ns




# SW[1] should control LED[0]
force {KEY[0]} 1 0, 0 {2ns} -r 4ns
force {KEY[2]} 1 0, 0 {2ns} -r 4ns
force {CLOCK_50} 1 0, 0 {1ns} -r 2 ns
force {SW[9]} 1
force {SW[3]} 1
force {KEY[1]} 0
force {KEY[3]} 0

run 1000000 ns

