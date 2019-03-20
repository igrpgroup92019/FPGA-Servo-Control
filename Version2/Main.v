module Main
(
	input clk, data_ready, data_bit, reset, trackswitch_extended, trackswitch_retracted,
	
	output turntable_out, track_out, data_ack, instruction_ready,
	output wire[9:0] servo_instr,
	
	//Debug / LEDs:
	output data_ready_LED, data_ack_LED, reset_LED,
	output reg[1:0] state,
	output wire[1:0] instr_state_LED
);
	
/*
INPUTS:
	clk - clock tick
	data_ready - high if MBED is ready to serve bits, low if not
	data_bit - the data line
	reset - self-explanatory, resets to state 0, stops whatever is going on
	trackswitch_extended/retracted - inputs from the toggle switches 
	
OUTPUTS:
	data_ack - acknowledgement line, where the FPGA acknowledges a received bit from the data line
	track/turntable_out - output signal to servos
	servo_instr - 10-bit instruction, first 2/3 bits describe state, 8 bits desribe servo pulse
	instruction_ready - checks whether the FPGA is ready to receive another instruction, this outputs to LED
*/
	
//Declare states and state register:
//reg [1:0] state;
parameter main_state = 0, turntable = 1, push = 2, pull = 3;
	
	
// Assignments:	
reg track_enable = 0; 							//enable bit for the track
reg turntable_enable = 0; 						//enable bit for the turntable
reg[7:0] track_position;
reg[7:0] turntable_position;

wire se1 = !reset && turntable_enable; 	//if reset, servo should stop
wire se2 = !reset && track_enable; 			//disconnect from reset to see if servo doesnt stop because of that (shouldnt be)
//wire instruction_ready;
	
// Debug assignments:
	assign data_ack_LED = data_ack;
	assign reset_LED = reset;
	assign data_ready_LED = data_ready;
	
/* Debug LEDs:
	LED G3 - data_ready
	LED G2 - instruction_ready
	LED G1 - reset
	LED G0 - data_ack
		
	LED G7, G6 - current state (should mirror red LEDs 9 and 8)
	LED G5, G4 - current instruction state (0 - counting, 1 - receive, 2 - confirmed, 3 - complete)
*/
	
Instruction3 instr 
(
	.clk(clk), 
	.data_ready(data_ready), 
	.data_bit(data_bit), 
	.reset(reset), 
	.instruction_ready(instruction_ready), 
	.data_ack(data_ack), 
	.instruction(servo_instr), 
	.state(instr_state_LED)
);
	
ServoDriver_24MHz_30ms servo_turntable 
(
	.clk(clk), 
	.enable(se1), 
	.data(turntable_position), 
	.servo_pulse(turntable_out)
);
	
ServoDriver_24MHz_30ms servo_track 
(
	.clk(clk), 
	.enable(se2), 
	.data(track_position), 
	.servo_pulse(track_out)
);
	
// --------------------------------------- State machine start -------------------------------------------
always @ (posedge clk) begin
	if (reset == 1) begin 		
		state <= main_state;
	end
	
	else
		case (state)
			main_state : begin
			
				track_enable <= 0;
				turntable_enable <= 0;
				
				if(instruction_ready) begin
							
					if( (servo_instr[9] == 1) && (servo_instr[8] == 1) ) state <= pull; 	// 11 - go to state 3
					else if(servo_instr[9] == 1) state <= push; 									// 10 - go to State 2
					else if(servo_instr[8] == 1) state <= turntable; 							// 01 - go to State 1
																												// else stay in State 0	
				end
					
			end
					
			turntable : begin
	
				track_enable <= 0;
				turntable_enable <= 1;
				turntable_position <= servo_instr[7:0]; 	//set servo to angle specified in GUI 
					
			end
					
			push : begin
				
				turntable_enable <= 0;		
				
				if (trackswitch_extended) begin 				//toggle switch use - *note: it's inverted !* 
					track_enable <= 1;
					track_position <= 8'b11111111;
				end
				
				else begin
					track_enable <= 0;

					if (servo_instr[7]) state <= pull;		//if MBED specifies 7-th bit HIGH, automatically go to pull
					else state <= main_state;
				end
					
			end
				
			pull : begin
				turntable_enable <= 0;
				
				if (trackswitch_retracted) begin 			//toggle switch use - *note: it's inverted !* 
					track_enable <= 1;
					track_position <= 8'b00000000;
				end
				
				else begin 											//toggle switch goes low, stop track
					track_enable <= 0;
					state <= main_state;
				end
					
			end
		endcase

	end //end else
// --------------------------------------- State machine end -------------------------------------------
endmodule
