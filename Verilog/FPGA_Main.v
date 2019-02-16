module FPGA_Main(clk, set_bit, input_bit, turntable_pulse, launch_pulse, mbed_data);
input clk, set_bit, input_bit;
output turntable_pulse, launch_pulse;
output [10:0] mbed_data;

// pulse date collection
wire set_bit, input_bit, ready;
wire [10:0] mbed_data; // 1 for activation, 1 for mode select (maintenance/running), 1 for servo, 8 bits -> int
Instruction_Set(set_bit, input_bit, mbed_data, ready);

// servo drivers
reg enableTurntable, enableLauncher;
//wire set_rotation;
Servo_Driver turntable(clk, enableTurntable, clk, mbed_data[7:0], turntable_pulse);
Servo_Driver launcher(clk, enableLauncher, clk, mbed_data[7:0], launch_pulse);

always @ (posedge clk)
begin
	if (ready & mbed_data[10]) // true if there's an active instruction present
	begin
		if (mbed_data[9]) // maintenance
		begin
			//set_rotation <= 1;
			enableTurntable <= mbed_data[8];
			enableLauncher <= !mbed_data[8];
		end
		
		// main operation
		else
		begin
			
		end
	end
	
	else
	begin
		enableTurntable <= 0;
		enableLauncher <= 0;
	end
end

endmodule
