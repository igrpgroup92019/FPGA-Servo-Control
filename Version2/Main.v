module Main(clk, mbedCommand, confirm, correct, waiting, reset, servo_turntable, servo_track, retracted, extended);
/*
INPUTS:
	clk - clock
	mbedCommand - current MBED bit to accept
	confirm - confirm bit, accept this bit from MBED
	correct - 1 from MBED if correct color is in front of sensor
	reset - go to default state
	retracted - 
	extended - 
OUTPUTS:
	waiting - if 1, accept command, else do not accept
	servo_turntable - output for servo 1
	servo_track - output for servo 2
*/

input clk, mbedCommand, confirm, correct, reset, retracted, extended;
output waiting, servo_turntable, servo_track;

//Helper definitions
parameter size = 	4; //size of state register
reg[size-1: 0] current_state;
wire[size-1: 0] next_state; 
reg turntable_enable, track_enable; //enable bits
wire servo_track, servo_turntable; //outputs to servos

reg[10:0] servoInstr; //the big instruction
wire clearInstruction; // clears the instruction, from reset input and state machine
wire waiting; 
reg getInstruction;

reg [7:0] trackPosition;
reg [7:0] turntablePosition;
parameter trackForwards = 8'b11111111;
parameter trackBackwards = 8'b00000000;
parameter turntableOperateSpeed = 8'b11111111;

assign clearInstruction = reset;

//State definitions
parameter default_state = 2'b00;
parameter turntable_state = 2'b01;
parameter push_track = 2'b10;
parameter pull_track = 2'b11;

//State Machine
always @ (posedge clk)
begin
	case(current_state)
		default_state: begin
			getInstruction <= 1;
			turntable_enable <= 0;
			track_enable <= 0;
		end
		
		turntable_state: begin
			turntable_enable <= 1;
			track_enable <= 0;
			
			if (!servoInstr[9]) // main operation
			begin
				turntablePosition <= turntablePosition;
				if (correct) current_state <= push_track; //find color
			end
			else //maintance mode - info for Alex: correct = to stop if you wanna just spin the turntable, if you wanna find a color use correct normally
			begin
				turntablePosition <= servoInstr[7:0];
				if (correct) current_state <= default_state;
			end
		end
		
		push_track: begin
			track_enable <= 1;
			turntable_enable <= 0;
			
			trackPosition <= trackForwards;
			if (extended)
			begin
				if (!servoInstr[9]) current_state <= pull_track;
				else current_state <= default_state;
			end
		end
		
		pull_track: begin
			track_enable <= 1;
			turntable_enable <= 0;
			
			trackPosition <= trackBackwards;
			if (retracted) current_state <= default_state;
		end
	endcase
end

// once a vaild instruction is recieved
always @ (negedge waiting)
begin
	getInstruction <= 0;
	
end

Instruction(getInstruction, mbedCommand, confirm, clearInstruction, servoInstr, !waiting);
/*
	getInstruction - enable getting an instruction
	mbedCommand - current bit that MBED wants to send (1 bit)
	confirm - confirms that current bit is valid 
*/
ServoDriver_50MHz_30ms turntable(clk, se1, turntablePosition, servo_turntable);
ServoDriver_50MHz_30ms track(clk, se2, trackPosition, servo_track);

assign se1 = !reset & turntable_enable;
assign se2 = !reset & track_enable;


endmodule