module Instruction(clk, data_bit, confirm_bit, reset, data_ready, full, instruction);
/*
INPUTS:
	data_bit - current instruction bit sent from MBED
	confirm_bit - confirming current bit, comes from MBED
	full - a bit specifying if we have a full instruction
	reset - synchronously reset instruction when confirm_bit and reset are high
OUTPUTS:
	instruction - full 10-bit instruction output
	data_ready - syncronization bit, FPGA confirms it received a bit; also known as a feedback bit (tri-state) / can modify to data_ready and make it maybe better... rn its stuck at 1
		use assign sync_bit = data_bit ? confirm-bit : 1'bz; -> data-bit decides whether sync_bit is an input or a tri-state, driving out value of sync - NEEDS WORK
*/

input clk, data_bit, confirm_bit, reset;
output[9:0] instruction;
output data_ready, full;

reg [9:0] instruction;
reg [9:0] instruction_helper;
reg data_ready;
reg full = 0;

integer counter = 0; //internal counter that counts to 10, number of bits in instruction

always @ (posedge clk) begin

if(data_ready == 1 & confirm_bit == 1) begin 

	//if(confirm_bit == 1) begin

		//Start off with checking for reset, if reset == 0, continue
		if (reset == 0) begin
				data_ready <= 0;
				
				if (counter < 10) begin
					//data_ready <= 0;
					full <= 0;
					instruction <= {instruction[8:0], data_bit}; // Adds instruction bit to register
					counter <= counter + 1; // increment counter
				end
		
				else begin
					counter <= 0;
					//instruction <= instruction_helper; //to have the old instruction replace the new one in full, evading any possible transition errors
					full <= 1;
					//need to put smth here to prevent it going into the 'if' above if full... but it might just be a valid start of an istruction... hmm...
				end
				
			end 
			
			else begin //if reset == 1, zero the istruction register
				instruction = 10'b0;
				counter <= 0;
				//data_ready <= 0; //confirm that reset was received
			end
		
		//end 
	
		//else begin //if confirm == 0
			
		//end
		
	end
	
	// if data_ready == 0
	else if (confirm_bit == 0) data_ready <= 1;
	
end


endmodule