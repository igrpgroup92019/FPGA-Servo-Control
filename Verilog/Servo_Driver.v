// modules set for a clock signal of 50MHz
module Servo_Driver(clk, enable, set_rotation, input_rotation, pulse);
input clk, enable, set_rotation;
input [7:0] input_rotation;
output pulse;

reg [19:0] counter;
reg [7:0] rotation_value;
reg [16:0] pulse_length;
reg pulse;

always @ (posedge set_rotation)
begin
	// 50000 = 1ms, 255*196 ~= 50000
	//pulse_length <= (input_rotation*196) + 50000;
	//pulse_length <= (input_rotation*400) + 30000;
	pulse_length <= (input_rotation*392) + 31000;
end

always @ (posedge clk)
begin
	if (enable)
	begin
		counter <= counter + 1;
		if (counter > 1000000) counter <= 0;
		else if (counter > pulse_length) pulse <= 0;
		else pulse <= 1;
	end
	
	else
	begin
		pulse <= 0;
		counter <= 0;
	end
end

endmodule 