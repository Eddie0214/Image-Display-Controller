module LCD_CTRL(clk,reset,datain,cmd,cmd_valid,dataout,output_valid,busy);
input clk;
input reset;
input [7:0] datain;
input [2:0] cmd;
input cmd_valid;
output  [7:0] dataout;
output  output_valid;
output  busy;
reg [2:0]origin_x, origin_y;
reg	magnification;
//reg [7:0]img_buffer[0:63];
reg [7:0]img_buffer[0:7][0:7];
reg [5:0]counter;
reg [1:0] state;
wire [2:0]zoomouty[0:15];
wire [2:0]zoomoutx[0:15];
wire [2:0]zoominy[0:15];
wire [2:0]zoominx[0:15];
wire [2:0]addressy,addressx;
integer i;
assign zoomouty[0]=3'd0;
assign zoomouty[1]=3'd0;
assign zoomouty[2]=3'd0;
assign zoomouty[3]=3'd0;
assign zoomouty[4]=3'd2;
assign zoomouty[5]=3'd2;
assign zoomouty[6]=3'd2;
assign zoomouty[7]=3'd2;
assign zoomouty[8]=3'd4;
assign zoomouty[9]=3'd4;
assign zoomouty[10]=3'd4;
assign zoomouty[11]=3'd4;
assign zoomouty[12]=3'd6;
assign zoomouty[13]=3'd6;
assign zoomouty[14]=3'd6;
assign zoomouty[15]=3'd6;
assign zoomoutx[0]=3'd0;
assign zoomoutx[1]=3'd2;
assign zoomoutx[2]=3'd4;
assign zoomoutx[3]=3'd6;
assign zoomoutx[4]=3'd0;
assign zoomoutx[5]=3'd2;
assign zoomoutx[6]=3'd4;
assign zoomoutx[7]=3'd6;
assign zoomoutx[8]=3'd0;
assign zoomoutx[9]=3'd2;
assign zoomoutx[10]=3'd4;
assign zoomoutx[11]=3'd6;
assign zoomoutx[12]=3'd0;
assign zoomoutx[13]=3'd2;
assign zoomoutx[14]=3'd4;
assign zoomoutx[15]=3'd6;
////////////////////////////////////////
assign zoominy[0] =origin_y;
assign zoominy[1] =origin_y;
assign zoominy[2] =origin_y;
assign zoominy[3] =origin_y;
assign zoominy[4] =origin_y+3'd1;
assign zoominy[5] =origin_y+3'd1;
assign zoominy[6] =origin_y+3'd1;
assign zoominy[7] =origin_y+3'd1;
assign zoominy[8] =origin_y+3'd2;
assign zoominy[9] =origin_y+3'd2;
assign zoominy[10]=origin_y+3'd2;
assign zoominy[11]=origin_y+3'd2;
assign zoominy[12]=origin_y+3'd3;
assign zoominy[13]=origin_y+3'd3;
assign zoominy[14]=origin_y+3'd3;
assign zoominy[15]=origin_y+3'd3;
assign zoominx[0] =origin_x;
assign zoominx[1] =origin_x+3'd1;
assign zoominx[2] =origin_x+3'd2;
assign zoominx[3] =origin_x+3'd3;
assign zoominx[4] =origin_x;
assign zoominx[5] =origin_x+3'd1;
assign zoominx[6] =origin_x+3'd2;
assign zoominx[7] =origin_x+3'd3;
assign zoominx[8] =origin_x;
assign zoominx[9] =origin_x+3'd1;
assign zoominx[10]=origin_x+3'd2;
assign zoominx[11]=origin_x+3'd3;
assign zoominx[12]=origin_x;
assign zoominx[13]=origin_x+3'd1;
assign zoominx[14]=origin_x+3'd2;
assign zoominx[15]=origin_x+3'd3;
////////////////////////////////////////////

//////state machine///////////
always@(posedge clk)begin
if(reset)begin
state<=2'd0;
counter<=6'd0;
end
else begin
		case(state)
		2'd0:  	if(cmd_valid)	begin
									case(cmd)
									3'd1:	state<=2'd1;
									default:state<=2'd3;
									endcase
								end
		2'd1:					//load_data
								if(counter<6'd63)
									counter<=counter+6'd1;
								else begin
									counter<=0;
									state<=2'd3; end 
				
		2'd3:	begin 
					if(counter<6'd15)begin
						counter<=counter+6'd1;
						end
					else begin
						counter<=0;
						state<=2'd0;end
				end
		endcase			
end end
/////////functional work////////////
always@(posedge clk)begin

		case(state)
		2'd0:			if(cmd_valid)begin//decode operation
							case(cmd)
							3'd0:;	 //reflash
							3'd1:;	//load_data		
							3'd2:	begin//zoomin
									magnification<=1;
									{origin_y,origin_x}<={3'b010,3'b010};
									end
							3'd3:	begin//zoomout
									magnification<=0;
									end
							3'd4:	begin//shift right
										if(origin_x==3'b100)
											origin_x<=origin_x;
										else 
											origin_x<=origin_x+3'd1;
									end
							3'd5:	begin//shift left
										if(origin_x==3'b000)
											origin_x<=origin_x;
										else 
											origin_x<=origin_x-3'd1;
									end
							3'd6:	begin//shift up
										if(origin_y==3'b000)
											origin_y<=origin_y;
										else 
											origin_y<=origin_y-3'd1;
									end
							3'd7:	begin//shift down
										if(origin_y==3'b100)
											origin_y<=origin_y;
										else 
											origin_y<=origin_y+3'd1;
									end
							endcase
						end
		2'd1:			begin 	if(counter<6'd63)		
									img_buffer[counter[5:3]][counter[2:0]]<=datain;
								else begin
									img_buffer[counter[5:3]][counter[2:0]]<=datain;
									origin_x<=0;
									origin_y<=0;
									magnification<=0;
								end			
						end
		2'd3: 		;	
		endcase
end
assign	busy=(state==0)?0:1;
assign	output_valid=(state==2'd3 )? 1 :0;
assign	dataout=img_buffer[addressy][addressx];
assign	addressy=(magnification)? zoominy[counter]: zoomouty[counter];
assign	addressx=(magnification)? zoominx[counter]: zoomoutx[counter];
endmodule