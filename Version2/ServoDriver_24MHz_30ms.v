module ServoDriver_24MHz_30ms(clk, enable, data, servo_pulse, smallPulse_Limit);
/*
INPUTS:
	clk - clock
	enable - an enable bit
	data - the 8 bit instruction
OUTPUTS:
	servo_pulse - the servo pulse output
*/

input clk, enable;
input wire[7:0] data;
output servo_pulse;
output[16:0] smallPulse_Limit;

//Assignments
//parameter ClkDiv = 94;  // 24000000/1000/256 = 93.75
reg [19:0] fullPulse_Count; // 30ms = a 24Hz pulse
reg [16:0] smallPulse_Limit; // 3ms = a 24Hz pulse
reg servo_pulse;

//Calculation block - hardcoded
always @ (negedge clk) begin
	if (enable) begin
	
		//smallPulse_Limit = 25000 + (320 * data); //Need better servos or calculation through trial and error...
		//smallPulse_Limit = 11990 + (235 * data); //Need better servos or calculation through trial and error...
		//smallPulse_Limit = 6000 + (118 * data);  //Need better servos or calculation through trial and error...
		
		if (fullPulse_Count > 719424) fullPulse_Count <= 0; //pulse every 24hz, 30ms period
		//if (fullPulse_Count > 359712) fullPulse_Count <= 0; //pulse every 24hz, 30ms period
		else fullPulse_Count <= fullPulse_Count + 1;
	
		if (smallPulse_Limit > fullPulse_Count) servo_pulse <= 1;
		else servo_pulse <= 0;
	end
end
/*
//Movement block
always @ (posedge clk) begin
	if (enable) begin //modified always blocks to ensure synchronous reset, otherwise any glitch can trigger always block + we fix Quartus complaints
	end
end
*/
always @ (posedge clk) begin
	if (enable) begin
	
		//smallPulse_Limit = 25000 + (320 * data); //Need better servos or calculation through trial and error...
		smallPulse_Limit = 11990 + (235 * data); //Need better servos or calculation through trial and error...
		//smallPulse_Limit = 6000 + (118 * data);  //Need better servos or calculation through trial and error...
		end
end

endmodule