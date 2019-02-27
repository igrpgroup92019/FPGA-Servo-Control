module Instruction(enable, set_bit, confirm_bit, clear, instruction, full);
/*
INPUTS:
	enable - enable getting an instruction
	set_bit - current instruction bit sent from MBED
	confirm_bit - confirming current bit, comes from MBED
OUTPUTS:
	instruction - full 11-bit instruction output
	full - high when there is a complete instruction
*/

input set_bit, confirm_bit, enable, clear;
output[9:0] instruction;
output full;

reg [9:0] instruction;
reg full;

reg [3:0] counter; //counter that counts to 11, number of bits in instruction

// Adds instruction bit to register
always @ (posedge confirm_bit & enable)
begin
	if (clear)
	begin
		instruction <= 0;
		counter <= 0;
		full <= 0;
	end
	
	else
	begin
		if (counter == 0) full <= 0;

		instruction <= {instruction[8:0], set_bit};
		
		counter <= counter + 1;
		if (counter > 10) 
		begin
			counter <= 0;
			full <= 1;
		end
	end
end

endmodule