module Instruction3 
(
	input	clk, data_ready, data_bit, reset,
	output reg instruction_ready, data_ack,
	output reg[9:0] instruction,
	output reg[1:0] state
); //Writing instruction type 3, hopefully this time it's okay, leave debug features on for now

/* 4-step description of handshake:
	Have data_ready on MBED
	FPGA reads 1 bit from data line
	FPGA sends data_ack(nowledged)
	The data_ready goes low on MBED as soon as it sees ack signal
	_____________________________________________________________
	
	FPGA just gets the bits too fast otherwise, causes race condition
*/

//reg[1:0] state;
parameter counting = 0, receive = 1, acknowledge = 2, complete = 3;
reg[3:0] counter;
reg new_bit;

/*InstructionRegister instr_reg (   <- use this ?
	.clock(clk),
	.sclr(reset),
	.shiftin(put a wire here that is = data_bit),
	.q(instruction);*/

always @ (posedge clk) begin
	case(state)
		
		counting : begin  //State 0
			
			instruction_ready <= 0;
			data_ack <= 0;
			
			if(!reset) begin
				if(counter < 10) begin
					if(data_ready == 1) state <= receive; //wait here until data_ready = 1
				end
				
				else state <= complete;
			end
			
			else begin //if reset == 1
				instruction <= 0;
				counter <= 0;
			end
			
		end
		
		receive : begin   //State 1
			if(!reset) begin
				new_bit <= data_bit; //buffer into a register to avoid multiple bits
				instruction <= {instruction[8:0], new_bit};
				counter = counter + 1;
				state <= acknowledge;
			end
			
			else begin
				instruction <= 0;
				counter <= 0;
				state <= counting;
			end
		end
		
		acknowledge : begin //State 2
			if(!reset) begin
				data_ack <= 1;
				state <= counting;
			end
			
			else begin
				instruction <= 0;
				counter <= 0;
				state <= counting;
			end
		end
		
		complete : begin  //State 3
		
			instruction_ready <= 1;
			counter <= 0;
			if(reset) state <= counting; //need reset to jump back to counting, plus its good to have instruction_ready = 1 for a while
			
		end
		
	endcase
	
end

endmodule