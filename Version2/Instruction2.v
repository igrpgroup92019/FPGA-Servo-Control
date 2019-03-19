module Instruction2
(
	input	clk, data_bit, confirm_bit, reset,
	output reg instruction_ready, data_ready,
	output reg[9:0] instruction,
	output reg[1:0] state
);

//reg[1:0] state;
parameter counting = 0, receive = 1, confirmed = 2, complete = 3;
reg[3:0] counter;
reg new_bit;

// confirmed buffer
/*
have data_ready on mbed
fpga reads 1 bit from data line
fpga sends data_ack(nowledged)
data_ready goes low on mbed as soon as it sees ack si gnal
*/
reg [3:0] confirmed_timer;

always @ (posedge clk) begin
	case(state)
		
		counting : begin  //State 0
		
			instruction_ready <= 0;
			if(reset) begin
				instruction <= 0;
				counter <= 0;
			end
			
			if(!reset && !confirm_bit) begin
				//data_ready <= 1;
				if(counter < 10) begin
					data_ready <= 1; //want data_ready = 1 only when we receive data, we DON'T want it = 1 if we go to complete
					state <= receive;
				end
				else state <= complete;
			end
			
		end
		
		receive : begin   //State 1
			
			if(reset) state = counting;
			else if(confirm_bit) begin
				data_ready <= 0;
				new_bit <= data_bit;
				state <= confirmed;
			end
			
		end
		
		confirmed : begin //State 2
		
			//if (confirmed_timer > 10) begin
			counter = counter + 1;
			instruction <= {instruction[8:0], new_bit};
			state <= counting;
			//end
			//else confirmed_timer = confirmed_timer + 1;
			
		end
		
		complete : begin  //State 3
		
			instruction_ready <= 1;
			counter <= 0; //hmm... counter should be reset here, shouldn't matter if it isn't but better add it for reference at least
			if(reset) state <= counting;
			
		end
		
	endcase
	
end

endmodule