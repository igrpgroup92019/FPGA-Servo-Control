module Main(clk, mbedCommand, confirm, colourCorrect, waiting, reset, servo_turntable, servo_track, retracted, extended, servoInstr);
/*
INPUTS:
	clk - clock
	mbedCommand - current MBED bit to accept
	confirm - confirm bit, accept this bit from MBED
	colourCorrect - 1 from MBED if correct color is in front of sensor
	reset - go to default state
	retracted - the retracted postion switch
	extended - the extended postion switch
OUTPUTS:
	waiting - if 1, accept command, else do not accept
	servo_turntable - output for servo 1
	servo_track - output for servo 2
	servoInstr; for displaying on red LEDs
*/

input clk, mbedCommand, confirm, colourCorrect, reset, retracted, extended;
output waiting, servo_turntable, servo_track;
output [9:0] servoInstr; // for displaying on red LEDs

//Helper definitions
parameter size = 4; //size of state register
reg[size-1: 0] current_state;
wire[size-1: 0] next_state; 
reg turntable_enable, track_enable; //enable bits
wire servo_track, servo_turntable; //outputs to servos

wire [9:0] servoInstr; //the big instruction
wire clearInstruction; // clears the instruction, from reset input and state machine
wire waiting; // ready to accept new instruction
reg taskFinished; // operation completed, used to reset instruction register
reg getInstruction;

reg [7:0] trackPosition;
reg [7:0] turntablePosition;
parameter trackForwards = 8'b11111111;
parameter trackBackwards = 8'b00000000;
parameter turntableOperateSpeed = 8'b11111111;

assign clearInstruction = reset | taskFinished;
assign waiting = !instructionReady;
assign addBit = confirm | taskFinished;

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
			taskFinished <= 0;
			
			if (instructionReady)
			begin
				getInstruction <= 0;
				
				// identifies the next state depending on the instruction
				if (!servoInstr[9]) current_state <= turntable_state; // main operation, otherwise it's maintenance mode
				else if (servoInstr[8]) current_state <= turntable_state; // activate turntable and set rotation to input
				else if (servoInstr[7]) current_state <= push_track; // extend rack servo
				else current_state <= push_track; // retract rack servo
			end
		
			else
			begin
				getInstruction <= 1;
				turntable_enable <= 0;
				track_enable <= 0;
			end
		end
		
		turntable_state: begin
			turntable_enable <= 1;
			track_enable <= 0;
			
			if (!servoInstr[9]) // main operation
			begin
				turntablePosition <= turntablePosition;
				if (colourCorrect) current_state <= push_track; //find color
			end
			else //maintance mode - info for Alex: correct = to stop if you wanna just spin the turntable, if you wanna find a color use correct normally
			begin
				turntablePosition <= servoInstr[7:0];
				if (colourCorrect)
				begin
					current_state <= default_state;
					taskFinished <= 1;
				end
			end
		end
		
		push_track: begin
			track_enable <= 1;
			turntable_enable <= 0;
			
			trackPosition <= trackForwards;
			if (extended)
			begin
				if (!servoInstr[9]) current_state <= pull_track;
				else
				begin
					current_state <= default_state;
					taskFinished <= 1;
				end
			end
		end
		
		pull_track: begin
			track_enable <= 1;
			turntable_enable <= 0;
			
			trackPosition <= trackBackwards;
			if (retracted)
			begin
				current_state <= default_state;
				taskFinished <= 1;
			end
		end
	endcase
	
	if (reset) current_state <= default_state;
end

Instruction instruction_set(getInstruction, mbedCommand, addBit, clearInstruction, servoInstr, instructionReady);
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