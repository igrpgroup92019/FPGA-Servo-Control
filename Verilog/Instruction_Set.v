module Instruction_Set(set_bit, input_bit, mbed_data, ready);
input set_bit, input_bit;
output [10:0] mbed_data;
output ready;

// pulse date collection
reg [10:0] mbed_data; // 1 for activation, 1 for mode select (maintenance/running), 1 for servo, 8 bits -> int
reg sample;
reg [3:0] pulse_count;

// for sending data to servos
assign ready = !sample;

always @ (posedge set_bit)
begin
	// starts the sampling process if there a data pluse and it ist't started already
	if (!sample)
	begin
		sample <= 1;
	end
	else
	begin
		// this ends the sampling process once all the bits have been collected
		if (pulse_count > 10) // set this number to the max index number of mbed_data (i.e [8:0] mbed_data -> 8)
		begin
			// resets sampling registers
			sample <= 0;
			pulse_count <= 0;
		end
		// collects data
		else 
		begin
			// shifts all the bits along the mbed data register and adds the newest bit at the end
			mbed_data <= {mbed_data[9:0], input_bit};
			// increments the bit counter
			pulse_count <= pulse_count + 1;
		end
	end
end

endmodule
