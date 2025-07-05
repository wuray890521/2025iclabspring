//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Midterm Proejct            : MRA  
//   Author                     : Lin-Hung, Lai
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//   Release version : V2.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
  loc_y         	,
	cost	 		      ,		
	busy         	  ,

    // AXI4 IO
	     arid_m_inf,
	   araddr_m_inf,
	    arlen_m_inf,
	   arsize_m_inf,
	  arburst_m_inf,
	  arvalid_m_inf,
	  arready_m_inf,
	
	      rid_m_inf,
	    rdata_m_inf,
	    rresp_m_inf,
	    rlast_m_inf,
	   rvalid_m_inf,
	   rready_m_inf,
	
	     awid_m_inf,
	   awaddr_m_inf,
	   awsize_m_inf,
	  awburst_m_inf,
	    awlen_m_inf,
	  awvalid_m_inf,
	  awready_m_inf,
	
	    wdata_m_inf,
	    wlast_m_inf,
	   wvalid_m_inf,
	   wready_m_inf,
	
	      bid_m_inf,
	    bresp_m_inf,
	   bvalid_m_inf,
	   bready_m_inf 
);

// ===============================================================
//  					Input / Output 
// ===============================================================

// << CHIP io port with system >>
input 			  	    clk,rst_n;
input 			   	    in_valid;
input  [4:0] 		    frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;       
  
// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       Your AXI-4 interface could be designed as a bridge in submodule,
	   therefore I declared output of AXI as wire.  
	   Ex: AXI4_interface AXI4_INF(...);
*/
parameter ID_WIDTH   =   4;
parameter ADDR_WIDTH =  32;
parameter DATA_WIDTH = 128;
// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output reg                   arvalid_m_inf;
input  wire                  arready_m_inf;
output reg [ADDR_WIDTH-1:0]   araddr_m_inf;
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output reg                    rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output reg                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)	axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------
reg [DATA_WIDTH-1:0] r_rdata;
reg [DATA_WIDTH-1:0] r_wdata;
reg rvalid_m_inf_d1;


// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

reg flag_map,flag_map_d;
// reg rlast_m_inf_d,rlast_m_inf_d2;
// reg flag_1;

reg flag_2;
reg flag_3; // use to save input x,y

reg f_switch;
reg f_switch_d;

wire [3:0] assign_out;

reg flag_filldone;

reg [4:0]  r_frameID;

reg [3:0]  net_ID [0:15];

reg [5:0]  cur_X_d1,cur_Y_d1;  
reg [5:0]  cur_X,cur_Y;
wire [6:0] cur_X_add1, cur_X_minus1;
wire [6:0] cur_Y_add1, cur_Y_minus1;

wire [5:0] add_6bits;
wire add_1bit;
wire [4:0] axis_to_address;



reg [5:0]  sour_X [0:14];
reg [5:0]  sour_Y [0:14];
reg [5:0]  sink_X [0:14];
reg [5:0]  sink_Y [0:14];

reg in_valid_d1;
reg wready_m_inf_d1;

reg [3:0] cnt_net_num;
reg [2:0] cnt;


reg [4:0] cnt_3;
reg [1:0] cnt_3_d;

always@(posedge clk)begin
 cnt_3_d<=cnt_3;
end

reg [6:0] cnt_dram;
reg [1:0] cnt_2; //cnt 0~3
wire [63:0] net_line;


reg [3:0] NETnum;
reg [1:0] Map [0:63][0:63];

reg [127:0] temp_reg;
reg [127:0] temp_reg_2;


integer i,j,k,l;
integer X,Y;

// state
parameter S0_IDLE          = 4'd0;
parameter S1_RAVALID       = 4'd1;
parameter S2_read_locMAP_D = 4'd2;
parameter S3_read_weiMAP_D = 4'd3;
parameter S4_setGoal       = 4'd4;
parameter S5_fillMAP       = 4'd5;
parameter S6_RETRACE       = 4'd6;
parameter S7_JUDGE         = 4'd7;
parameter S8_WAVALID       = 4'd8;
parameter S9_write_loc_D   = 4'd9;
parameter S10_BUFF         = 4'd10;

reg [3:0] c_s, n_s;


wire [7:0] index_addr;


//=====================================================================================================================================================================
reg [7:0]  SRAM_1_add;
reg [7:0]  SRAM_1_add_d1;
reg [63:0] SRAM_1_in;
reg [63:0] SRAM_1_out;
reg SRAM_1_WEB; 

SUMA180_256X64X1BM1 SRAM_1(.A0(SRAM_1_add[0]),.A1(SRAM_1_add[1]),.A2(SRAM_1_add[2]),.A3(SRAM_1_add[3]),.A4(SRAM_1_add[4]),.A5(SRAM_1_add[5]),.A6(SRAM_1_add[6]),.A7(SRAM_1_add[7]),
                             .DO0(SRAM_1_out[0]),.DO1(SRAM_1_out[1]),.DO2(SRAM_1_out[2]),.DO3(SRAM_1_out[3]),.DO4(SRAM_1_out[4]),.DO5(SRAM_1_out[5]),.DO6(SRAM_1_out[6]),.DO7(SRAM_1_out[7]),
                             .DO8(SRAM_1_out[8]),.DO9(SRAM_1_out[9]),.DO10(SRAM_1_out[10]),.DO11(SRAM_1_out[11]),.DO12(SRAM_1_out[12]),.DO13(SRAM_1_out[13]),.DO14(SRAM_1_out[14]),.DO15(SRAM_1_out[15]),
                             .DO16(SRAM_1_out[16]),.DO17(SRAM_1_out[17]),.DO18(SRAM_1_out[18]),.DO19(SRAM_1_out[19]),.DO20(SRAM_1_out[20]),.DO21(SRAM_1_out[21]),.DO22(SRAM_1_out[22]),.DO23(SRAM_1_out[23]),
                             .DO24(SRAM_1_out[24]),.DO25(SRAM_1_out[25]),.DO26(SRAM_1_out[26]),.DO27(SRAM_1_out[27]),.DO28(SRAM_1_out[28]),.DO29(SRAM_1_out[29]),.DO30(SRAM_1_out[30]),.DO31(SRAM_1_out[31]),
                             .DO32(SRAM_1_out[32]),.DO33(SRAM_1_out[33]),.DO34(SRAM_1_out[34]),.DO35(SRAM_1_out[35]),.DO36(SRAM_1_out[36]),.DO37(SRAM_1_out[37]),.DO38(SRAM_1_out[38]),.DO39(SRAM_1_out[39]),
                             .DO40(SRAM_1_out[40]),.DO41(SRAM_1_out[41]),.DO42(SRAM_1_out[42]),.DO43(SRAM_1_out[43]),.DO44(SRAM_1_out[44]),.DO45(SRAM_1_out[45]),.DO46(SRAM_1_out[46]),.DO47(SRAM_1_out[47]),
                             .DO48(SRAM_1_out[48]),.DO49(SRAM_1_out[49]),.DO50(SRAM_1_out[50]),.DO51(SRAM_1_out[51]),.DO52(SRAM_1_out[52]),.DO53(SRAM_1_out[53]),.DO54(SRAM_1_out[54]),.DO55(SRAM_1_out[55]),
                             .DO56(SRAM_1_out[56]),.DO57(SRAM_1_out[57]),.DO58(SRAM_1_out[58]),.DO59(SRAM_1_out[59]),.DO60(SRAM_1_out[60]),.DO61(SRAM_1_out[61]),.DO62(SRAM_1_out[62]),.DO63(SRAM_1_out[63]),
                             .DI0(SRAM_1_in[0]),.DI1(SRAM_1_in[1]),.DI2(SRAM_1_in[2]),.DI3(SRAM_1_in[3]),.DI4(SRAM_1_in[4]),.DI5(SRAM_1_in[5]),.DI6(SRAM_1_in[6]),.DI7(SRAM_1_in[7]),
                             .DI8(SRAM_1_in[8]),.DI9(SRAM_1_in[9]),.DI10(SRAM_1_in[10]),.DI11(SRAM_1_in[11]),.DI12(SRAM_1_in[12]),.DI13(SRAM_1_in[13]),.DI14(SRAM_1_in[14]),.DI15(SRAM_1_in[15]),
                             .DI16(SRAM_1_in[16]),.DI17(SRAM_1_in[17]),.DI18(SRAM_1_in[18]),.DI19(SRAM_1_in[19]),.DI20(SRAM_1_in[20]),.DI21(SRAM_1_in[21]),.DI22(SRAM_1_in[22]),.DI23(SRAM_1_in[23]),
                             .DI24(SRAM_1_in[24]),.DI25(SRAM_1_in[25]),.DI26(SRAM_1_in[26]),.DI27(SRAM_1_in[27]),.DI28(SRAM_1_in[28]),.DI29(SRAM_1_in[29]),.DI30(SRAM_1_in[30]),.DI31(SRAM_1_in[31]),
                             .DI32(SRAM_1_in[32]),.DI33(SRAM_1_in[33]),.DI34(SRAM_1_in[34]),.DI35(SRAM_1_in[35]),.DI36(SRAM_1_in[36]),.DI37(SRAM_1_in[37]),.DI38(SRAM_1_in[38]),.DI39(SRAM_1_in[39]),
                             .DI40(SRAM_1_in[40]),.DI41(SRAM_1_in[41]),.DI42(SRAM_1_in[42]),.DI43(SRAM_1_in[43]),.DI44(SRAM_1_in[44]),.DI45(SRAM_1_in[45]),.DI46(SRAM_1_in[46]),.DI47(SRAM_1_in[47]),
                             .DI48(SRAM_1_in[48]),.DI49(SRAM_1_in[49]),.DI50(SRAM_1_in[50]),.DI51(SRAM_1_in[51]),.DI52(SRAM_1_in[52]),.DI53(SRAM_1_in[53]),.DI54(SRAM_1_in[54]),.DI55(SRAM_1_in[55]),
                             .DI56(SRAM_1_in[56]),.DI57(SRAM_1_in[57]),.DI58(SRAM_1_in[58]),.DI59(SRAM_1_in[59]),.DI60(SRAM_1_in[60]),.DI61(SRAM_1_in[61]),.DI62(SRAM_1_in[62]),.DI63(SRAM_1_in[63]),
                            .CK(clk),.WEB(SRAM_1_WEB),.OE(1'b1),.CS(1'b1));

reg  [7:0]  SRAM_2_add;
reg  [63:0] SRAM_2_in;
reg  [63:0] SRAM_2_out;
reg SRAM_2_WEB; 
  
SUMA180_256X64X1BM1 SRAM_2(.A0(SRAM_2_add[0]),.A1(SRAM_2_add[1]),.A2(SRAM_2_add[2]),.A3(SRAM_2_add[3]),.A4(SRAM_2_add[4]),.A5(SRAM_2_add[5]),.A6(SRAM_2_add[6]),.A7(SRAM_2_add[7]),
                             .DO0(SRAM_2_out[0]),.DO1(SRAM_2_out[1]),.DO2(SRAM_2_out[2]),.DO3(SRAM_2_out[3]),.DO4(SRAM_2_out[4]),.DO5(SRAM_2_out[5]),.DO6(SRAM_2_out[6]),.DO7(SRAM_2_out[7]),
                             .DO8(SRAM_2_out[8]),.DO9(SRAM_2_out[9]),.DO10(SRAM_2_out[10]),.DO11(SRAM_2_out[11]),.DO12(SRAM_2_out[12]),.DO13(SRAM_2_out[13]),.DO14(SRAM_2_out[14]),.DO15(SRAM_2_out[15]),
                             .DO16(SRAM_2_out[16]),.DO17(SRAM_2_out[17]),.DO18(SRAM_2_out[18]),.DO19(SRAM_2_out[19]),.DO20(SRAM_2_out[20]),.DO21(SRAM_2_out[21]),.DO22(SRAM_2_out[22]),.DO23(SRAM_2_out[23]),
                             .DO24(SRAM_2_out[24]),.DO25(SRAM_2_out[25]),.DO26(SRAM_2_out[26]),.DO27(SRAM_2_out[27]),.DO28(SRAM_2_out[28]),.DO29(SRAM_2_out[29]),.DO30(SRAM_2_out[30]),.DO31(SRAM_2_out[31]),
                             .DO32(SRAM_2_out[32]),.DO33(SRAM_2_out[33]),.DO34(SRAM_2_out[34]),.DO35(SRAM_2_out[35]),.DO36(SRAM_2_out[36]),.DO37(SRAM_2_out[37]),.DO38(SRAM_2_out[38]),.DO39(SRAM_2_out[39]),
                             .DO40(SRAM_2_out[40]),.DO41(SRAM_2_out[41]),.DO42(SRAM_2_out[42]),.DO43(SRAM_2_out[43]),.DO44(SRAM_2_out[44]),.DO45(SRAM_2_out[45]),.DO46(SRAM_2_out[46]),.DO47(SRAM_2_out[47]),
                             .DO48(SRAM_2_out[48]),.DO49(SRAM_2_out[49]),.DO50(SRAM_2_out[50]),.DO51(SRAM_2_out[51]),.DO52(SRAM_2_out[52]),.DO53(SRAM_2_out[53]),.DO54(SRAM_2_out[54]),.DO55(SRAM_2_out[55]),
                             .DO56(SRAM_2_out[56]),.DO57(SRAM_2_out[57]),.DO58(SRAM_2_out[58]),.DO59(SRAM_2_out[59]),.DO60(SRAM_2_out[60]),.DO61(SRAM_2_out[61]),.DO62(SRAM_2_out[62]),.DO63(SRAM_2_out[63]),
                             .DI0(SRAM_2_in[0]),.DI1(SRAM_2_in[1]),.DI2(SRAM_2_in[2]),.DI3(SRAM_2_in[3]),.DI4(SRAM_2_in[4]),.DI5(SRAM_2_in[5]),.DI6(SRAM_2_in[6]),.DI7(SRAM_2_in[7]),
                             .DI8(SRAM_2_in[8]),.DI9(SRAM_2_in[9]),.DI10(SRAM_2_in[10]),.DI11(SRAM_2_in[11]),.DI12(SRAM_2_in[12]),.DI13(SRAM_2_in[13]),.DI14(SRAM_2_in[14]),.DI15(SRAM_2_in[15]),
                             .DI16(SRAM_2_in[16]),.DI17(SRAM_2_in[17]),.DI18(SRAM_2_in[18]),.DI19(SRAM_2_in[19]),.DI20(SRAM_2_in[20]),.DI21(SRAM_2_in[21]),.DI22(SRAM_2_in[22]),.DI23(SRAM_2_in[23]),
                             .DI24(SRAM_2_in[24]),.DI25(SRAM_2_in[25]),.DI26(SRAM_2_in[26]),.DI27(SRAM_2_in[27]),.DI28(SRAM_2_in[28]),.DI29(SRAM_2_in[29]),.DI30(SRAM_2_in[30]),.DI31(SRAM_2_in[31]),
                             .DI32(SRAM_2_in[32]),.DI33(SRAM_2_in[33]),.DI34(SRAM_2_in[34]),.DI35(SRAM_2_in[35]),.DI36(SRAM_2_in[36]),.DI37(SRAM_2_in[37]),.DI38(SRAM_2_in[38]),.DI39(SRAM_2_in[39]),
                             .DI40(SRAM_2_in[40]),.DI41(SRAM_2_in[41]),.DI42(SRAM_2_in[42]),.DI43(SRAM_2_in[43]),.DI44(SRAM_2_in[44]),.DI45(SRAM_2_in[45]),.DI46(SRAM_2_in[46]),.DI47(SRAM_2_in[47]),
                             .DI48(SRAM_2_in[48]),.DI49(SRAM_2_in[49]),.DI50(SRAM_2_in[50]),.DI51(SRAM_2_in[51]),.DI52(SRAM_2_in[52]),.DI53(SRAM_2_in[53]),.DI54(SRAM_2_in[54]),.DI55(SRAM_2_in[55]),
                             .DI56(SRAM_2_in[56]),.DI57(SRAM_2_in[57]),.DI58(SRAM_2_in[58]),.DI59(SRAM_2_in[59]),.DI60(SRAM_2_in[60]),.DI61(SRAM_2_in[61]),.DI62(SRAM_2_in[62]),.DI63(SRAM_2_in[63]),
                            .CK(clk),.WEB(SRAM_2_WEB),.OE(1'b1),.CS(1'b1));

//================================================================
//                FSM
//================================================================
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        c_s <= S0_IDLE ;
    else
        c_s <= n_s ;
end
always @(*)
begin
    n_s = c_s ;
    case(c_s)
      S0_IDLE:
        if (in_valid)    n_s = S1_RAVALID;
        else             n_s = S0_IDLE ;
      S1_RAVALID:
        if (arready_m_inf) begin
          if (flag_map)  n_s = S3_read_weiMAP_D;
          else           n_s = S2_read_locMAP_D;
        end
        else             n_s = S1_RAVALID ;
      S2_read_locMAP_D:
        if (rlast_m_inf)  n_s = S1_RAVALID;
        else              n_s = S2_read_locMAP_D ;
	    S3_read_weiMAP_D:
        if (rlast_m_inf) begin
          if(Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]]!=0)
               n_s = S10_BUFF;
          else n_s = S5_fillMAP;
        end
        else              n_s = S3_read_weiMAP_D ;	
      S4_setGoal:
         n_s = S5_fillMAP;     	
		  S5_fillMAP:
        // if (flag_1)
        if(Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]]!=0)
            n_s = S6_RETRACE;
        else
            n_s = S5_fillMAP ;
      S10_BUFF:    
        if(SRAM_1_add==255)
          n_s = S6_RETRACE ;
        else 
          n_s = S10_BUFF ;
		  S6_RETRACE:
        // if (cur_X_d1==sour_X[cnt_net_num] && cur_Y_d1==sour_Y[cnt_net_num])
        if (cur_X==sour_X[cnt_net_num] && cur_Y==sour_Y[cnt_net_num] )
            n_s = S7_JUDGE;
        else
            n_s = S6_RETRACE ;	
      S7_JUDGE:
        if((cnt_net_num+1)==NETnum) 
          n_s = S8_WAVALID;
        else 
          n_s = S4_setGoal;
      S8_WAVALID:
            if (awready_m_inf)
              n_s = S9_write_loc_D;
            else
              n_s = S8_WAVALID;											
		  S9_write_loc_D :
          if (bvalid_m_inf) n_s = S0_IDLE;
          else              n_s = S9_write_loc_D ;
        default:
            n_s = S0_IDLE;
    endcase
end
// ===============================================================
//      cnt & DELAY & FLAG
// ===============================================================
always@(posedge clk or negedge rst_n)
begin
  if (!rst_n) in_valid_d1 <= 0;
  else in_valid_d1 <= in_valid;
end

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n) begin
    wready_m_inf_d1 <= 0;
    // rlast_m_inf_d <= 0;
    // rlast_m_inf_d2 <= 0;
  end
  
  else begin
    wready_m_inf_d1 <= wready_m_inf;
    // rlast_m_inf_d <= rlast_m_inf;
    // rlast_m_inf_d2 <= rlast_m_inf_d;
  end
end


always@(posedge clk or negedge rst_n)
begin
  if (!rst_n) cnt_net_num <= 0;
  else if(c_s==S7_JUDGE) begin
    cnt_net_num <= cnt_net_num + 1;
  end
  else if(c_s==S0_IDLE) cnt_net_num <= 0;
end



// ===============================================================
//  				      cnt_2
// ===============================================================
  always @ (posedge clk or negedge rst_n) begin 
  	if (!rst_n) cnt_2 <= 0 ;
  	else begin
  		if (c_s == S0_IDLE)                                                    cnt_2 <= 0 ;
      else if(flag_map && c_s <= 3) begin
        if (cnt==1) cnt_2 <= cnt_2 + 1 ;
        else if(cnt>1) begin
          if(flag_filldone) cnt_2 <= cnt_2;
          else if(Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]]!=0) cnt_2 <= cnt_2 - 2 ;
          else cnt_2 <= cnt_2 + 1 ;
        end
      end
      else if(c_s == S4_setGoal || (c_s == S5_fillMAP && n_s == S5_fillMAP)) cnt_2 <= cnt_2 + 1 ;
      else if(c_s == S5_fillMAP && n_s == S6_RETRACE ) cnt_2 <= cnt_2 - 2 ; 
  		else if(c_s == S6_RETRACE && cnt_3==2)                                  cnt_2 <= cnt_2 - 1 ; 
      else if(c_s ==S7_JUDGE) cnt_2 <= 0;
  		// else if(c_s == S8_WAVALID && n_s == S4_setGoal)                    cnt_2 <= 0 ;      
  		else cnt_2 <= cnt_2 ;
  	end
  end
  always @ (posedge clk or negedge rst_n) begin 
  	if (!rst_n) cnt_3 <= 0 ;  
    else if(in_valid) cnt_3 <= cnt_3 + 1;
    else if(c_s==S0_IDLE) cnt_3 <= 0;
    else if(c_s==S3_read_weiMAP_D) cnt_3 <= 0;
    else if(c_s==S5_fillMAP) cnt_3 <= 0;
    else if(c_s==S6_RETRACE) begin
      if(cnt_3==3) cnt_3 <= 1;
      else cnt_3 <= cnt_3 + 1;
    end
    else cnt_3 <= cnt_3;
  end

// ------- cnt_dram -----------------------
  always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n) cnt_dram <= 0;
    else begin
      if(rvalid_m_inf || wready_m_inf) cnt_dram <= cnt_dram + 1;
      else cnt_dram <= 0;
    end
  end
  always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n) cnt <= 0;
    else if (c_s==S0_IDLE) cnt <= 0;
    else if(c_s==S1_RAVALID || c_s==S2_read_locMAP_D || c_s==S3_read_weiMAP_D)begin
      if(flag_map) begin
        if(cnt==3) cnt <= cnt;
        else cnt <= cnt+1;
      end
      else        cnt <= cnt;
    end
    else if(c_s==S10_BUFF) cnt <= 0;
    else if(c_s==S5_fillMAP) cnt <= 0;
    else if(c_s==S6_RETRACE) begin
      if(cnt==3) cnt <= cnt;
      else cnt <= cnt+1;
    end
    // else if(c_s==S8_WAVALID) cnt <= 0;
    // else begin
    //   if(c_s==S9_write_loc_D) cnt <= cnt + 1;
    //   else cnt <= 0;
    // end
  end
// --------- flag --------------------------
always @(posedge clk or negedge rst_n) 
begin
  if(!rst_n) flag_3 <= 0;  
  else if(in_valid) flag_3 <= ~flag_3;
  else flag_3 <= flag_3;
end
always @(posedge clk or negedge rst_n) 
begin
  if(!rst_n) flag_map<=0;
  else if(rlast_m_inf) flag_map <= 1;
  else if(c_s==S0_IDLE) flag_map <= 0;
  else   flag_map<=flag_map;
end

// always @(posedge clk or negedge rst_n) 
// begin
//   if(!rst_n) flag_1 <= 0;
//   else if(rlast_m_inf && !flag_filldone) flag_1 <= 0;
//   else if(c_s==S4_setGoal) flag_1 <= 0;
//   else if(c_s<=5 && n_s==S6_RETRACE) flag_1 <= 1;
// //   else if(c_s==S5_fillMAP)begin
// //     // if(Map[sink_Y[cnt_net_num]+1][sink_X[cnt_net_num]]!=0 && Map[sink_Y[cnt_net_num]-1][sink_X[cnt_net_num]]!=0 && Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]+1]!=0 && Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]-1]!=0) flag_1 <= 1;
// //     if(n_s==S6_RETRACE) flag_1 <= 1;
// //     else flag_1 <= 0;  
// //   end
//   else if(c_s==S6_RETRACE) begin
//     if((cur_X!=cur_X_d1)||(cur_Y!=cur_Y_d1)) flag_1 <= 0;
//   end
//   else if(c_s==S0_IDLE) flag_1 <= 0;
//   else   flag_1 <= flag_1;
// end

always @(posedge clk or negedge rst_n) 
begin
  if(!rst_n) flag_filldone <= 0;
  else if(c_s==S0_IDLE) flag_filldone <= 0;
  else if(flag_map && (cnt > 1) && Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]]!=0) flag_filldone <= 1;
  else if(c_s==S4_setGoal) flag_filldone <= 0;
  else flag_filldone <= flag_filldone;
end


// ===============================================================
//      INPUT
// ===============================================================
always@(posedge clk) // reg frame_id
  begin
    if (in_valid && !cnt_3[0]) r_frameID <= frame_id;
    // else if (c_s == S0_IDLE) r_frameID <= 0;
    else r_frameID <= r_frameID;
  end
// always@(posedge clk) // reg frame_id
//   begin
//     if (in_valid && !in_valid_d1) r_frameID <= frame_id;
//     // else if (c_s == S0_IDLE) r_frameID <= 0;
//     else r_frameID <= r_frameID;
//   end
always@(posedge clk) // total number of nets
  begin
    if (in_valid && cnt_3[0]==1) NETnum <= NETnum+1;
    else if (c_s == S0_IDLE) NETnum <= 0;
  end

always@(posedge clk) // reg frame_id
  begin
    // if(c_s==S0_IDLE) begin
    //   for(i=0;i<16;i=i+1) begin
    //     net_ID[i] <= 0;
    //   end    
    // end
    // else begin
      if(in_valid && cnt_3[0]==0) net_ID[cnt_3[4:1]] <= net_id;
    // end
  end
//--------------source & sink ------------------------------
  //------- SOURCE ------------------------------------
    always@(posedge clk)
      begin
        // if(!rst_n) begin
        //   for (i=0; i<15; i=i+1) begin
        //     sour_X[i] <= 0;  
        //   end
        // end
       if(in_valid && !flag_3) sour_X[NETnum] <= loc_x;
        else begin
          for (i=0; i<15; i=i+1) begin
            sour_X[i] <= sour_X[i];  
          end
        end 
      end
    always@(posedge clk)
      begin
        // if(!rst_n) begin
        //   for (i=0; i<15; i=i+1) begin
        //     sour_Y[i] <= 0;  
        //   end
        // end
       if(in_valid && !flag_3) sour_Y[NETnum] <= loc_y;
        else begin
          for (i=0; i<15; i=i+1) begin
            sour_Y[i] <= sour_Y[i];  
          end
        end 
      end
  //-------- SINK --------------------------------------
    always@(posedge clk)
      begin
        // if(!rst_n) begin
        //   for (i=0; i<15; i=i+1) begin
        //     sink_X[i] <= 0;  
        //   end
        // end
        if(in_valid && flag_3) sink_X[NETnum] <= loc_x;
        else begin
          for (i=0; i<15; i=i+1) begin
            sink_X[i] <= sink_X[i];  
          end
        end 
      end
    always@(posedge clk)
      begin
        // if(!rst_n) begin
        //   for (i=0; i<15; i=i+1) begin
        //     sink_Y[i] <= 0;  
        //   end
        // end
        if(in_valid && flag_3) sink_Y[NETnum] <= loc_y;
        else begin
          for (i=0; i<15; i=i+1) begin
            sink_Y[i] <= sink_Y[i];  
          end
        end 
      end
  

    
  
// -----------------------------------------------------------------
//    MMM     MMMM       AAAAAA        PPPPPPPPP 
//    MMMMM  MMMMM      AAA  AAA      PPP    PPP
//    MM  MMMM  MM     AAA    AAA     PPPPPPPPP
//    MM   MM   MM    AAAAAAAAAAAA    PPP
//    MM        MM   AAA        AAA   PPP  
// -----------------------------------------------------------------
always@(posedge clk)
  begin
    // if(!rst_n)begin
  	//     for(i=0; i<64; i=i+1)begin
  	//       for(j=0; j<64; j=j+1) begin
  	//         Map[i][j] <= 0;
  	//       end
  	//     end
    //   end
    // else begin
      if(c_s==S2_read_locMAP_D && rvalid_m_inf) 
        begin   
           for (k = 0; k < 32; k = k + 1)  
              begin
                Map[cnt_dram>>1][((cnt_dram[0])<<5)+k] <= {1'b0,(|rdata_m_inf[k<<2+:4])}; // 0: road, 1: object or net, 2,3: wave propagation
                // Map[cnt_dram/2][(cnt_dram%2)*32+k] <= {1'b0,(|rdata_m_inf[k*4+:4])}; // 0: road, 1: object or net, 2,3: wave propagation
              end
        end
      else if(((c_s==S1_RAVALID || c_s==S2_read_locMAP_D || c_s==S3_read_weiMAP_D) && cnt==1) || c_s==S4_setGoal) 
        begin
          Map[sour_Y[cnt_net_num]][sour_X[cnt_net_num]] <= 2; // propagate from source
          Map[sink_Y[cnt_net_num]][sink_X[cnt_net_num]] <= 0; // sink is the goal of propagation
        for (X = 0 ; X < 64 ; X = X + 1) begin 
			    for (Y = 0 ; Y < 64 ; Y = Y + 1) begin 
			    	if (Map[Y][X][1]) begin 
			    		Map[Y][X] <= 0 ;  
			    	end
			  end
			end
        end
      else if(c_s==S5_fillMAP || (!flag_filldone && cnt>1 && (c_s==S1_RAVALID || c_s==S2_read_locMAP_D || c_s==S3_read_weiMAP_D))) 
        begin
			  // middle
			    for (X = 1 ; X < 63 ; X = X + 1) begin  
			    	for (Y = 1 ; Y < 63 ; Y = Y + 1) begin 
			    		if (Map[Y][X] == 0 && (Map[Y-1][X][1] | Map[Y+1][X][1] | Map[Y][X-1][1] | Map[Y][X+1][1])) Map[Y][X] <= {1'b1, cnt_2[1]};
			    	end
			    end
			  // boundary
			    for (Y = 1 ; Y < 63 ; Y = Y + 1) begin 
			    	if (Map[Y][0]  == 0 && (Map[Y+1][0][1]  | Map[Y-1][0][1]  | Map[Y][1][1]))  Map[Y][0]  <= {1'b1, cnt_2[1]} ;
			    	if (Map[Y][63] == 0 && (Map[Y+1][63][1] | Map[Y-1][63][1] | Map[Y][62][1])) Map[Y][63] <= {1'b1, cnt_2[1]} ;
			    end
			    for (X = 1 ; X < 63 ; X = X + 1) begin 
			    	if (Map[0][X]  == 0 && (Map[0][X+1][1]  | Map[0][X-1][1]  | Map[1][X][1]))  Map[0][X]  <= {1'b1, cnt_2[1]} ;
			    	if (Map[63][X] == 0 && (Map[63][X+1][1] | Map[63][X-1][1] | Map[62][X][1])) Map[63][X] <= {1'b1, cnt_2[1]} ;
			    end
        // corner
			    if (Map[0][0] == 0   && (Map[0][1][1]   | Map[1][0][1]))   Map[0][0]   <= {1'b1, cnt_2[1]} ;
			    if (Map[63][63] == 0 && (Map[63][62][1] | Map[62][63][1])) Map[63][63] <= {1'b1, cnt_2[1]} ;
			    if (Map[0][63]  == 0 && (Map[1][63][1]  | Map[0][62][1]))  Map[0][63]  <= {1'b1, cnt_2[1]} ;
			    if (Map[63][0]  == 0 && (Map[63][1][1]  | Map[62][0][1]))  Map[63][0]  <= {1'b1, cnt_2[1]} ;           
        end
      else if(c_s==S6_RETRACE || c_s==S7_JUDGE)
        begin
          Map[cur_Y_d1][cur_X_d1] <= 1; // make net
        end
      else begin
        for(i=0; i<64; i=i+1)begin
  	      for(j=0; j<64; j=j+1) begin
  	        Map[i][j] <=  Map[i][j];
  	      end
  	    end
      end  
    // end 
  end


// -----------------------------------------------------------------
//   RRRRRRRRR   EEEEEEEEE  TTTTTTTTT  RRRRRRRRR      AAAA     
//   RR     RRR  EE            TT      RR     RRR    AA  AA    
//   RRRRRRRRR   EEEEEEEE      TT      RRRRRRRRR    AA    AA   
//   RR    RR    EE            TT      RR    RR    AAAAAAAAAA  
//   RR     RRR  EEEEEEEEE     TT      RR     RRR AA        AA 
// -----------------------------------------------------------------
  // convience to write
  assign cur_X_add1 = cur_X +1; 
  assign cur_X_minus1 = cur_X -1;
  assign cur_Y_add1 = cur_Y +1;
  assign cur_Y_minus1 = cur_Y -1;

// Current coordinate
  always@(posedge clk)begin
    // if(!rst_n) begin
    //   cur_X <= 0;
    //   cur_Y <= 0;
    // end
    // else begin
      if(c_s == S2_read_locMAP_D)begin
        cur_X <= sink_X[cnt_net_num];
        cur_Y <= sink_Y[cnt_net_num];
      end
      else if(c_s == S5_fillMAP)begin
        cur_X <= sink_X[cnt_net_num];
        cur_Y <= sink_Y[cnt_net_num];
      end      
      else if(c_s == S6_RETRACE && cnt_3==2) begin 
        if((~cur_Y_add1[6]) && Map[cur_Y_add1][cur_X]=={1'b1,cnt_2[1]}) begin
          cur_X <= cur_X;
          cur_Y <= cur_Y_add1;
        end
        else if((~cur_Y_minus1[6]) && Map[cur_Y_minus1][cur_X]=={1'b1,cnt_2[1]})begin
          cur_X <= cur_X;
          cur_Y <= cur_Y_minus1;          
        end
        else if((~cur_X_add1[6]) && Map[cur_Y][cur_X_add1]=={1'b1,cnt_2[1]})begin
          cur_X <= cur_X_add1;
          cur_Y <= cur_Y;          
        end
        else if((~cur_X_minus1[6]) && Map[cur_Y][cur_X_minus1]=={1'b1,cnt_2[1]})begin
          cur_X <= cur_X_minus1;
          cur_Y <= cur_Y;          
        end
        else begin
          cur_X <= cur_X;
          cur_Y <= cur_Y;
        end                
      end
    // end
  end
// Last coordinate
  always@(posedge clk)begin
    // if(!rst_n) cur_X_d1 <= 0;
   cur_X_d1 <= cur_X;
    // else begin
    //   if(c_s==S5_fillMAP) cur_X_d1 <= cur_X;
    //   else if(c_s==S6_RETRACE) cur_X_d1 <= cur_X;
    // end
  end
  always@(posedge clk)begin
    // if(!rst_n) cur_Y_d1 <= 0;
    cur_Y_d1 <= cur_Y;
    // else begin
    //   if(c_s==S5_fillMAP) cur_Y_d1 <= cur_Y;
    //   else if(c_s==S6_RETRACE) cur_Y_d1 <= cur_Y;
    // end
  end    

// -----------------------------------------------------------------
//  DDDDDDDD    RRRRRRRRR      AAAA     MMM     MMMM 
//  DD    DDD   RR     RRR    AA  AA    MMMMM  MMMMM 
//  DD     DDD  RRRRRRRRR    AA    AA   MM  MMMM  MM 
//  DD    DDD   RR    RR    AAAAAAAAAA  MM   MM   MM 
//  DDDDDDD     RR     RRR AA        AA MM        MM 
// -----------------------------------------------------------------
// <<<<< AXI READ >>>>>
// ------------------------
  // --- 	axi read address channel  ---------------------
    assign arid_m_inf = 'b0;
    assign arburst_m_inf = 2'b01; ///limited to be 2'b01
    assign arsize_m_inf = 3'b100; //limited to be 3'b100 which is 16 Bytes
    assign arlen_m_inf = 'd127; // (64*64)/16 one address can store 16 grids
    
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n) arvalid_m_inf <= 0;
    	else if (arready_m_inf)   arvalid_m_inf <= 0;	
    	else if (c_s==S1_RAVALID) arvalid_m_inf <= 1;
    end
    
    always@(posedge clk or negedge rst_n)
    begin
    	if(!rst_n) araddr_m_inf <= 0;
    	else if(c_s==S1_RAVALID) begin
        if(flag_map)       araddr_m_inf <= 32'h00020000 + r_frameID*'h800;
        else               araddr_m_inf <= 32'h00010000 + r_frameID*'h800; 
      end
    end
    
  // --- 	axi read data channel  ---------------------
    always@(posedge clk or negedge rst_n)
      begin
        if(!rst_n) rready_m_inf <= 0;
        else if(arready_m_inf) rready_m_inf <= 1;
        else if(rlast_m_inf)   rready_m_inf <= 0;
      end

    always@(posedge clk or negedge rst_n)
      begin
        if(!rst_n) rvalid_m_inf_d1 <= 0;
        else rvalid_m_inf_d1 <= rvalid_m_inf;
      end  
    always@(posedge clk or negedge rst_n)
      begin
        if(!rst_n) r_rdata <= 0;
        else r_rdata <= rdata_m_inf;
      end 
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
assign awid_m_inf    = 4'b0;
assign awburst_m_inf = 2'b01;
assign awsize_m_inf  = 3'b100;
assign awlen_m_inf   = 127; 

// (1) 	axi write address channel
 assign   awaddr_m_inf = 32'h00010000 + r_frameID*'h800;
 always@(posedge clk or negedge rst_n) begin
   if(!rst_n) awvalid_m_inf <= 0;
   else begin
    if (awready_m_inf)    awvalid_m_inf<=0;
    else if(c_s==S8_WAVALID) awvalid_m_inf <= 1;
    else awvalid_m_inf <= 0;
   end
 end 
// (2)	axi write data channel 
assign wlast_m_inf = (cnt_dram==127)? 1:0;
assign wvalid_m_inf = 1;
assign wdata_m_inf = r_wdata;

always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n) r_wdata <= 0;
    else if(wready_m_inf && !wready_m_inf_d1) r_wdata <= temp_reg;
    else if(wready_m_inf) r_wdata <= {SRAM_2_out,SRAM_1_out};
    else r_wdata <= temp_reg_2;
  end

always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n) temp_reg <= 0;
    else if(c_s==S9_write_loc_D && SRAM_1_add_d1==2) temp_reg <= {SRAM_2_out,SRAM_1_out};
  end

always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n) temp_reg_2 <= 0;
    else if(c_s==S8_WAVALID) temp_reg_2 <= {SRAM_2_out,SRAM_1_out};
  end  

always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n) SRAM_1_add_d1 <= 0;
    else SRAM_1_add_d1 <= SRAM_1_add;
  end
  


// (3)	axi write response channel 
assign bready_m_inf = 1;



// =========================================================
//             SRAM switch
// =========================================================
  // always@(posedge clk) //SRAM_1_WEB
  //   begin
  //     if(c_s==S1_RAVALID) f_switch <= 0;
  //     else if(c_s==S6_RETRACE)begin
  //       if(cur_X[3])
  //     end
  //     else f_switch <= f_switch;
  //   end
  always@(*)begin
    if(cur_X[5:4]==2'b01 || cur_X[5:4]==2'b11) f_switch = 1;
    else         f_switch = 0;
  end
  always@(posedge clk)begin
        f_switch_d <= f_switch;
  end

assign index_addr = cur_Y*4;

// =========================================================
//             SRAM 1
// =========================================================
 // ---------- WEB --------------------------
  always@(posedge clk or negedge rst_n) //SRAM_1_WEB
    begin
      if(!rst_n) SRAM_1_WEB <= 1;
      else if(rvalid_m_inf_d1) SRAM_1_WEB <= 0;
      else if(c_s==S6_RETRACE) begin
        if(f_switch) begin // read SRAM1 wei, so SRAM1 no need to write
          SRAM_1_WEB <= 1;
        end
        else begin // read SRAM1 loc, when cnt_3==1 write back loc
          if(cnt_3==2 && cnt==3) SRAM_1_WEB <= 0;
          else         SRAM_1_WEB <= 1;
        end    
      end
      else SRAM_1_WEB <= 1;
    end
 // ---------- ADDRESS --------------------------    
  always@(posedge clk or negedge rst_n) //SRAM128_add
    begin // SRAM_1_add [6:0]
      if(!rst_n) SRAM_1_add <= 0;
      else if(c_s==S0_IDLE) SRAM_1_add <= 0;
      else if(c_s==S10_BUFF && n_s==S6_RETRACE)  SRAM_1_add <= 0;
      else if(c_s==S1_RAVALID && SRAM_1_WEB && flag_map) SRAM_1_add <= 1;
      else if(c_s==S1_RAVALID && !SRAM_1_WEB) SRAM_1_add <= SRAM_1_add+2;
      else if(c_s==S2_read_locMAP_D && !SRAM_1_WEB) SRAM_1_add <= SRAM_1_add+2;
      else if(c_s==S3_read_weiMAP_D && !SRAM_1_WEB) SRAM_1_add <= SRAM_1_add+2;
      else if(c_s==S6_RETRACE)begin
        if(f_switch) begin //  read weight (f_switch means cur_X[3] == 1, read SRAM2 loc read SRAM1 wei)
          SRAM_1_add <= index_addr + 2*cur_X[5] + 1; // when cur_X = 32~63 cur_X[5]=1
        end
        else begin //  read location
          SRAM_1_add <= index_addr + 2*cur_X[5]; // when cur_X = 32~63 cur_X[5]=1
        end
      end
      else if(c_s==S10_BUFF) SRAM_1_add <= SRAM_1_add+2;

      else if(wready_m_inf) SRAM_1_add <= SRAM_1_add+2;
      else if(c_s==S9_write_loc_D) SRAM_1_add <= 4;
      else if(n_s==S9_write_loc_D) SRAM_1_add <= 2;
      else if(c_s==S8_WAVALID) SRAM_1_add <= 0;
      else SRAM_1_add <= SRAM_1_add;
    end
 // ---------- INPUT --------------------------  
  always@(posedge clk or negedge rst_n) //SRAM128_in
    begin
      if(!rst_n)  SRAM_1_in <= 0;
      else if(rvalid_m_inf_d1) begin
        if(flag_map)       SRAM_1_in <= r_rdata[127:64];
        else               SRAM_1_in <= r_rdata[63:0];
      end
      else if(c_s==S6_RETRACE)begin
        SRAM_1_in <= SRAM_1_out + net_line;
      end
      else SRAM_1_in <= SRAM_1_in;
    end

// =========================================================
//             SRAM 2
// =========================================================
  // assign add_1bit  = (cur_X>31)? 1 : 0;
  // assign add_6bits = cur_Y;
 // ---------- WEB --------------------------  
  always@(posedge clk or negedge rst_n) //SRAM_2_WEB
    begin
      if(!rst_n) SRAM_2_WEB <= 1;
      else if(rvalid_m_inf_d1) SRAM_2_WEB <= 0;
      else if(c_s==S6_RETRACE) begin
        if(f_switch) begin // read SRAM2 loc, when cnt_3==1 write back loc
          if(cnt_3==2 && cnt==3) SRAM_2_WEB <= 0;
          else         SRAM_2_WEB <= 1;        
        end
        else begin // read SRAM2 wei, so SRAM2 no need to write
          SRAM_2_WEB <= 1;
        end    
      end
      else SRAM_2_WEB <= 1;
    end
 // ---------- ADDRESS --------------------------      
  always@(posedge clk or negedge rst_n) //SRAM_2_add [6:0]
    begin 
      if(!rst_n)  SRAM_2_add <= 0;
      else if(c_s==S0_IDLE) SRAM_2_add <= 0;
      else if(c_s==S10_BUFF && n_s==S6_RETRACE)  SRAM_2_add <= 0; 
      else if(c_s==S1_RAVALID && SRAM_2_WEB && flag_map) SRAM_2_add <= 1;
      else if(c_s==S1_RAVALID && !SRAM_2_WEB) SRAM_2_add <= SRAM_2_add+2;      
      else if(c_s==S2_read_locMAP_D && !SRAM_2_WEB) SRAM_2_add <= SRAM_2_add+2;
      else if(c_s==S3_read_weiMAP_D && !SRAM_2_WEB) SRAM_2_add <= SRAM_2_add+2;
      else if(c_s==S6_RETRACE)begin
        if(f_switch) begin //  read location (f_switch means cur_X[3] == 1, read SRAM2 loc read SRAM1 wei)
          SRAM_2_add <= index_addr + 2*cur_X[5]; // when cur_X = 32~63 cur_X[5]=1
        end
        else begin //  read weight
          SRAM_2_add <= index_addr + 2*cur_X[5] + 1; // when cur_X = 32~63 cur_X[5]=1
        end
      end
      else if(c_s==S10_BUFF) SRAM_2_add <= SRAM_2_add+2;

      else if(wready_m_inf) SRAM_2_add <= SRAM_2_add+2;
      else if(c_s==S9_write_loc_D) SRAM_2_add <= 4;
      else if(n_s==S9_write_loc_D) SRAM_2_add <= 2;
      else if(c_s==S8_WAVALID) SRAM_2_add <= 0;
      else SRAM_2_add <= SRAM_2_add;
    end
 // ---------- INPUT --------------------------      
  always@(posedge clk or negedge rst_n) //SRAM128_in
    begin
      if(!rst_n)  SRAM_2_in <= 0;
      else if(rvalid_m_inf_d1) begin
        if(flag_map)       SRAM_2_in <= r_rdata[63:0];
        else               SRAM_2_in <= r_rdata[127:64];
      end
      else if(c_s==S6_RETRACE)begin
        SRAM_2_in <= SRAM_2_out + net_line;
      end
    end

// ===============================================================
//      OUTPUT
// ===============================================================
// assign axis_to_address = (cur_X>31)? cur_X-'d32 : cur_X;
// assign assign_out = SRAM_2_out >> (axis_to_address*4);
// assign net_line = net_ID[cnt_net_num] << (axis_to_address*4); 
  
assign axis_to_address = (cur_X >= 16 && cur_X <= 31) ? (cur_X - 16) :
                         (cur_X >= 32 && cur_X <= 47) ? (cur_X - 32) :
                         (cur_X >= 48)                ? (cur_X - 48) :
                         cur_X;
assign net_line = net_ID[cnt_net_num] << (axis_to_address*4); 
assign assign_out = (f_switch_d)? SRAM_1_out >> (axis_to_address*4) : SRAM_2_out >> (axis_to_address*4);


always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)  flag_2 <= 0;
  else if(c_s==S6_RETRACE && (cur_X_d1!=sink_X[cnt_net_num] || cur_Y_d1!=sink_Y[cnt_net_num])) flag_2 <= 1;
  else if(c_s==S0_IDLE) flag_2 <= 0;
end
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)  busy <= 0;
    else if(n_s == S0_IDLE || in_valid)  busy <= 0;
    else    busy <= 1;
end

always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n) cost <= 0;
    else if(c_s==S0_IDLE) cost <= 0;
    // else if(c_s==S6_RETRACE && cnt_3==2 && !flag_1) begin
    //     if(flag_2) cost <= cost + assign_out;
    // end
    else if(c_s==S6_RETRACE)begin
      if(cnt_3==2 &&  flag_2 && cnt==3)begin
        cost <= cost + assign_out;
      end
    end
    else cost <= cost;
  end


endmodule
