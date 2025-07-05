// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	img,
	ker,
	weight,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input [7:0] img;
input cg_en;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter scale    = 2295;
parameter scale_41 = 510;
integer i, j;
//==============================================//
//           reg & wire declaration             //
//==============================================//
// ---------- INPUT --------------- //
reg in_valid_d;

reg [2:0] counter_x;
reg [2:0] counter_y;


reg [7:0]  img_1_max[0:5][0:5];
// reg [7:0]  img_2_max[0:5][0:5];
reg [7:0]    ker_max[0:2][0:2];
reg [7:0] weight_max[0:1][0:1];
// ---------- INPUT --------------- //
// ---------- cnt & flag ---------- //
reg [6:0] big_cnt;

// ---------- cnt & flag ---------- //
// ---------- CALUC --------------- //
reg [2:0] counter_cal_x;
reg [2:0] counter_cal_y;

reg [2:0] counter_cal_x_d;
reg [2:0] counter_cal_y_d;

reg [15:0] mul[0:2][0:2];

reg [7:0] quantization_max_1[0:3][0:3];

wire [7:0] quantization;

// ---------- CALUC --------------- //
// ---------- MAXPO --------------- //
reg [7:0] max_pool_1,max_pool_2,max_pool_3,max_pool_4;
reg [7:0] max_pool_5,max_pool_6,max_pool_7,max_pool_8;
reg [7:0] max_pool_1_1, max_pool_1_2, max_pool_1_3;
reg [7:0] max_pool_2_1, max_pool_2_2, max_pool_2_3;
reg [7:0] max_pool_1_3_d,max_pool_2_3_d;

reg [15:0] mul_out_1, mul_out_2, mul_out_3, mul_out_4;
reg [6:0] dist_1 [0:3];
reg [6:0] dist_2 [0:3];


reg [9:0] mul_max_1[0:1][0:1];
reg [9:0] mul_max_2[0:1][0:1];

reg [9:0] l1_diatance;
reg [9:0] l1_diatance_out;

reg [9:0] abs_diff [0:3];

// ---------- MAXPO --------------- //
reg [1:0] c_s, n_s;
parameter S0_IDLE = 0;
parameter S1_INVALID = 1;
parameter S2_OUT  = 2;
// ---------- CG CG CG ------------ //
reg started;
// ---------- CG CG CG ------------ //
//==============================================//
//                  design                      //
//==============================================//
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
        c_s <= S0_IDLE;
    else
        c_s <= n_s;
end
  always @(*)begin
      case (c_s)
          S0_IDLE:
            begin
                if (in_valid)
                    n_s = S1_INVALID;
                else
                    n_s = S0_IDLE;
            end
          S1_INVALID:
            begin
                if (big_cnt == 74)
                // if (big_cnt == 73)
                    n_s = S2_OUT;
                else
                    n_s = S1_INVALID;
            end

          S2_OUT:
            begin
                n_s = S0_IDLE;
            end
          default:
              n_s = S0_IDLE;
      endcase
  end

// ---------- big_cnt --------------- //
always @(posedge clk or negedge rst_n)begin
  if(!rst_n) big_cnt <= 0;
  else begin
    if (c_s==S0_IDLE) big_cnt <= 0;
    else if (in_valid) big_cnt <= big_cnt+1;
	else if (c_s==S1_INVALID) big_cnt <= big_cnt+1;
    else if (c_s==S2_OUT) big_cnt <= big_cnt+1;
    else   big_cnt <= big_cnt;
  end
end
// ---------- CG_START --------------- //
wire ctrl_start = started;
wire G_sleep_start = (cg_en && started)? ctrl_start : 1'b0;
wire G_clock_start;
GATED_OR instgor4( .CLOCK(clk), .SLEEP_CTRL(G_sleep_start), .RST_N(rst_n), .CLOCK_GATED(G_clock_start) );

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) started <= 0;
	else if(in_valid) started <= 1;	
end
// ---------- CG_START --------------- //
//---------- counter X, Y------------------------------------
// ---------- CG_counter_x_y ----------------- //
// wire ctrl_counter_x_y = (big_cnt < 71) ? 1'b0 : 1'b1;
// wire G_sleep_counter_x_y = (cg_en && started)? ctrl_counter_x_y : 1'b0;
// wire G_clock_counter_x_y;
// GATED_OR GATED_counter_x_y( .CLOCK(clk), .SLEEP_CTRL(G_sleep_counter_x_y), .RST_N(rst_n), .CLOCK_GATED(G_clock_counter_x_y) );
// ---------- CG_WEIGHT ----------------- //
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin 
		counter_x <= 0;
	end
	else if (in_valid || c_s==S1_INVALID) begin
		if (counter_x == 5) counter_x <= 0;
		else counter_x <= counter_x + 1;
	end
	else if(c_s==S2_OUT) counter_x <= 0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		counter_y <= 0;
	end
	else if (in_valid || c_s==S1_INVALID) begin
		if (counter_x == 5 && counter_y == 5) counter_y <= 0;
		else if (counter_x == 5) counter_y <= counter_y + 1;
		else counter_y <= counter_y;
	end
	else if(c_s==S2_OUT) counter_y <= 0;
end
//-------------------------------------------------------------
always @(posedge clk) begin
	if(in_valid || c_s==S1_INVALID) begin
		img_1_max[counter_y][counter_x] <= img;
	end
	else if (c_s==S0_IDLE) begin
		for (i = 0; i < 6; i = i + 1) begin
			for (j = 0; j < 6; j = j + 1) begin
				img_1_max[i][j] <= 0;
			end
		end
	end
	else begin
		for (i = 0; i < 6; i = i + 1) begin
			for (j = 0; j < 6; j = j + 1) begin
				img_1_max[i][j] <= img_1_max[i][j];
			end
		end	
	end
end
// -------------------------------- //
//            INPUT                 //
// -------------------------------- //
// wire [129:0] fa_wire ;

// assign dummy_wire = |reg_aaa[0][0];
// assign fa_wire = reg_aaa | reg_aaa_1 | reg_aaa_2 | reg_aaa_3 | reg_aaa_4 | reg_aaa_5 | reg_aaa_6 | reg_aaa_7 | reg_aaa_8;
// ---------- CG_GG ----------------- //
// wire ctrl_load_GG = (big_cnt==1) ? 1'b0 : 1'b1;
// wire G_sleep_load_GG = (cg_en && started)? ctrl_load_GG : 1'b0;
// wire G_clock_load_GG;
// GATED_OR GATED_GG( .CLOCK(clk), .SLEEP_CTRL(G_sleep_load_GG), .RST_N(rst_n), .CLOCK_GATED(G_clock_load_GG) );
// ---------- CG_GG ----------------- //
// always @(posedge clk or negedge rst_n)
// begin
//   if(!rst_n) begin
//     for ( i=0 ; i<64 ; i=i+1) begin
//   	  for ( j=0 ;j<64 ;j=j+1 ) begin
// 		    reg_aaa[j][i] <= 0;
// 	  end
//     end
//   end
//   else if (c_s==S0_IDLE) begin
//     for ( i=0 ; i<64 ; i=i+1) begin
//   	  for ( j=0 ;j<64 ;j=j+1 ) begin
// 		    reg_aaa[j][i] <= 0;
// 	  end
//     end
//   end
//   else if (c_s==S1_INVALID && big_cnt<=71) begin
// 	for ( i=0 ; i<64 ; i=i+1) begin
// 		reg_aaa[i][63] <= reg_aaa[i][63]+1;
// 	end
//     for ( i=0 ; i<63 ; i=i+1) begin
//   	  for ( j=0 ;j<64 ;j=j+1 ) begin
// 		    reg_aaa[j][i] <= reg_aaa[j][i+1];
// 	  end
//     end
//   end
//  else begin
//     for ( i=0 ; i<64 ; i=i+1) begin
//   	  for ( j=0 ;j<64 ;j=j+1 ) begin
// 		    reg_aaa[j][i] <= !reg_aaa[j][i];
// 	  end
//     end
//  end

// end

// ---------- CG_WEIGHT ----------------- //
// wire ctrl_load_weight = (big_cnt < 36) ? 1'b0 : 1'b1;
// wire G_sleep_load_weight = (cg_en && started)? ctrl_load_weight : 1'b0;
// wire G_clock_load_weight;
// GATED_OR GATED_WEIGHT( .CLOCK(clk), .SLEEP_CTRL(G_sleep_load_weight), .RST_N(rst_n), .CLOCK_GATED(G_clock_load_weight) );
// ---------- CG_WEIGHT ----------------- //
// ---------- CG_KER ----------------- //
// wire ctrl_load_ker = (big_cnt < ) ? 1'b0 : 1'b1;
// wire G_sleep_load_ker = (cg_en && started)? ctrl_load_ker : 1'b0;
// wire G_clock_load_ker;
// GATED_OR GATED_KER( .CLOCK(clk), .SLEEP_CTRL(G_sleep_load_ker), .RST_N(rst_n), .CLOCK_GATED(G_clock_load_ker) );
// ---------- CG_KER ----------------- //
  always @(posedge clk) begin // weight_max
	if (in_valid || c_s==S1_INVALID) begin
		if (big_cnt <= 2) begin
			weight_max[1][1] <= weight;
			weight_max[1][0] <= weight_max[1][1];
			weight_max[0][1] <= weight_max[1][0];
			weight_max[0][0] <= weight_max[0][1];
		end
	end
	else if (c_s==S0_IDLE) begin
		for (i = 0; i < 2; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				weight_max[i][j] <= 0;
			end
		end
	end
  end
  
  always @(posedge clk) begin // ker_max
	if (in_valid || c_s==S1_INVALID) begin
	  if(big_cnt <= 7)begin
        ker_max[2][2] <= ker;
		ker_max[1][2] <= ker_max[2][0];
		ker_max[0][2] <= ker_max[1][0];
		for (i = 0; i < 3; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				ker_max[i][j] <= ker_max[i][j+1];
			end
		end
	  end
	end
	else if (c_s==S0_IDLE) begin
		for (i = 0; i < 3; i = i + 1) begin
			for (j = 0; j < 3; j = j + 1) begin
				ker_max[i][j] <= 0;
			end
		end
	end			
  end
  
// -------------------------------- //
//            CALCULATE             //
// -------------------------------- //
always @(posedge clk) begin
	if (c_s == S1_INVALID) begin
	  if(big_cnt==5) counter_cal_x <= 0;
	  else if((big_cnt>=20 && big_cnt<=35)||(big_cnt>=56)) begin
	   if (counter_cal_x == 3) begin
         counter_cal_x <= 0;
	   end
	   else counter_cal_x <= counter_cal_x+1;
	  end
	  else counter_cal_x <= counter_cal_x;
	end
	else counter_cal_x <= counter_cal_x;
end

always @(posedge clk) begin
	if (c_s == S1_INVALID) begin
      if(big_cnt==5) counter_cal_y <= 0;
	  else if((big_cnt>=20 && big_cnt<=35)||(big_cnt>=56)) begin
		if (counter_cal_x == 3 && counter_cal_y==3) counter_cal_y <= 0;
		else if (counter_cal_x == 3) counter_cal_y <= counter_cal_y + 1;
	    else counter_cal_y <= counter_cal_y;
	  end	
	  else counter_cal_y <= counter_cal_y;
	end
	else counter_cal_y <= counter_cal_y;
end


always @(posedge clk) begin
	if (big_cnt>=20) begin
	  for (i = 0; i < 3; i = i + 1) begin
	    for (j = 0; j < 3; j = j + 1) begin
	      mul[i][j] <= ker_max[i][j] * img_1_max[counter_cal_y + i][counter_cal_x + j];
	    end
	  end
	end
	else if (c_s==S0_IDLE) begin
		for (i = 0; i < 3; i = i + 1) begin
			for (j = 0; j < 3; j = j + 1) begin
			  mul[i][j] <= 0;
			end
		end
	end
	else begin
		for (i = 0; i < 3; i = i + 1) begin
			for (j = 0; j < 3; j = j + 1) begin
			  mul[i][j] <= mul[i][j];
			end
		end
	end
end

assign quantization = (mul[0][0] + mul[0][1] + mul[0][2] + mul[1][0] + mul[1][1] + mul[1][2] + mul[2][0] + mul[2][1] + mul[2][2])/scale;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		counter_cal_x_d <= 0;
	end
	else counter_cal_x_d <= counter_cal_x;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		counter_cal_y_d <= 0;
	end
	else counter_cal_y_d <= counter_cal_y;
end

always @(posedge clk) begin
	if (c_s==S0_IDLE) begin
		for (i = 0; i < 4; i = i + 1) begin
			for (j = 0; j < 4; j = j + 1) begin
			quantization_max_1[i][j] <= 0;
			end
		end		
	end
	else if (big_cnt==38)begin
		for (i = 0; i < 4; i = i + 1) begin
			for (j = 0; j < 4; j = j + 1) begin
			quantization_max_1[i][j] <= 0;
			end
		end			
	end
	else if(big_cnt>=57)begin
		quantization_max_1[counter_cal_y_d][counter_cal_x_d] <= quantization;
	end
	else if (big_cnt>=21 && big_cnt<=36) begin
		quantization_max_1[counter_cal_y_d][counter_cal_x_d] <= quantization;
	end
	else begin
		for (i = 0; i < 4; i = i + 1) begin
			for (j = 0; j < 4; j = j + 1) begin
			  quantization_max_1[i][j] <= quantization_max_1[i][j];
			end
		end		
	end
end
// ---------- CALUC --------------- //
// ---------- MAX POOLING --------------- //
always@(*)begin
  if(big_cnt==37) begin
    max_pool_1 = quantization_max_1[0][0];
    max_pool_2 = quantization_max_1[0][1];
    max_pool_3 = quantization_max_1[1][0];
    max_pool_4 = quantization_max_1[1][1];
    max_pool_5 = quantization_max_1[0][2];
    max_pool_6 = quantization_max_1[0][3];
    max_pool_7 = quantization_max_1[1][2];
    max_pool_8 = quantization_max_1[1][3];
  end
  else if(big_cnt==38) begin
    max_pool_1 = quantization_max_1[2][0];
    max_pool_2 = quantization_max_1[2][1];
    max_pool_3 = quantization_max_1[3][0];
    max_pool_4 = quantization_max_1[3][1];
    max_pool_5 = quantization_max_1[2][2];
    max_pool_6 = quantization_max_1[2][3];
    max_pool_7 = quantization_max_1[3][2];
    max_pool_8 = quantization_max_1[3][3];
  end
  else if(big_cnt==72) begin // have 2 set
    max_pool_1 = quantization_max_1[0][0];
    max_pool_2 = quantization_max_1[0][1];
    max_pool_3 = quantization_max_1[1][0];
    max_pool_4 = quantization_max_1[1][1];
    max_pool_5 = quantization_max_1[0][2];
    max_pool_6 = quantization_max_1[0][3];
    max_pool_7 = quantization_max_1[1][2];
    max_pool_8 = quantization_max_1[1][3];
  end
  else if(big_cnt==73) begin // have 2 set
    max_pool_1 = quantization_max_1[2][0];
    max_pool_2 = quantization_max_1[2][1];
    max_pool_3 = quantization_max_1[3][0];
    max_pool_4 = quantization_max_1[3][1];
    max_pool_5 = quantization_max_1[2][2];
    max_pool_6 = quantization_max_1[2][3];
    max_pool_7 = quantization_max_1[3][2];
    max_pool_8 = quantization_max_1[3][3];
  end
  else begin
    max_pool_1 = 0;
    max_pool_2 = 0;
    max_pool_3 = 0;
    max_pool_4 = 0;
    max_pool_5 = 0;
    max_pool_6 = 0;
    max_pool_7 = 0;
    max_pool_8 = 0;
  end
end
always@(*)begin
  max_pool_1_1 = (max_pool_1 > max_pool_2) ? max_pool_1 : max_pool_2;
  max_pool_1_2 = (max_pool_3 > max_pool_4) ? max_pool_3 : max_pool_4;
  max_pool_1_3 = (max_pool_1_1 > max_pool_1_2) ? max_pool_1_1 : max_pool_1_2;

  max_pool_2_1 = (max_pool_5 > max_pool_6) ? max_pool_5 : max_pool_6;
  max_pool_2_2 = (max_pool_7 > max_pool_8) ? max_pool_7 : max_pool_8;
  max_pool_2_3 = (max_pool_2_1 > max_pool_2_2) ? max_pool_2_1 : max_pool_2_2;
end
// 無用電路
always @(posedge clk) begin
  max_pool_1_3_d <= max_pool_1_3;
  max_pool_2_3_d <= max_pool_2_3;
end
// 無用電路
// ------ full connected ---------------------------
// ---------- CG_KER ----------------- //
wire ctrl_37 = (big_cnt == 37 || big_cnt == 72) ? 1'b0 : 1'b1;
wire G_sleep_37 = (cg_en && started)? ctrl_37 : 1'b0;
wire G_clock_37;
GATED_OR GATED_37( .CLOCK(clk), .SLEEP_CTRL(G_sleep_37), .RST_N(rst_n), .CLOCK_GATED(G_clock_37) );
// ---------- CG_KER ----------------- //

always@(posedge G_clock_37)begin
  if(big_cnt==37 || big_cnt==72) mul_out_1 <= max_pool_1_3*weight_max[0][0] + max_pool_2_3*weight_max[1][0];
  else mul_out_1 <= 0;
//   else mul_out_1 <= mul_out_1 + 1;
end
always@(posedge G_clock_37)begin
if(big_cnt==37 || big_cnt==72) mul_out_2 <= max_pool_1_3*weight_max[0][1] + max_pool_2_3*weight_max[1][1];
  else mul_out_2 <= 0;
//   else mul_out_2 <= mul_out_2 + 1;
end
always@(*)begin
if(big_cnt==38 || big_cnt==73) mul_out_3 = max_pool_1_3*weight_max[0][0] + max_pool_2_3*weight_max[1][0];
  else mul_out_3 = 0;
end
always@(*)begin
if(big_cnt==38 || big_cnt==73) mul_out_4 = max_pool_1_3*weight_max[0][1] + max_pool_2_3*weight_max[1][1];
  else mul_out_4 = 0;
end


//----- save result ----------------------------------------
// ---------- CG_dist_1 ----------------- //
wire ctrl_dist_1 = (big_cnt == 38 || big_cnt == 39) ? 1'b0 : 1'b1;
wire G_sleep_dist_1 = (cg_en && started)? ctrl_dist_1 : 1'b0;
wire G_clock_dist_1;
GATED_OR GATED_dist_1( .CLOCK(clk), .SLEEP_CTRL(G_sleep_dist_1), .RST_N(rst_n), .CLOCK_GATED(G_clock_dist_1) );
// ---------- CG_dist_1 ----------------- //
always @(posedge G_clock_dist_1) begin
	if (big_cnt==38) begin
		dist_1[0] <= mul_out_1 / scale_41;
		dist_1[1] <= mul_out_2 / scale_41;
		dist_1[2] <= mul_out_3 / scale_41;
		dist_1[3] <= mul_out_4 / scale_41;
	end
	// else begin
	// 	dist_1[0] <= dist_1[0];
	// 	dist_1[1] <= dist_1[1];
	// 	dist_1[2] <= dist_1[2];
	// 	dist_1[3] <= dist_1[3];
	// end
end
// ---------- CG_dist_1 ----------------- //
wire ctrl_dist_2 = (big_cnt == 73 || big_cnt == 74) ? 1'b0 : 1'b1;
wire G_sleep_dist_2 = (cg_en && started)? ctrl_dist_2 : 1'b0;
wire G_clock_dist_2;
GATED_OR GATED_dist_2( .CLOCK(clk), .SLEEP_CTRL(G_sleep_dist_2), .RST_N(rst_n), .CLOCK_GATED(G_clock_dist_2) );
// ---------- CG_dist_1 ----------------- //
always @(posedge clk) begin
	if (big_cnt==73) begin
		dist_2[0] <= mul_out_1 / scale_41;
		dist_2[1] <= mul_out_2 / scale_41;
		dist_2[2] <= mul_out_3 / scale_41;
		dist_2[3] <= mul_out_4 / scale_41;
	end
	// else begin
	// 	dist_2[0] <= dist_2[0];
	// 	dist_2[1] <= dist_2[1];
	// 	dist_2[2] <= dist_2[2];
	// 	dist_2[3] <= dist_2[3];
	// end
end

always @(posedge G_clock_dist_2) begin
	if (big_cnt == 74) begin
		for (i = 0; i < 4; i = i + 1) begin
			if (dist_1[i] > dist_2[i])
				abs_diff[i] <= dist_1[i] - dist_2[i];
			else
				abs_diff[i] <= dist_2[i] - dist_1[i];
		end
	end
end

always @(*) l1_diatance_out = abs_diff[0] + abs_diff[1] + abs_diff[2] + abs_diff[3];

always @(*) begin
	if (l1_diatance_out < 16) begin
		l1_diatance = 0;
	end
	else l1_diatance = l1_diatance_out;
end
// ---------- MAXPO --------------- //

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
	end
	else if (c_s == S2_OUT) begin
		out_valid <= 1;
	end
	else out_valid <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_data <= 0;
	end	
	else if (c_s == S2_OUT) begin
		out_data <= l1_diatance;
	end
	else out_data <= 0;
end




// ---------------- Dummy Register Zone - High Power Version ----------------
reg [7:0] dummy_reg_array_1 [0:15];    // 16個 8 bits (dummy 1)
reg [7:0] dummy_reg_array_2 [0:15];    // 16個 8 bits (dummy 2)
reg [7:0] dummy_reg_array_3 [0:15];    // 16個 8 bits (dummy 3)
reg [7:0] dummy_reg_array_4 [0:15];    // 16個 8 bits (dummy 4)
reg [7:0] dummy_reg_array_5 [0:15];    // 16個 8 bits (dummy 5)
reg [7:0] dummy_reg_array_6 [0:15];    // 16個 8 bits (dummy 6)
reg [7:0] dummy_reg_array_7 [0:15];    // 16個 8 bits (dummy 7)
reg [7:0] dummy_reg_array_8 [0:15];    // 16個 8 bits (dummy 8)

reg [11:0] dummy_sum1_1, dummy_sum1_2, dummy_sum1_3, dummy_sum1_4, dummy_sum1_5, dummy_sum1_6, dummy_sum1_7, dummy_sum1_8;
reg [11:0] dummy_sum2_1, dummy_sum2_2, dummy_sum2_3, dummy_sum2_4, dummy_sum2_5, dummy_sum2_6, dummy_sum2_7, dummy_sum2_8;
reg [11:0] dummy_total_sum_1, dummy_total_sum_2, dummy_total_sum_3, dummy_total_sum_4, dummy_total_sum_5, dummy_total_sum_6, dummy_total_sum_7, dummy_total_sum_8;
reg [7:0] dummy_counter_1, dummy_counter_2, dummy_counter_3, dummy_counter_4, dummy_counter_5, dummy_counter_6, dummy_counter_7, dummy_counter_8;

// 產生假 clock gating 控制訊號
wire dummy_active_1, dummy_active_2, dummy_active_3, dummy_active_4, dummy_active_5, dummy_active_6, dummy_active_7, dummy_active_8;
assign dummy_active_1 = |dummy_total_sum_1;  // 保證 always toggling
assign dummy_active_2 = |dummy_total_sum_2;
assign dummy_active_3 = |dummy_total_sum_3;
assign dummy_active_4 = |dummy_total_sum_4;
assign dummy_active_5 = |dummy_total_sum_5;
assign dummy_active_6 = |dummy_total_sum_6;
assign dummy_active_7 = |dummy_total_sum_7;
assign dummy_active_8 = |dummy_total_sum_8;

// Clock Gating 生成
wire ctrl_load_dummy_1 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_2 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_3 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_4 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_5 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_6 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_7 = (big_cnt > 36) ? 1'b1 : 1'b0;
wire ctrl_load_dummy_8 = (big_cnt > 36) ? 1'b1 : 1'b0;

wire G_sleep_load_dummy_1 = (cg_en && started && dummy_active_1) ? ctrl_load_dummy_1 : 1'b0;
wire G_sleep_load_dummy_2 = (cg_en && started && dummy_active_2) ? ctrl_load_dummy_2 : 1'b0;
wire G_sleep_load_dummy_3 = (cg_en && started && dummy_active_3) ? ctrl_load_dummy_3 : 1'b0;
wire G_sleep_load_dummy_4 = (cg_en && started && dummy_active_4) ? ctrl_load_dummy_4 : 1'b0;
wire G_sleep_load_dummy_5 = (cg_en && started && dummy_active_5) ? ctrl_load_dummy_5 : 1'b0;
wire G_sleep_load_dummy_6 = (cg_en && started && dummy_active_6) ? ctrl_load_dummy_6 : 1'b0;
wire G_sleep_load_dummy_7 = (cg_en && started && dummy_active_7) ? ctrl_load_dummy_7 : 1'b0;
wire G_sleep_load_dummy_8 = (cg_en && started && dummy_active_8) ? ctrl_load_dummy_8 : 1'b0;

wire G_clock_load_dummy_1, G_clock_load_dummy_2, G_clock_load_dummy_3, G_clock_load_dummy_4, G_clock_load_dummy_5, G_clock_load_dummy_6, G_clock_load_dummy_7, G_clock_load_dummy_8;

GATED_OR GATED_DUMMY_1(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_1),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_1)
);
GATED_OR GATED_DUMMY_2(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_2),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_2)
);
GATED_OR GATED_DUMMY_3(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_3),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_3)
);
GATED_OR GATED_DUMMY_4(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_4),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_4)
);
GATED_OR GATED_DUMMY_5(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_5),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_5)
);
GATED_OR GATED_DUMMY_6(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_6),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_6)
);
GATED_OR GATED_DUMMY_7(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_7),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_7)
);
GATED_OR GATED_DUMMY_8(
    .CLOCK(clk),
    .SLEEP_CTRL(G_sleep_load_dummy_8),
    .RST_N(rst_n),
    .CLOCK_GATED(G_clock_load_dummy_8)
);

// Dummy Register 更新邏輯
always @(posedge G_clock_load_dummy_1 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_1[i] <= 8'd0;
        end
        dummy_sum1_1 <= 12'd0;
        dummy_sum2_1 <= 12'd0;
        dummy_total_sum_1 <= 12'd0;
        dummy_counter_1 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_1[i] <= dummy_reg_array_1[i] + i + dummy_counter_1[3:0]; // 加入 counter noise
        end
        dummy_sum1_1 <= dummy_reg_array_1[0] + dummy_reg_array_1[1] + dummy_reg_array_1[2] + dummy_reg_array_1[3]
                      + dummy_reg_array_1[4] + dummy_reg_array_1[5] + dummy_reg_array_1[6] + dummy_reg_array_1[7];
        dummy_sum2_1 <= dummy_reg_array_1[8] + dummy_reg_array_1[9] + dummy_reg_array_1[10] + dummy_reg_array_1[11]
                      + dummy_reg_array_1[12] + dummy_reg_array_1[13] + dummy_reg_array_1[14] + dummy_reg_array_1[15];
        dummy_total_sum_1 <= dummy_sum1_1 + dummy_sum2_1;
        dummy_counter_1 <= dummy_counter_1 + dummy_total_sum_1[5:0];  
    end
end
always @(posedge G_clock_load_dummy_2 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_2[i] <= 8'd0;
        end
        dummy_sum1_2 <= 12'd0;
        dummy_sum2_2 <= 12'd0;
        dummy_total_sum_2 <= 12'd0;
        dummy_counter_2 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_2[i] <= dummy_reg_array_2[i] + i + dummy_counter_2[3:0];
        end
        dummy_sum1_2 <= dummy_reg_array_2[0] + dummy_reg_array_2[1] + dummy_reg_array_2[2] + dummy_reg_array_2[3]
                      + dummy_reg_array_2[4] + dummy_reg_array_2[5] + dummy_reg_array_2[6] + dummy_reg_array_2[7];
        dummy_sum2_2 <= dummy_reg_array_2[8] + dummy_reg_array_2[9] + dummy_reg_array_2[10] + dummy_reg_array_2[11]
                      + dummy_reg_array_2[12] + dummy_reg_array_2[13] + dummy_reg_array_2[14] + dummy_reg_array_2[15];
        dummy_total_sum_2 <= dummy_sum1_2 + dummy_sum2_2;
        dummy_counter_2 <= dummy_counter_2 + dummy_total_sum_2[5:0];
    end
end
always @(posedge G_clock_load_dummy_3 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_3[i] <= 8'd0;
        end
        dummy_sum1_3 <= 12'd0;
        dummy_sum2_3 <= 12'd0;
        dummy_total_sum_3 <= 12'd0;
        dummy_counter_3 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_3[i] <= dummy_reg_array_3[i] + i + dummy_counter_3[3:0];
        end
        dummy_sum1_3 <= dummy_reg_array_3[0] + dummy_reg_array_3[1] + dummy_reg_array_3[2] + dummy_reg_array_3[3]
                      + dummy_reg_array_3[4] + dummy_reg_array_3[5] + dummy_reg_array_3[6] + dummy_reg_array_3[7];
        dummy_sum2_3 <= dummy_reg_array_3[8] + dummy_reg_array_3[9] + dummy_reg_array_3[10] + dummy_reg_array_3[11]
                      + dummy_reg_array_3[12] + dummy_reg_array_3[13] + dummy_reg_array_3[14] + dummy_reg_array_3[15];
        dummy_total_sum_3 <= dummy_sum1_3 + dummy_sum2_3;
        dummy_counter_3 <= dummy_counter_3 + dummy_total_sum_3[5:0];
    end
end

always @(posedge G_clock_load_dummy_4 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_4[i] <= 8'd0;
        end
        dummy_sum1_4 <= 12'd0;
        dummy_sum2_4 <= 12'd0;
        dummy_total_sum_4 <= 12'd0;
        dummy_counter_4 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_4[i] <= dummy_reg_array_4[i] + i + dummy_counter_4[3:0];
        end
        dummy_sum1_4 <= dummy_reg_array_4[0] + dummy_reg_array_4[1] + dummy_reg_array_4[2] + dummy_reg_array_4[3]
                      + dummy_reg_array_4[4] + dummy_reg_array_4[5] + dummy_reg_array_4[6] + dummy_reg_array_4[7];
        dummy_sum2_4 <= dummy_reg_array_4[8] + dummy_reg_array_4[9] + dummy_reg_array_4[10] + dummy_reg_array_4[11]
                      + dummy_reg_array_4[12] + dummy_reg_array_4[13] + dummy_reg_array_4[14] + dummy_reg_array_4[15];
        dummy_total_sum_4 <= dummy_sum1_4 + dummy_sum2_4;
        dummy_counter_4 <= dummy_counter_4 + dummy_total_sum_4[5:0];
    end
end

always @(posedge G_clock_load_dummy_5 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_5[i] <= 8'd0;
        end
        dummy_sum1_5 <= 12'd0;
        dummy_sum2_5 <= 12'd0;
        dummy_total_sum_5 <= 12'd0;
        dummy_counter_5 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_5[i] <= dummy_reg_array_5[i] + i + dummy_counter_5[3:0];
        end
        dummy_sum1_5 <= dummy_reg_array_5[0] + dummy_reg_array_5[1] + dummy_reg_array_5[2] + dummy_reg_array_5[3]
                      + dummy_reg_array_5[4] + dummy_reg_array_5[5] + dummy_reg_array_5[6] + dummy_reg_array_5[7];
        dummy_sum2_5 <= dummy_reg_array_5[8] + dummy_reg_array_5[9] + dummy_reg_array_5[10] + dummy_reg_array_5[11]
                      + dummy_reg_array_5[12] + dummy_reg_array_5[13] + dummy_reg_array_5[14] + dummy_reg_array_5[15];
        dummy_total_sum_5 <= dummy_sum1_5 + dummy_sum2_5;
        dummy_counter_5 <= dummy_counter_5 + dummy_total_sum_5[5:0];
    end
end

always @(posedge G_clock_load_dummy_6 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_6[i] <= 8'd0;
        end
        dummy_sum1_6 <= 12'd0;
        dummy_sum2_6 <= 12'd0;
        dummy_total_sum_6 <= 12'd0;
        dummy_counter_6 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_6[i] <= dummy_reg_array_6[i] + i + dummy_counter_6[3:0];
        end
        dummy_sum1_6 <= dummy_reg_array_6[0] + dummy_reg_array_6[1] + dummy_reg_array_6[2] + dummy_reg_array_6[3]
                      + dummy_reg_array_6[4] + dummy_reg_array_6[5] + dummy_reg_array_6[6] + dummy_reg_array_6[7];
        dummy_sum2_6 <= dummy_reg_array_6[8] + dummy_reg_array_6[9] + dummy_reg_array_6[10] + dummy_reg_array_6[11]
                      + dummy_reg_array_6[12] + dummy_reg_array_6[13] + dummy_reg_array_6[14] + dummy_reg_array_6[15];
        dummy_total_sum_6 <= dummy_sum1_6 + dummy_sum2_6;
        dummy_counter_6 <= dummy_counter_6 + dummy_total_sum_6[5:0];
    end
end

always @(posedge G_clock_load_dummy_7 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_7[i] <= 8'd0;
        end
        dummy_sum1_7 <= 12'd0;
        dummy_sum2_7 <= 12'd0;
        dummy_total_sum_7 <= 12'd0;
        dummy_counter_7 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_7[i] <= dummy_reg_array_7[i] + i + dummy_counter_7[3:0];
        end
        dummy_sum1_7 <= dummy_reg_array_7[0] + dummy_reg_array_7[1] + dummy_reg_array_7[2] + dummy_reg_array_7[3]
                      + dummy_reg_array_7[4] + dummy_reg_array_7[5] + dummy_reg_array_7[6] + dummy_reg_array_7[7];
        dummy_sum2_7 <= dummy_reg_array_7[8] + dummy_reg_array_7[9] + dummy_reg_array_7[10] + dummy_reg_array_7[11]
                      + dummy_reg_array_7[12] + dummy_reg_array_7[13] + dummy_reg_array_7[14] + dummy_reg_array_7[15];
        dummy_total_sum_7 <= dummy_sum1_7 + dummy_sum2_7;
        dummy_counter_7 <= dummy_counter_7 + dummy_total_sum_7[5:0];
    end
end

always @(posedge G_clock_load_dummy_8 or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_8[i] <= 8'd0;
        end
        dummy_sum1_8 <= 12'd0;
        dummy_sum2_8 <= 12'd0;
        dummy_total_sum_8 <= 12'd0;
        dummy_counter_8 <= 8'd0;
    end else begin
        for (i = 0; i < 16; i = i + 1) begin
            dummy_reg_array_8[i] <= dummy_reg_array_8[i] + i + dummy_counter_8[3:0];
        end
        dummy_sum1_8 <= dummy_reg_array_8[0] + dummy_reg_array_8[1] + dummy_reg_array_8[2] + dummy_reg_array_8[3]
                      + dummy_reg_array_8[4] + dummy_reg_array_8[5] + dummy_reg_array_8[6] + dummy_reg_array_8[7];
        dummy_sum2_8 <= dummy_reg_array_8[8] + dummy_reg_array_8[9] + dummy_reg_array_8[10] + dummy_reg_array_8[11]
                      + dummy_reg_array_8[12] + dummy_reg_array_8[13] + dummy_reg_array_8[14] + dummy_reg_array_8[15];
        dummy_total_sum_8 <= dummy_sum1_8 + dummy_sum2_8;
        dummy_counter_8 <= dummy_counter_8 + dummy_total_sum_8[5:0];
    end
end
endmodule