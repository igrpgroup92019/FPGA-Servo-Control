module Instruction(data_bit, confirm_bit, sync_bit, clear, reset, instruction);
/*
INPUTS:
	data_bit - current instruction bit sent from MBED
	confirm_bit - confirming current bit, comes from MBED
	clear - a bit specifying if the instruction is to be wiped or not
	reset - synchronously reset instruction when confirm_bit and reset are high
OUTPUTS:
	instruction - full 10-bit instruction output
	sync_bit - syncronization bit, FPGA confirms it received a bit; also known as a feedback bit (tri-state) / can modify to data_ready and make it maybe better... rn its stuck at 1
		use assign sync_bit = data_bit ? confirm-bit : 1'bz; -> data-bit decides whether sync_bit is an input or a tri-state, driving out value of sync - NEEDS WORK
*/

input data_bit, confirm_bit, clear, reset;
output[9:0] instruction;
inout sync_bit;

reg [9:0] instruction;
reg [9:0] instruction_helper;
reg sync;
integer counter = 0; //internal counter that counts to 10, number of bits in instruction


always @ (posedge confirm_bit) begin
	//Start off with checking for reset, if reset == 0, continue
	if (reset == 0) begin
	
		if (clear == 0) begin 
		
			//if clear == 0, the instruction is received serially
			if (counter < 10) begin
				instruction_helper <= {instruction_helper[8:0], data_bit}; // Adds instruction bit to register
				counter <= counter + 1; // increment counter
				sync <= 1;
			end
		
			else begin
				counter <= 0;
				instruction <= instruction_helper; //to have the old instruction replace the new one in full, evading any possible transition errors
				//need to put smth here to prevent it going into the 'if' above if full... but it might just be a valid start of an istruction... hmm...
			end
			
		end //if clear == 1, zero the instruction register
		else begin 
			instruction = 10'b0;
			counter <= 0;
		end
		
	end //if reset == 1, zero the instruction register
	else begin 
		instruction = 10'b0;
		counter <= 0;
		sync <= 1; //confirm that reset was received
	end
end

endmodule