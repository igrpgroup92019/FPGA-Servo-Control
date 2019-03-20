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


always @ (posedge clk) begin
if(reset) begin
	instruction <= 0;
	counter <= 0;
	state <= counting;
end

	else begin

	case(state)
		
		counting : begin  //State 0

			instruction_ready <= 0;
			data_ack <= 0;
			
			if(!reset) begin
				if(counter < 11) begin
					if(data_ready == 1) begin
						
						state <= receive; //wait here until data_ready = 1
					end
				end
			
				else state <= complete;
			end
			
		end
		
		receive : begin   //State 1
		
			if(!reset && !data_ack) begin
			
				//new_bit <= data_bit; //buffer into a register to avoid multiple bits
				instruction <= {instruction[8:0], data_bit};
				counter = counter + 1;
				
				state <= acknowledge;
				
			end
			
		end
		
		acknowledge : begin //State 2
		
			data_ack <= 1;
				
			if(!data_ready) begin 
				state <= counting;
			end
			
		end
		
		complete : begin  //State 3
		
			if(!reset) begin
				instruction_ready <= 1;
				data_ack <= 1;
				counter <= 0;
			end
			
		end
		
		default: state <= counting;
		
	endcase
	
	end
end
	

endmodule