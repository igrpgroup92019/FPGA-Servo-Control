## Generated SDC file "Main.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Fri Mar 15 16:58:07 2019"

##
## DEVICE  "EP2C20F484C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {clk}]
set_input_delay -add_delay -min -clock [get_clocks {clk}]  2.000 [get_ports {clk}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {data_ready}]
set_input_delay -add_delay -min -clock [get_clocks {clk}]  2.000 [get_ports {data_ready}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {data_bit}]
set_input_delay -add_delay -min -clock [get_clocks {clk}]  2.000 [get_ports {data_bit}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {reset}]
set_input_delay -add_delay -min -clock [get_clocks {clk}]  2.000 [get_ports {reset}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {trackswitch_extended}]
set_input_delay -add_delay -min -clock [get_clocks {clk}]  2.000 [get_ports {trackswitch_extended}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  3.000 [get_ports {trackswitch_retracted}]
set_input_delay -add_delay -min -clock [get_clocks {clk}]  2.000 [get_ports {trackswitch_retracted}]



#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {turntable_out}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {track_out}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_ack}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instruction_ready}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {servo_instr[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {~LVDS91p/nCEO~}]
#set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_ready_LED}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_ack_LED}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {reset_LED}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {state[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {state[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_state_LED[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_state_LED[1]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

