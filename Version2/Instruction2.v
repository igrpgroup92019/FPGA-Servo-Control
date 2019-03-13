module Instruction2
(
	input	clk, data_bit, confirm_bit, reset,
	output reg instruction_ready, waiting_bit,
	output reg[9:0] instruction
);

reg[1:0] state;
parameter counting = 0, receive = 1, confirmed = 2, complete = 3;
integer counter;
reg new_bit;

// confirmed buffer
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
				waiting_bit <= 1;
				if(counter < 10) state = receive;
				else state = complete;
			end
		end
		
		receive : begin   //State 1
			if(reset) state = counting;
			else if(confirm_bit) begin
				new_bit <= data_bit;
				waiting_bit <= 0;
				state <= confirmed;
			end
		end
		
		confirmed : begin //State 2
			if (confirmed_timer > 10) begin
			counter = counter + 1;
			instruction <= {instruction[8:0], new_bit};
			state <= counting;
			end
			else confirmed_timer = confirmed_timer + 1;
		end
		
		complete : begin  //State 3
			instruction_ready <= 1;
			if(reset) state <= counting;
		end
		
	endcase
	
end

endmodule