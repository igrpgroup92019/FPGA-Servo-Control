module ServoDriver_50MHz_30ms(clk, enable, data, servo_pulse);
/*
INPUTS:
	clk - clock
	enable - an enable bit
	data - the 8 bit instruction
OUTPUTS:
	servo_pulse - the servo pulse output
*/

input clk, enable;
input [7:0] data;
output servo_pulse;

//Assignments
parameter ClkDiv = 195;  // 50000000/1000/256 = 195.31
reg [20:0] fullPulse_Count; // 20ms = a 50Hz pulse
reg [17:0] smallPulse_Limit;
reg servo_pulse;

//Calculation block - hardcoded
always @ (posedge clk) begin
	if (enable) begin
		smallPulse_Limit = 25000 + (320 * data); //Need better servos or calculation through trial and error...
		
	end
end
//Movement block
always @ (posedge clk) begin
	if (enable) begin //modified always blocks to ensure synchronous reset, otherwise any glitch can trigger always block + we fix Quartus complaints
		if (fullPulse_Count > 1500000) fullPulse_Count <= 0; //pulse every 50hz, 30ms period
		else fullPulse_Count <= fullPulse_Count + 1;
	
		if (smallPulse_Limit > fullPulse_Count) servo_pulse <= 1;
		else servo_pulse <= 0;
	end
end
endmodule