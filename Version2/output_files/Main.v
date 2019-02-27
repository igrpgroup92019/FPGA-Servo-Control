module Main(clk, e, RxD_data, RCServo_pulse);
input clk, e;
input [7:0] RxD_data;
output RCServo_pulse;

parameter ClkDiv = 195;  // 50000000/1000/256 = 195.31
reg [18:0] fullPulse_Count; // 20ms = a 50Hz pulse
reg [15:0] smallPulse_Limit;
reg RCServo_pulse;

always @ (posedge e)
begin
	smallPulse_Limit <= 50000 + (ClkDiv * RxD_data);
end

always @ (posedge clk & e)
begin
	if (fullPulse_Count > 1000000) fullPulse_Count <= 0;
	else fullPulse_Count <= fullPulse_Count + 1;
	
	if (smallPulse_Limit > fullPulse_Count) RCServo_pulse <= 1;
	else RCServo_pulse <= 0;
end
endmodule