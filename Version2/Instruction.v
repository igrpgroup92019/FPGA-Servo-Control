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

// TODO: if detect posedge (clear) begin instrRegister <= 0; AND add clear command to this module from the non-default states

input set_bit, confirm_bit, enable;
output[10:0] instruction;
output full;

reg [10:0] instruction;
reg full;

reg [3:0] counter; //counter that counts to 11, number of bits in instruction

always @ (posedge confirm_bit & enable)
begin
	if (counter == 0) full <= 0;

	instruction <= {instruction[9:0], set_bit};
	
	counter <= counter + 1;
	if (counter > 11) 
	begin
		counter <= 0;
		full <= 1;
	end
end

endmodule