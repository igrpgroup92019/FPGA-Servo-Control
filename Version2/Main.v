module Main
(
	input clk, data_ready, data_bit, reset, trackswitch_extended, trackswitch_retracted,
	
	output turntable_out, track_out, data_ack, data_ready_LED,
	output wire[9:0] servo_instr,
	
	// Debug
	output data_ack_LED,
	output reset_LED,
	output instruction_ready,
	output reg[1:0] state,
	output wire[1:0] instr_state_LED
);
	
/*
INPUTS:
	clk - clock tick
	data_ready - high if MBED is ready to serve bits, low if not
	data_bit - the data line
	reset - self-explanatory, resets to state 0, stops whatever is going on
	
OUTPUTS:
	data_ack - (in place of CONFIRM) acknowledgement line, where the FPGA acknowledges a received bit from the data line
	track/turntable_out - output signal to servos
	servo_instr - instruction_ready 10-bit instruction 
	instruction_ready - checks whether the FPGA is ready to receive another instruction (= data_ready)

	TODO:
	ensure good logic with clear/instruction_ready
*/
	
	//Declare states and state register:
	//reg [1:0] state;
	parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3;
	
	
	// Assignments:
	reg task_finished = 0; // operation completed, used to reset instruction, IMPLEMENT FURTHER
	
	reg track_enable = 0; //enable bit for the track
	reg turntable_enable = 0; //enable bit for the turntable
	reg[7:0] track_position;
	reg[7:0] turntable_position;
	
	wire se1 = !reset && turntable_enable; //if reset, servo should stop
	wire se2 = !reset && track_enable; //disconnect from reset to see if servo doesnt stop because of that (shouldnt be)
	wire retracted = 0, extended = 0; //TODO: Use with touch switch.
	//wire instruction_ready;
	//wire servo_track, servo_turntable;
	
	// Debug
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
		
		Issues:
		- instruction (2) gets wiped sometimes randomly, data_ready flashes once while that happens (i think)
		- missed bit here or there (2)
		- servo doesn't always stop when it has to
		- dim LEDs why? any problems in main?
	*/
	
	Instruction3 instr (clk, data_ready, data_bit, reset, instruction_ready, data_ack, servo_instr, instr_state_LED);
	ServoDriver_24MHz_30ms servo_turntable (.clk(clk), .enable(se1), .data(turntable_position), .servo_pulse(turntable_out));
	ServoDriver_24MHz_30ms servo_track (.clk(clk), .enable(se2), .data(track_position), .servo_pulse(track_out));
	
	
	// State machine
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
							
							if( (servo_instr[9] == 1) && (servo_instr[8] == 1) ) state <= 3; //11 - go to state 3
							else if(servo_instr[9] == 1) state <= 2;  // 10 - go to State 2
							else if(servo_instr[8] == 1) state <= 1; // 01 - go to State 1
						//	else state <= 0; - don't need 
							
						end
					
					end
				S1 : begin
				
					//if(instruction_ready) begin //not bad to have this here, however servo won't turn if we immediately start passing another instruction if it is here
					
						//if(task_finished | reset ) state <= 0; //go to state 0 if colour is found
						track_enable <= 0;
						turntable_enable <= 1;
						
						turntable_position <= servo_instr[7:0];
						task_finished <= 1; //13.03.19
						//if(reset) state <= 0;
					//end
					//else state <= 0;
					
					end
				S2 : begin
					
					//if(instruction_ready) begin
					
						//if((task_finished | reset) & !extended) state <= 0;
					//	if(task_finished | reset) state <= 0;
						
						if (trackswitch_extended) begin
							//incorporate instruction_ready
							track_enable <= 1;
							turntable_enable <= 0;
							
							track_position <= 8'b11111111;
						end
						else begin
							track_enable <= 0;
							task_finished <= 1;
							
							if (servo_instr[7]) state <= 3;
							else state <= 0;
						end
					//	end
					//else state <= 0;
					
					end
				S3 : begin
				
					//if(instruction_ready) begin
					
						//if((task_finished | reset) & !retracted) state <= 0;
						//incorporate instruction_ready
					//	if(task_finished | reset) state <= 0;
						
						if (trackswitch_retracted) begin
							track_enable <= 1;
							turntable_enable <= 0;
				
							track_position <= 8'b00000000;
						end
						else begin
							track_enable <= 0;
							task_finished <= 1;
							state <= 0;
						end
						
					//	end
					//else state <= 0;
					
					end
			endcase
	end
	
endmodule
