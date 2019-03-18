module Main
(
	input clk, command, confirm, reset, 
	
	output turntable_out, track_out, data_ready,
	output wire[9:0] servo_instr,
	
	// debug
	output data_ready_LED,
	output reset_LED,
	output instruction_ready,
	output reg[1:0] state,
	output wire[1:0] instr_state_LED
);
	
/*
INPUTS:
	clk - clock
	confirm - confirming current bit, comes from MBED
	reset - self-explanatory, resets to state 0, stops whatever is going on
	data_ready - feedback to MBED
	instruction_ready - checks whether the FPGA is ready to receive another instruction (= data_ready)
OUTPUTS:
	servo_track, servo turntable - two helper wires, look to remove from outputs if allowed
	servo_instr - instruction_ready 10-bit instruction 
TODO:
	ensure good logic with clear/instruction_ready
	
*/
	
	// Declare states and state register:
	//reg [1:0] state;
	parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3;
	
	
	// Assignments:
	reg task_finished = 0; // operation completed, used to reset instruction
	
	reg track_enable = 0; //enable bit for the track
	reg turntable_enable = 0; //enable bit for the turntable
	reg[7:0] track_position;
	reg[7:0] turntable_position;
	
	wire se1 = !reset & track_enable;
	wire se2 = !reset & turntable_enable;
	wire retracted = 0, extended = 0;
	//wire instruction_ready;
	//wire servo_track, servo_turntable;
	
	// debug
	assign data_ready_LED = data_ready;
	assign reset_LED = reset;
	/* LED G2 - instruction_ready
		LED G1 - reset
		LED G0 - data_ready
		
		LED G7, G6 - current state (should mirror red LEDs 9 and 8)
		LED G5, G4 - current instruction state (0 - counting, 1 - receive, 2 - confirmed, 3 - complete)
		
		Issues:
		- instruction gets wiped sometimes randomly, data_ready flashes once while that happens (i think)
		- missed bit here or there
		- servo doesn't always stop when it has to
	*/
	
	Instruction2 instr (clk, command, confirm, reset, instruction_ready, data_ready, servo_instr, instr_state_LED);
	ServoDriver_50MHz_30ms servo_turntable (clk, se1, turntable_position, track_out);
	ServoDriver_50MHz_30ms servo_track (clk, se2, track_position, turntable_out);
	
	
	// Determine the next state
	always @ (posedge clk) begin
		if (reset == 1) begin
			state <= S0;
		end
		else
			case (state)
				S0 : begin
				
					track_enable <= 0;
					turntable_enable <= 0;
					
					if(instruction_ready) begin
					
						//track_position <= 2'b10000000;
						//turntable_position <= 2'b10000000;
						
						
							task_finished <= 0;
							
							if( (servo_instr[9]) == 1 && (servo_instr[8] == 1) ) state <= 3; //11 - go to state 3
							else if(servo_instr[9] == 1) state <= 2;  // 10 - go to State 2
							else if(servo_instr[8] == 1) state <= 1; // 01 - go to State 1
						//	else state <= 0;
							
						end
					//else state <= 0;
					
					end
				S1 : begin
				
					//if(instruction_ready) begin
					
						//if(task_finished | reset ) state <= 0; //go to state 0 if colour is found
						//until color is found, instruction_ready = 0 ?
						track_enable <= 0;
						turntable_enable <= 1;
						
						turntable_position <= servo_instr[7:0];
						task_finished <= 1; //13.03.19
						state <= 0;
					//end
					//else state <= 0;
					
					end
				S2 : begin
					
					//if(instruction_ready) begin
					
						//if((task_finished | reset) & !extended) state <= 0;
					//	if(task_finished | reset) state <= 0;
						
						//incorporate instruction_ready
						track_enable <= 1;
						turntable_enable <= 0;
						
						track_position <= 8'b11111111;
						task_finished <= 1;
						state <= 0;
						
					//	end
					//else state <= 0;
					
					end
				S3 : begin
				
					//if(instruction_ready) begin
					
						//if((task_finished | reset) & !retracted) state <= 0;
						//incorporate instruction_ready
					//	if(task_finished | reset) state <= 0;
						
						track_enable <= 1;
						turntable_enable <= 0;
			
						track_position <= 8'b00000000;
						task_finished <= 1;
						state <= 0;
						
					//	end
					//else state <= 0;
					
					end
			endcase
	end
	
endmodule
