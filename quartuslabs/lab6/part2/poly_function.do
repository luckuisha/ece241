# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog poly_function.v

#load simulation using mux as the top level simulation module
vsim poly_function

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# first test case
#set input values using the force command, signal names need to be in {} brackets

#set up clock
force {CLOCK_50} 0 0ns, 1 {10ns} -r 20ns
run 200ns

#resetn
force {KEY[0]} 0
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns







#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns


#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns






#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 0
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns


#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 0
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns







#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns






#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns


#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns


#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 0
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns

#resetn
force {KEY[0]} 1
#go
force {KEY[1]} 1
#data_in
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0
force {SW[7]} 0
#run simulation for a few ns
run 40ns
