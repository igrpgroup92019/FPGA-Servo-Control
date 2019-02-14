// modules set for a clock signal of 50MHz
module Servo_Driver(clk, enable, set_rotation, input_rotation, pulse);
input clk, enable, set_rotation;
input [7:0] input_rotation;
output pulse;

reg [19:0] counter;
reg [7:0] rotation_value;
reg [17:0] thing;
reg pulse;

always @ (posedge set_rotation)
begin
	rotation_value <= input_rotation;
	
end

always @ (posedge clk)
begin
	if (enable)
	begin
		counter <= counter + 1;
		if (counter < 50000) pulse <= 1;
		else if ()
		else 
	end
	else pulse <= 0;
end

endmodule 