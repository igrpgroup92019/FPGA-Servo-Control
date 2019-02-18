module FPGA_Main(clk, set_bit, input_bit, reset, turntable_pulse, launch_pulse, mbed_data, enableTurntable, enableLauncher, ready); // mbed last one
input clk, set_bit, input_bit, reset;
output turntable_pulse, launch_pulse;
output [10:0] mbed_data;

output enableTurntable, enableLauncher, ready;

// pulse date collection
wire clk, reset, set_bit, input_bit, ready;
wire [10:0] mbed_data; // 1 for activation, 1 for mode select (maintenance/running), 1 for servo, 8 bits -> int
Instruction_Set(reset, set_bit, input_bit, mbed_data, ready);

// servo drivers
reg enableTurntable, enableLauncher;
Servo_Driver turntable(clk, enableTurntable, ready, mbed_data[7:0], turntable_pulse);
Servo_Driver launcher(clk, enableLauncher, ready, launcher_position, launch_pulse);

// automated launcher movement
reg linearPosition;
reg [7:0] launcher_position;
reg [7:0] extendedPosition;
reg [7:0] retractedPosition;
reg [25:0] extension_timer; // counts for 1 second

always @ (posedge clk)
begin
	if (ready & mbed_data[10]) // true if there's an active instruction present
	begin
		 // maintenance mode
		if (mbed_data[9])
		begin
			enableTurntable <= mbed_data[8];
			enableLauncher <= !mbed_data[8];
			
			if (!mbed_data[8]) launcher_position <= mbed_data[7:0];
		end
		
		// linear servo automation
		else
		begin
			extension_timer <= extension_timer + 1;
			if (extension_timer > 50000000)
			begin
				extension_timer <= 0;
				linearPosition <= 1;
			end
			
			if (!linearPosition) launcher_position <= extendedPosition;
			else launcher_position <= retractedPosition;
		end
	end
	
	else if (ready)
	begin
		// set end position mode
		if (mbed_data[9])
		begin
			if (mbed_data[8]) extendedPosition <= mbed_data[7:0];
			else retractedPosition <= mbed_data[7:0];
		end
		
		// stop all servo movement
		else
		begin
			enableTurntable <= 0;
			enableLauncher <= 0;
			linearPosition <= 0;
		end
	end
	
	else
	begin
		enableTurntable <= 0;
		enableLauncher <= 0;
		linearPosition <= 0;
	end
end

endmodule
