module ServoDriver_50MHz_30ms(clk, e, RxD_data, RCServo_pulse);
input clk, e;
input [7:0] RxD_data;
output RCServo_pulse;
//output [15:0] leds;

parameter ClkDiv = 195;  // 50000000/1000/256 = 195.31
reg [20:0] fullPulse_Count; // 20ms = a 50Hz pulse
reg [17:0] smallPulse_Limit;
reg RCServo_pulse;
assign leds = smallPulse_Limit;

always @ (posedge clk & e)
begin
	//smallPulse_Limit <= 50000 + (ClkDiv * RxD_data);  //set servo pulse length to give direction of rotation/motion
	//smallPulse_Limit <= 31000 + (390 * RxD_data);
	smallPulse_Limit = 25000 + (320 * RxD_data);
end

always @ (posedge clk & e)
begin
	if (fullPulse_Count > 1500000) fullPulse_Count <= 0; //pulse every 50hz, 30ms period
	else fullPulse_Count <= fullPulse_Count + 1;
	
	if (smallPulse_Limit > fullPulse_Count) RCServo_pulse <= 1;
	else RCServo_pulse <= 0;
end
endmodule