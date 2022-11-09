`timescale 1ns / 1ps
module work3(clk,rst,led,button0,button1,sw);

input clk,rst;
input button0,button1,sw;
output [7:0] led;
wire b0,b1;
wire divclk_1,divclk_2;
wire [3:0] Rs,Ls;

div div1(divclk_1,divclk_2,clk,rst);
button bt0(b0,button0,clk,rst);
button bt1(b1,button1,clk,rst);
FSM FSM1(divclk_2,rst,b0,b1,led,Mstar,flag,ledc,Rs,Ls);
MRL MRL1(divclk_1,rst,led,flag,Mstar,ledc,Rs,Ls,sw);

endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module FSM(clk,rst,button0,button1,led,Mstar,flag,ledc,Rs,Ls);
	
	input clk,rst;
	input button0,button1;
	input [7:0] led;
	output reg Mstar,flag,ledc;
	output reg [3:0] Rs,Ls;
//	output reg [7:0] seg7_out;
	reg[2:0] state;
	
	parameter Lstar=3'd0 , Rstar=3'd1 , MR=3'd2 , ML=3'd3; 
	
	always@(posedge clk or negedge rst)
		begin
			if(rst)
				begin
					state<=Lstar;
//					seg7_out<=8'b0;
					Mstar<=0;
					flag<=0;
					ledc<=0;
					Rs<=0;
					Ls<=0;
				end
			else
				begin
					case(state)
						Lstar:
							begin
								if(flag==0 && button0==1)
									begin
										Mstar<=1;
										state<=MR;
										ledc<=1;
									end
								else
									begin
										Mstar<=0;
										state<=Lstar;
										ledc<=0;
									end
							end
						Rstar:
							begin
								if(flag==1 && button1==1)
									begin
										Mstar<=1;
										state<=ML;
										ledc<=1;
									end
								else
									begin
										Mstar<=0;
										state<=Rstar;
										ledc<=0;
									end
							end
						MR:
							begin
							    if(button1==1 && led==8'b0000_0001)
							        begin
							            state<=ML;
							            flag<=1;
							        end
								else if((button1==1 && led!=8'b0000_0001) || led==8'b0000_0000)
									begin
										state<=Lstar;
										Mstar<=0;
										ledc<=0;
										Ls<=Ls+1;
									end
								else
									state<=MR;
							end
						ML:
							begin
							    if(button0==1 && led==8'b1000_0000)
							        begin
							            state<=MR;
							            flag<=0;
							        end
								else if((button0==1 && led!=8'b1000_0000) || led==8'b0000_0000)
									begin
										state<=Rstar;
										Mstar<=0;
										ledc<=0;
										Rs<=Rs+1;
									end
								else
									state<=ML;
							end
					endcase				
				end
		end
endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module MRL(clk,rst,led,flag,Mstar,ledc,Rs,Ls,sw);
	
	input clk,rst;
	input flag,Mstar,ledc,sw;
	input [3:0] Rs,Ls;
	output reg [7:0] led;
	reg [3:0] SR,SL;

	
	always@(posedge clk or negedge rst)
		begin
			if(rst)
			    begin
				    led<=8'b1000_0000;
				    SR<=0;
				    SL<=0;
				end
			else 
				begin
				    SL<=Ls;
				    SR<=Rs;
				    if(sw==1)
				        begin
				            led<={SL,SR};
				        end
				    else
				        begin
					       if(flag==0 && ledc==0)
					           led<=8'b1000_0000;
					       if(flag==1 && ledc==0)
						      led<=8'b0000_0001;	
					       if(flag==0 && ledc==1)
						      led<=led/2;
					       if(flag==1 && ledc==1)
						      led<=led*2;
						end
				end
		end
endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module button(click,in,clk,rst);
	output reg click;
	input in,clk,rst;
	reg [23:0]decnt;

	parameter bound = 24'h000f0f;

	always @ (posedge clk or negedge rst)begin
		if(rst)begin
			decnt <= 0;
			click <= 0;
		end
		else begin
			if(in)begin
				if(decnt < bound)begin
					decnt <= decnt + 1;
					click <= 0;
				end
				else begin
					decnt <= decnt;
					click <= 1;
				end
			end
			else begin
				decnt <= 0;
				click <= 0;
			end
		end
	end
endmodule
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
module div(divclk_1,divclk_2,clk,rst);

input clk,rst;
output divclk_1,divclk_2;
reg [27:0]divclkcnt;

assign divclk_1 = divclkcnt[25];
assign divclk_2 = divclkcnt[20];

always@(posedge clk or negedge rst)begin
    if(rst)
        divclkcnt = 0;
    else
        divclkcnt = divclkcnt + 1;
end
endmodule
