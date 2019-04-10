module ServoDriver_24MHz_30ms
(
	input clk, enable, 
	input wire[7:0] data, 
	
	output reg servo_pulse
);
/*
INPUTS:
	clk - clock
	enable - an enable bit
	data - the data describing the pulse to the servo, 8-bit (0-255) instruction
OUTPUTS:
	servo_pulse - the servo pulse output
*/

//Assignments:
//parameter ClkDiv = 94; 		// 24000000/1000/256 = 93.75
reg [19:0] fullPulse_Count; 	// 30ms = a 24Hz pulse
reg [16:0] smallPulse_Limit; 	// 3ms = a 24Hz pulse

//Calculation block - hardcoded:
always @ (posedge clk) begin
	if (enable) begin														//modified always blocks to ensure synchronous reset, 
																				//otherwise any glitch can trigger always block + we fix Quartus complaints
		smallPulse_Limit = 11990 + (156 * data); 					//numbers found through trial + error... (mult was 170)
		
		if (fullPulse_Count > 719424) fullPulse_Count <= 0; 	//pulse every 24hz, 30ms period
		else fullPulse_Count <= fullPulse_Count + 1;
	
		if (smallPulse_Limit > fullPulse_Count) servo_pulse <= 1;
		else servo_pulse <= 0;
	end
	else servo_pulse <= 0;
end

endmodule