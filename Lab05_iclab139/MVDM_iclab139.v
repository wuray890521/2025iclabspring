module MVDM(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    in_data,
    // output signals
    out_valid,
    out_sad
    );

input clk;
input rst_n;
input in_valid;
input in_valid2;
input [11:0] in_data;

output reg out_valid;
output reg out_sad;

//=======================================================
//                   Reg/Wire
//=======================================================
// ---------------integer-----------
integer i, j;
// ---------------integer-----------
// -----------------FSM---------------------
reg [3:0] c_s, n_s;
parameter S0_IDLE       = 3'd0;
parameter S1_LOAD_IMG   = 3'd1;
parameter S2_LOAD_MV    = 3'd2;
parameter S3_CAL_BI     = 3'd3;
parameter S4_CAL_BI_p2  = 3'd4;
parameter S5_SAD        = 3'd5;
parameter S6_OUT        = 3'd6;

// --------- input data for SRAM L0 ------------
reg [7:0] in_data_d;
reg [7:0] in_data_out_l0;

reg in_valid_d;
reg [6:0] count_in_x;
reg [6:0] count_in_y;
reg web_input_l0;
wire [13:0] addres;

// --------- input data for SRAM L1 ------------
reg [7:0] in_data_out_l1;
reg [6:0] count_in_x_l1;
reg [6:0] count_in_y_l1;
reg web_input_l1;
wire [13:0] addres_1;

// ------------in_valid2----------
reg [11:0] motion_reg[0:7];

reg [7:0] fraction_xy_point_1_l0 ;
reg [7:0]  fraction_y_point_1_l0 ;
reg [7:0]  fraction_x_point_1_l0 ;

reg [7:0] fraction_xy_point_1_l1;
reg [7:0]  fraction_y_point_1_l1;
reg [7:0]  fraction_x_point_1_l1;

reg [7:0] fraction_xy_point_2_l0;
reg [7:0]  fraction_y_point_2_l0;
reg [7:0]  fraction_x_point_2_l0;

reg [7:0] fraction_xy_point_2_l1;
reg [7:0]  fraction_y_point_2_l1;
reg [7:0]  fraction_x_point_2_l1;

// ----------c_s == S3_CAL_BI-------------
reg [3:0] count_bi;
reg [3:0] count_bi_y;

wire [8:0] p0_l0_point1;
wire [8:0] p1_l0_point1;
wire [8:0] p2_l0_point1;
wire [8:0] p3_l0_point1;

wire [8:0] p0_l1_point1;
wire [8:0] p1_l1_point1;
wire [8:0] p2_l1_point1;
wire [8:0] p3_l1_point1;

wire [8:0] p0_l0_point2;
wire [8:0] p1_l0_point2;
wire [8:0] p2_l0_point2;
wire [8:0] p3_l0_point2;

wire [8:0] p0_l1_point2;
wire [8:0] p1_l1_point2;
wire [8:0] p2_l1_point2;
wire [8:0] p3_l1_point2;

reg [7:0] l0_data_point1;
reg [7:0] l0_data_max[0:1][0:10];

reg [7:0] l1_data_point1;
reg [7:0] l1_data_max[0:1][0:10];

reg [7:0] cnt;
reg [4:0] cnt_Lmat_x;
reg       cnt_Lmat_y;

reg [3:0] count_pointer_x;
reg [3:0] count_pointer_y;

reg [15:0] p0_bi;
reg [15:0] p1_bi;
reg [15:0] p2_bi;
reg [15:0] p3_bi;
wire [15:0] bi_l0;
wire [15:0] bi_l0_p2;

reg [15:0] p0_bi_l1;
reg [15:0] p1_bi_l1;
reg [15:0] p2_bi_l1;
reg [15:0] p3_bi_l1;
wire [15:0] bi_l1;
wire [15:0] bi_l1_p2;
// addres to write read to SRAM
reg [3:0] Bi_L0_p1_addr_x, Bi_L0_p1_addr_y; 

reg [3:0] Bi_L1_p1_addr_x, Bi_L1_p1_addr_y; 

reg [3:0] Bi_L0_p2_addr_x, Bi_L0_p2_addr_y; 

reg [3:0] Bi_L1_p2_addr_x, Bi_L1_p2_addr_y; 

wire [6:0] addres_bi_p1_l0;
wire [6:0] addres_bi_p1_l1;
wire [6:0] addres_bi_p2_l0;
wire [6:0] addres_bi_p2_l1;
// wire [7:0] addres_bi_p1_l0;
// wire [7:0] addres_bi_p1_l1;
// wire [7:0] addres_bi_p2_l0;
// wire [7:0] addres_bi_p2_l1;



reg [3:0] count_bi_p2_x;
reg [3:0] count_bi_p2_y; 
// wire [7:0] addres_bi_p2_l0;
reg web_bi_l0_p2;

reg [3:0] count_bi_p1_x_l1;
// reg [3:0] count_bi_p1_y_l1; 

reg [3:0] count_bi_p2_x_l1;
reg [3:0] count_bi_p2_y_l1; 
// wire [7:0] addres_bi_p2_l1;
reg web_bi_l1_p2;

reg web_bi_l0_p1;
reg [15:0] bi_l0_p1_out;
reg [15:0] bi_l0_p2_out;

reg web_bi_l1_p1;
reg [15:0] bi_l1_p1_out;
reg [15:0] bi_l1_p2_out;
// addres to write read to SRAM

reg [15:0] L0_p1_BiSRAM_in;
reg [15:0] L0_p2_BiSRAM_in;
reg [15:0] L1_p1_BiSRAM_in;
reg [15:0] L1_p2_BiSRAM_in;


// ----------c_s == S5_SAD ---------------
reg [4:0] count_pointer_sad_x;
reg [4:0] count_pointer_sad_y;
// reg [4:0] count_pointer_sad_y_d1;

reg [1:0] count_start_sad_x;
reg [1:0] count_start_sad_y;
// always@(posedge clk)begin
//   if(c_s == S5_SAD)  count_pointer_sad_y_d1 <= count_pointer_sad_y;
//   else count_pointer_sad_y_d1 <= 0;
// end

reg [15:0] l0_data_sad_p1;
reg [15:0] l1_data_sad_p1;

reg [15:0] l0_data_sad_p2;
reg [15:0] l1_data_sad_p2;

reg [15:0] sad_point1;
reg [27:0] sad_sum_point1;

reg [15:0] sad_point2;
reg [27:0] sad_sum_point2;

reg [3:0] count_sad;
reg [3:0] count_sad_d;

// reg [27:0] out_sad_reg_point1;
// reg [27:0] out_sad_reg_point1_max[0:8];
reg [27:0] min_value_p1;
integer g;

// reg [27:0] out_sad_reg_point2;
// reg [27:0] out_sad_reg_point2_max[0:8];
reg [27:0] min_value_p2;
integer k;



reg [27:0] compare_reg_p1, compare_reg_p2;


wire [55:0] out_sad_data;
// ----------c_s == S5_SAD ---------------

// ------------ c_s == S_OUT ------------
reg [5:0] count_out;
// ------------ c_s == S_OUT ------------


//=======================================================
//                   Design
//=======================================================
// -----------------FSM---------------------
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
                    n_s = S1_LOAD_IMG;
                else if (in_valid2)
                    n_s = S2_LOAD_MV;
                else
                    n_s = S0_IDLE;
            end
          S1_LOAD_IMG:
            begin
                if (in_valid2)
                    n_s = S2_LOAD_MV;
                else
                    n_s = S1_LOAD_IMG;
            end
          S2_LOAD_MV:
            begin
                if (cnt == 3)
                    n_s = S3_CAL_BI;
                else
                    n_s = S2_LOAD_MV;
            end
          S3_CAL_BI:
            begin
                // if (count_pointer_x == 9 && count_pointer_y == 9)
                if (cnt==129)
                    n_s = S4_CAL_BI_p2;
                else
                    n_s = S3_CAL_BI;
            end
          S4_CAL_BI_p2:
            begin
                // if (count_pointer_x == 9 && count_pointer_y == 9)
                if (cnt==126)
                    n_s = S5_SAD;
                else
                    n_s = S4_CAL_BI_p2;
            end
        //   S5_SAD:
        //     begin
        //       n_s = S5_SAD;
        //     end
          S5_SAD:
            begin
                if (count_sad == 10)
                    n_s = S6_OUT;
                else
                    n_s = S5_SAD;
            end
          S6_OUT:
            begin
                if (count_out == 56)
                    n_s = S0_IDLE;
                else
                    n_s = S6_OUT;
            end
          default:
              n_s = S0_IDLE;
      endcase
  end
// -----------------FSM---------------------

//================================================================
//                 COUNTER
//================================================================
//------- big cnt -------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)              cnt <= 0;
    else if (in_valid2)      cnt <= cnt + 1;
    else if (c_s==S3_CAL_BI) begin
      if(cnt==129) cnt <= 0;
      else         cnt <= cnt + 1;
    end
    else if (c_s==S4_CAL_BI_p2) begin
      if(n_s==S5_SAD) cnt <= 0;
      else            cnt <= cnt + 1;
    end
    else if(c_s==S5_SAD)  cnt <= cnt + 1;
    else if(c_s==S0_IDLE)    cnt <= 0;
    else if(c_s==S6_OUT)     cnt <= 0;
    else                     cnt <= cnt;
  end
//=================================================
//              DELAY 
//=================================================
  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        in_valid_d <= 0;
      end
      else in_valid_d <= in_valid;
  end

  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          in_data_d <= 0;
      end
      else if (in_valid) begin
          in_data_d <= in_data[11:4];
      end
      else in_data_d <= 0;
  end

//=================================================
//              MOTION 
//=================================================
  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          for (i = 0; i < 8 ; i = i + 1 ) begin
              motion_reg[i] <= 0;
          end
      end
      else if (in_valid2) begin
          motion_reg[cnt] <= in_data;
      end
      else begin
          for (i = 0; i < 8 ; i = i + 1 ) begin
              motion_reg[i] <= motion_reg[i];
          end        
      end
  end
//================================================================
//               Bi SRAM L0 p1
//================================================================
//------ address -------------------------------------------
// assign addres_bi_p1_l0 = {Bi_L0_p1_addr_y, Bi_L0_p1_addr_x};
assign addres_bi_p1_l0 = Bi_L0_p1_addr_y*10 + Bi_L0_p1_addr_x;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L0_p1_addr_x <= 0;
    end
    else if (c_s==S3_CAL_BI && cnt>=22) begin
      if(Bi_L0_p1_addr_x==10) Bi_L0_p1_addr_x <= 0;
      else Bi_L0_p1_addr_x <= Bi_L0_p1_addr_x+1;
    end
    else if (c_s == S5_SAD) begin
        Bi_L0_p1_addr_x <= count_start_sad_y + count_pointer_sad_x;
    end
    else if (c_s == S6_OUT) begin
        Bi_L0_p1_addr_x <= 0;
    end
    else Bi_L0_p1_addr_x <= Bi_L0_p1_addr_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L0_p1_addr_y <= 0;
    end
    else if (c_s==S3_CAL_BI && cnt>=22) begin
      if(Bi_L0_p1_addr_x==9) Bi_L0_p1_addr_y <= Bi_L0_p1_addr_y+1;
      else Bi_L0_p1_addr_y <= Bi_L0_p1_addr_y;
    end
    else if (c_s == S5_SAD) begin
        Bi_L0_p1_addr_y <= count_start_sad_x + count_pointer_sad_y;
    end
    else if (c_s == S6_OUT) begin
        Bi_L0_p1_addr_y <= 0;
    end
    else Bi_L0_p1_addr_y <= Bi_L0_p1_addr_y;
end

//--------- WEB --------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_bi_l0_p1 <= 1;
    end
    else if (c_s == S3_CAL_BI) begin
      if (Bi_L0_p1_addr_x==9)   web_bi_l0_p1 <= 1;  
      else if(cnt >= 21)    web_bi_l0_p1 <= 0;
    end
    else web_bi_l0_p1 <= 1;
end
//------------ input ---------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) L0_p1_BiSRAM_in <= 0;
    // if(c_s == S0_IDLE) L0_p1_BiSRAM_in <= 0;
    else if(c_s == S3_CAL_BI)begin
      L0_p1_BiSRAM_in <= bi_l0;
    end
  end

//================================================================
//               Bi SRAM L1 p1
//================================================================
//------ address -------------------------------------------
// assign addres_bi_p1_l1 = {Bi_L1_p1_addr_y, Bi_L1_p1_addr_x};
assign addres_bi_p1_l1 = Bi_L1_p1_addr_y * 10 + Bi_L1_p1_addr_x;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L1_p1_addr_x <= 0;
    end
    else if (c_s==S3_CAL_BI && cnt>=22) begin
      if(Bi_L1_p1_addr_x==10) Bi_L1_p1_addr_x <= 0;
      else Bi_L1_p1_addr_x <= Bi_L1_p1_addr_x+1;
    end
    else if (c_s == S5_SAD) begin
        Bi_L1_p1_addr_x <= 2 + count_pointer_sad_x - count_start_sad_y;
    end
    else if (c_s == S6_OUT) begin
        Bi_L1_p1_addr_x <= 0;
    end
    else Bi_L1_p1_addr_x <= Bi_L1_p1_addr_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L1_p1_addr_y <= 0;
    end
    else if (c_s==S3_CAL_BI && cnt>=22) begin
      if(Bi_L1_p1_addr_x==9) Bi_L1_p1_addr_y <= Bi_L1_p1_addr_y+1;
      else Bi_L1_p1_addr_y <= Bi_L1_p1_addr_y;
    end
    else if (c_s == S5_SAD) begin
        Bi_L1_p1_addr_y <= 2 + count_pointer_sad_y - count_start_sad_x;
    end
    else if (c_s == S6_OUT) begin
        Bi_L1_p1_addr_y <= 0;
    end
    else Bi_L1_p1_addr_y <= Bi_L1_p1_addr_y;
end

//--------- WEB --------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_bi_l1_p1 <= 1;
    end
    else if (c_s == S3_CAL_BI) begin
      if (Bi_L1_p1_addr_x==9)   web_bi_l1_p1 <= 1;  
      else if(cnt >= 21)    web_bi_l1_p1 <= 0;
    end
    else web_bi_l1_p1 <= 1;
end
//------------ input ---------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) L1_p1_BiSRAM_in <= 0;
    // if(c_s == S0_IDLE) L0_p1_BiSRAM_in <= 0;
    else if(c_s == S3_CAL_BI)begin
      L1_p1_BiSRAM_in <= bi_l1;
    end
  end

//================================================================
//               Bi SRAM L0 p2
//================================================================
//------ address -------------------------------------------
// assign addres_bi_p2_l0 = {Bi_L0_p2_addr_y, Bi_L0_p2_addr_x};
assign addres_bi_p2_l0 = Bi_L0_p2_addr_y * 10 + Bi_L0_p2_addr_x;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L0_p2_addr_x <= 0;
    end
    else if (c_s==S4_CAL_BI_p2 && cnt>=18) begin
      if(Bi_L0_p2_addr_x==10) Bi_L0_p2_addr_x <= 0;
      else Bi_L0_p2_addr_x <= Bi_L0_p2_addr_x+1;
    end
    else if (c_s == S5_SAD) begin
        Bi_L0_p2_addr_x <= count_start_sad_y + count_pointer_sad_x;
        // if (count_start_sad_y == 8) Bi_L0_p2_addr_x <= 0;
        // else Bi_L0_p2_addr_x <= count_start_sad_y + count_pointer_sad_x;
    end
    else if (c_s == S6_OUT) begin
        Bi_L0_p2_addr_x <= 0;
    end
    else Bi_L0_p2_addr_x <= Bi_L0_p2_addr_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L0_p2_addr_y <= 0;
    end
    else if (c_s==S4_CAL_BI_p2 && cnt>=18) begin
      if(Bi_L0_p2_addr_x==9) Bi_L0_p2_addr_y <= Bi_L0_p2_addr_y+1;
      else Bi_L0_p2_addr_y <= Bi_L0_p2_addr_y;
    end
    else if (c_s == S5_SAD) begin
        Bi_L0_p2_addr_y <= count_start_sad_x + count_pointer_sad_y;
        // if (count_start_sad_y == 8) Bi_L0_p2_addr_y <= 0;
        // else Bi_L0_p2_addr_y <= count_start_sad_x + count_pointer_sad_y;
    end
    else if (c_s == S6_OUT) begin
        Bi_L0_p2_addr_y <= 0;
    end
    else Bi_L0_p2_addr_y <= Bi_L0_p2_addr_y;
end

//--------- WEB --------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_bi_l0_p2 <= 1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if (Bi_L0_p2_addr_x==9)   web_bi_l0_p2 <= 1;  
      else if(cnt >= 17)    web_bi_l0_p2 <= 0;
    end
    else web_bi_l0_p2 <= 1;
end
//------------ input ---------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) L0_p2_BiSRAM_in <= 0;
    // if(c_s == S0_IDLE) L0_p2_BiSRAM_in <= 0;
    else if(c_s == S4_CAL_BI_p2)begin
      L0_p2_BiSRAM_in <= bi_l0_p2;
    end
  end

//================================================================
//               Bi SRAM L1 p2
//================================================================
//------ address -------------------------------------------
// assign addres_bi_p2_l1 = {Bi_L1_p2_addr_y, Bi_L1_p2_addr_x};
assign addres_bi_p2_l1 = Bi_L1_p2_addr_y * 10 + Bi_L1_p2_addr_x;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L1_p2_addr_x <= 0;
    end
    else if (c_s==S4_CAL_BI_p2 && cnt>=18) begin
      if(Bi_L1_p2_addr_x==10) Bi_L1_p2_addr_x <= 0;
      else Bi_L1_p2_addr_x <= Bi_L1_p2_addr_x+1;
    end
    else if (c_s == S5_SAD) begin
        Bi_L1_p2_addr_x <= 2 + count_pointer_sad_x - count_start_sad_y;
        // if (count_start_sad_y == 8) Bi_L1_p2_addr_x <= 0;
        // else Bi_L1_p2_addr_x <= 2 + count_pointer_sad_x - count_start_sad_y;
    end
    else if (c_s == S6_OUT) begin
        Bi_L1_p2_addr_x <= 0;
    end
    else Bi_L1_p2_addr_x <= Bi_L1_p2_addr_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Bi_L1_p2_addr_y <= 0;
    end
    else if (c_s==S4_CAL_BI_p2 && cnt>=18) begin
      if(Bi_L1_p2_addr_x==9) Bi_L1_p2_addr_y <= Bi_L1_p2_addr_y+1;
      else Bi_L1_p2_addr_y <= Bi_L1_p2_addr_y;
    end
    else if (c_s == S5_SAD) begin
        Bi_L1_p2_addr_y <= 2 + count_pointer_sad_y - count_start_sad_x;
        // if (count_start_sad_y == 8) Bi_L1_p2_addr_y <= 0;
        // else Bi_L1_p2_addr_y <= 2 + count_pointer_sad_y - count_start_sad_x;
    end
    else if (c_s == S6_OUT) begin
        Bi_L1_p2_addr_y <= 0;
    end
    else Bi_L1_p2_addr_y <= Bi_L1_p2_addr_y;
end

//--------- WEB --------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_bi_l1_p2 <= 1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if (Bi_L1_p2_addr_x==9)   web_bi_l1_p2 <= 1;  
      else if(cnt >= 17)    web_bi_l1_p2 <= 0;
    end
    else web_bi_l1_p2 <= 1;
end
//------------ input ---------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) L1_p2_BiSRAM_in <= 0;
    // if(c_s == S0_IDLE) L1_p2_BiSRAM_in <= 0;
    else if(c_s == S4_CAL_BI_p2)begin
      L1_p2_BiSRAM_in <= bi_l1_p2;
    end
  end


//================================================================
//              SRAM for L0, L1
//================================================================

//------- Counter for L0 address ------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_in_x <= 0;    
    end
    // wirte data to sram at in_valid == 1
    else if (in_valid_d) begin
        count_in_x <= count_in_x + 1;
    end
    // read data at c_s == S3_CAL_BI
    else if (c_s == S3_CAL_BI) begin
        if(cnt==129) count_in_x <= motion_reg[4][11:4];
        else         count_in_x <= motion_reg[0][11:4] + count_bi;
    end
    // read data at c_s == S4_CAL_BI_p2
    else if (c_s == S4_CAL_BI_p2) begin
        count_in_x <= motion_reg[4][11:4] + count_bi;
    end
    else count_in_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_in_y <= 0;    
    end
    // wirte data to sram at in_valid == 1
    else if (in_valid_d) begin
        if (count_in_x == 127) count_in_y <= count_in_y + 1;
        else count_in_y <= count_in_y;
    end
    else if (c_s == S3_CAL_BI) begin
        if(cnt==129) count_in_y <= motion_reg[5][11:4];
        else         count_in_y <= motion_reg[1][11:4] + count_bi_y;
    end
    // read data at c_s == S4_CAL_BI_p2
    else if (c_s == S4_CAL_BI_p2) begin
        count_in_y <= motion_reg[5][11:4] + count_bi_y;
    end
    else count_in_y <= 0;
end
//-------- ADDRESS -------------------------
assign addres = {count_in_y, count_in_x};

//-------- WEB -----------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_input_l0 <= 1;
    end
    else if (in_valid && !in_valid_d) begin
        web_input_l0 <= 0;
    end
    else if (in_valid) begin
        if (count_in_x == 127 && count_in_y == 127) begin
            web_input_l0 <= 1;
        end
        else web_input_l0 <= web_input_l0;
    end
    else web_input_l0 <= 1;
end
// L0 part
//=====================================================================
// L1 part
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_in_x_l1 <= 0;    
    end
    // wirte data to sram at in_valid == 1
    else if (in_valid_d) begin
        count_in_x_l1 <= count_in_x_l1 + 1;
    end
    else if (c_s == S3_CAL_BI) begin
        count_in_x_l1 <= motion_reg[2][11:4] + count_bi;
    end
    else if (c_s == S4_CAL_BI_p2) begin
        count_in_x_l1 <= motion_reg[6][11:4] + count_bi;
    end
    else count_in_x_l1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_in_y_l1 <= 0;    
    end
    // wirte data to sram at in_valid == 1
    else if (in_valid_d) begin
        if (count_in_x_l1 == 127) count_in_y_l1 <= count_in_y_l1 + 1;
        else count_in_y_l1 <= count_in_y_l1;
    end
    else if (c_s == S3_CAL_BI) begin
        count_in_y_l1 <= motion_reg[3][11:4] + count_bi_y;
    end
    else if (c_s == S4_CAL_BI_p2) begin
        count_in_y_l1 <= motion_reg[7][11:4] + count_bi_y;
    end
    else count_in_y_l1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        web_input_l1 <= 1;
    end
    else if (in_valid && !in_valid_d) begin
        web_input_l1 <= 1;
    end
    else if (in_valid) begin
        if (count_in_x == 127 && count_in_y == 127) begin
            web_input_l1 <= 0;
        end
        else web_input_l1 <= web_input_l1;
    end
    else web_input_l1 <= 1;
end
assign addres_1 = {count_in_y_l1, count_in_x_l1};



//=================================================
//              fraction 
//=================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_xy_point_1_l0 <= 0;
    end
    else if (c_s == S2_LOAD_MV) begin
        fraction_xy_point_1_l0 <= motion_reg[0][3:0] * motion_reg[1][3:0];
    end
    else fraction_xy_point_1_l0 <= fraction_xy_point_1_l0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_x_point_1_l0 <= 0;
    end
    else if (c_s == S2_LOAD_MV) begin
        fraction_x_point_1_l0 <= {motion_reg[0][3:0],4'b0};
    end
    else fraction_x_point_1_l0 <= fraction_x_point_1_l0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_y_point_1_l0 <= 0;
    end
    else if (c_s == S2_LOAD_MV) begin
        fraction_y_point_1_l0 <= {motion_reg[1][3:0],4'b0};
    end
    else fraction_y_point_1_l0 <= fraction_y_point_1_l0;
end



always @(posedge clk or negedge rst_n) begin //fraction_xy_point_1_l1
    if (!rst_n) begin
        fraction_xy_point_1_l1 <= 0;
    end
    else if (c_s == S2_LOAD_MV || c_s == S3_CAL_BI) begin
        fraction_xy_point_1_l1 <= motion_reg[2][3:0] * motion_reg[3][3:0];
    end
    else fraction_xy_point_1_l1 <= fraction_xy_point_1_l1;
end

always @(posedge clk or negedge rst_n) begin //fraction_x_point_1_l1
    if (!rst_n) begin
        fraction_x_point_1_l1 <= 0;
    end
    else if (c_s == S2_LOAD_MV) begin
        fraction_x_point_1_l1 <= {motion_reg[2][3:0],4'b0};
    end
    else fraction_x_point_1_l1 <= fraction_x_point_1_l1;
end

always @(posedge clk or negedge rst_n) begin //fraction_y_point_1_l1
    if (!rst_n) begin
        fraction_y_point_1_l1 <= 0;
    end
    else if (c_s == S2_LOAD_MV || c_s == S3_CAL_BI) begin
        fraction_y_point_1_l1 <= {motion_reg[3][3:0],4'b0};
    end
    else fraction_y_point_1_l1 <= fraction_y_point_1_l1;
end

always @(posedge clk or negedge rst_n) begin //fraction_xy_point_2_l0
    if (!rst_n) begin
        fraction_xy_point_2_l0 <= 0;
    end
    else if (c_s == S2_LOAD_MV || c_s == S3_CAL_BI) begin
        fraction_xy_point_2_l0 <= motion_reg[4][3:0] * motion_reg[5][3:0];
    end
    else fraction_xy_point_2_l0 <= fraction_xy_point_2_l0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_x_point_2_l0 <= 0;
    end
    else if (c_s == S2_LOAD_MV || c_s == S3_CAL_BI) begin
        fraction_x_point_2_l0 <= {motion_reg[4][3:0],4'b0};
    end
    else fraction_x_point_2_l0 <= fraction_x_point_2_l0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_y_point_2_l0 <= 0;
    end
    else if (c_s == S2_LOAD_MV || c_s == S3_CAL_BI) begin
        fraction_y_point_2_l0 <= {motion_reg[5][3:0],4'b0};
    end
    else fraction_y_point_2_l0 <= fraction_y_point_2_l0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_xy_point_2_l1 <= 0;
    end
    else if (c_s == S2_LOAD_MV || c_s == S3_CAL_BI) begin
        fraction_xy_point_2_l1 <= motion_reg[6][3:0] * motion_reg[7][3:0];
    end    
    else fraction_xy_point_2_l1 <= fraction_xy_point_2_l1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_x_point_2_l1 <= 0;
    end
    else fraction_x_point_2_l1 <= {motion_reg[6][3:0],4'b0};
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fraction_y_point_2_l1 <= 0;
    end
    else fraction_y_point_2_l1 <= {motion_reg[7][3:0],4'b0};
end

assign p0_l0_point1 = 256 - fraction_y_point_1_l0 - fraction_x_point_1_l0 + fraction_xy_point_1_l0;
assign p1_l0_point1 = fraction_x_point_1_l0 - fraction_xy_point_1_l0;
assign p2_l0_point1 = fraction_y_point_1_l0 - fraction_xy_point_1_l0;
assign p3_l0_point1 = fraction_xy_point_1_l0;

assign p0_l0_point2 = 256 - fraction_y_point_2_l0 - fraction_x_point_2_l0 + fraction_xy_point_2_l0;
assign p1_l0_point2 = fraction_x_point_2_l0 - fraction_xy_point_2_l0;
assign p2_l0_point2 = fraction_y_point_2_l0 - fraction_xy_point_2_l0;
assign p3_l0_point2 = fraction_xy_point_2_l0;

assign p0_l1_point1 = 256 - fraction_y_point_1_l1 - fraction_x_point_1_l1 + fraction_xy_point_1_l1;
assign p1_l1_point1 = fraction_x_point_1_l1 - fraction_xy_point_1_l1;
assign p2_l1_point1 = fraction_y_point_1_l1 - fraction_xy_point_1_l1;
assign p3_l1_point1 = fraction_xy_point_1_l1;

assign p0_l1_point2 = 256 - fraction_y_point_2_l1 - fraction_x_point_2_l1 + fraction_xy_point_2_l1;
assign p1_l1_point2 = fraction_x_point_2_l1 - fraction_xy_point_2_l1;
assign p2_l1_point2 = fraction_y_point_2_l1 - fraction_xy_point_2_l1;
assign p3_l1_point2 = fraction_xy_point_2_l1;



// ---------- in_valid2 ----------
// ----------c_s == S3_CAL_BI-------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_bi <= 0;
    end
    else if (c_s == S3_CAL_BI && n_s == S4_CAL_BI_p2) begin
        count_bi <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
        if (count_bi == 10) count_bi <= 0;
        else count_bi <= count_bi + 1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
        if (count_bi == 10) count_bi <= 0;
        else count_bi <= count_bi + 1;
    end
    else if (c_s == S6_OUT) begin
        count_bi <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_bi_y <= 0;
    end
    else if (c_s == S3_CAL_BI && n_s == S4_CAL_BI_p2) begin
        count_bi_y <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
        if (count_bi == 10) count_bi_y <= count_bi_y + 1;
        else count_bi_y <= count_bi_y;
    end
    else if (c_s == S4_CAL_BI_p2) begin
        if (count_bi == 10) count_bi_y <= count_bi_y + 1;
        else count_bi_y <= count_bi_y;
    end
    else if (c_s == S6_OUT) begin
        count_bi_y <= 0;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        l1_data_point1 <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
        if (count_bi < 2 && count_bi_y == 0) l1_data_point1 <= 0;
        else l1_data_point1 <= in_data_out_l1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
        if (count_bi < 2 && count_bi_y == 0) l1_data_point1 <= 0;
        else l1_data_point1 <= in_data_out_l1;
    end
    else l1_data_point1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_Lmat_x <= 0;
    end
    else if (c_s == S3_CAL_BI && n_s == S4_CAL_BI_p2) begin
        cnt_Lmat_x <= 0;
    end
    else if (c_s == S3_CAL_BI && cnt>=6) begin
        if (cnt_Lmat_x == 10) cnt_Lmat_x <= 0;
        else cnt_Lmat_x <= cnt_Lmat_x + 1;
    end
    else if (c_s == S4_CAL_BI_p2 && cnt>=2) begin
        if (cnt_Lmat_x == 10) cnt_Lmat_x <= 0;
        else cnt_Lmat_x <= cnt_Lmat_x + 1;
    end
    else if (c_s == S6_OUT) begin
        cnt_Lmat_x <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_Lmat_y <= 0;
    end
    else if (c_s == S3_CAL_BI && n_s == S4_CAL_BI_p2) begin
        cnt_Lmat_y <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
        if (cnt_Lmat_x == 10) cnt_Lmat_y <= ~cnt_Lmat_y;
        else cnt_Lmat_y <= cnt_Lmat_y;
    end
    else if (c_s == S4_CAL_BI_p2) begin
        if (cnt_Lmat_x == 10) cnt_Lmat_y <= ~cnt_Lmat_y;
        else cnt_Lmat_y <= cnt_Lmat_y;
    end
    else if (c_s == S6_OUT) begin
        cnt_Lmat_y <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1) begin
            for (j = 0; j < 11 ; j = j + 1 ) begin
                l0_data_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S3_CAL_BI) begin
      if(cnt>=28) begin
        l0_data_max[0][cnt_Lmat_x] <= l0_data_max[1][cnt_Lmat_x];
        l0_data_max[1][cnt_Lmat_x] <= in_data_out_l0;
      end
      else begin
        l0_data_max[cnt_Lmat_y][cnt_Lmat_x] <= in_data_out_l0;        
      end
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(cnt>=24) begin
        l0_data_max[0][cnt_Lmat_x] <= l0_data_max[1][cnt_Lmat_x];
        l0_data_max[1][cnt_Lmat_x] <= in_data_out_l0;
      end
      else begin
        l0_data_max[cnt_Lmat_y][cnt_Lmat_x] <= in_data_out_l0;        
      end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 2 ; i = i + 1) begin
            for (j = 0; j < 11 ; j = j + 1 ) begin
                l1_data_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S3_CAL_BI) begin
      if(cnt>=28) begin
        l1_data_max[0][cnt_Lmat_x] <= l1_data_max[1][cnt_Lmat_x];
        l1_data_max[1][cnt_Lmat_x] <= in_data_out_l1;
      end
      else begin
        l1_data_max[cnt_Lmat_y][cnt_Lmat_x] <= in_data_out_l1;        
      end
    end    
    else if (c_s == S4_CAL_BI_p2) begin
      if(cnt>=24) begin
        l1_data_max[0][cnt_Lmat_x] <= l1_data_max[1][cnt_Lmat_x];
        l1_data_max[1][cnt_Lmat_x] <= in_data_out_l1;
      end
      else begin
        l1_data_max[cnt_Lmat_y][cnt_Lmat_x] <= in_data_out_l1;        
      end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_pointer_x <= 0;
    end
    else if (c_s == S3_CAL_BI && n_s == S4_CAL_BI_p2) begin
        count_pointer_x <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
        if (cnt_Lmat_x == 2 && cnt_Lmat_y == 1) begin
            count_pointer_x <= 0;
        end
        else begin
            if (count_pointer_x == 10) begin
                count_pointer_x <= 0;
            end
            else count_pointer_x <= count_pointer_x + 1;
        end
    end
    else if (c_s == S4_CAL_BI_p2) begin
        if (cnt_Lmat_x == 2 && cnt_Lmat_y == 1) begin
            count_pointer_x <= 0;
        end
        else begin
            if (count_pointer_x == 10) begin
                count_pointer_x <= 0;
            end
            else count_pointer_x <= count_pointer_x + 1;
        end
    end
    else if (c_s == S6_OUT) begin
        count_pointer_x <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_pointer_y <= 0;
    end
    else if (c_s == S3_CAL_BI && n_s == S4_CAL_BI_p2) begin
        count_pointer_y <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
        if (cnt_Lmat_x == 2 && cnt_Lmat_y == 1) begin
            count_pointer_y <= 0;
        end
        else begin
            if (count_pointer_x == 10) begin
                count_pointer_y <= count_pointer_y + 1;
            end
            else count_pointer_y <= count_pointer_y;
        end
    end
    else if (c_s == S4_CAL_BI_p2) begin
        if (cnt_Lmat_x == 2 && cnt_Lmat_y == 1) begin
            count_pointer_y <= 0;
        end
        else begin
            if (count_pointer_x == 10) begin
                count_pointer_y <= count_pointer_y + 1;
            end
            else count_pointer_y <= count_pointer_y;
        end
    end
    else if (c_s == S6_OUT) begin
        count_pointer_y <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p0_bi <= 0;
    end
    // point1 l0
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p0_bi <= 0;
      else   p0_bi <= l0_data_max[0][count_pointer_x] * p0_l0_point1;
    end
    // point2 l0
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p0_bi <= 0;
      else   p0_bi <= l0_data_max[0][count_pointer_x] * p0_l0_point2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p1_bi <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p1_bi <= 0;
      else   p1_bi <= l0_data_max[0][count_pointer_x + 1] * p1_l0_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p1_bi <= 0;
      else   p1_bi <= l0_data_max[0][count_pointer_x + 1] * p1_l0_point2;
    end

end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p2_bi <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p2_bi <= 0;
      else   p2_bi <= l0_data_max[0 + 1][count_pointer_x] * p2_l0_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p2_bi <= 0;
      else   p2_bi <= l0_data_max[0 + 1][count_pointer_x] * p2_l0_point2;
    end
    
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p3_bi <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p3_bi <= 0;
      else  p3_bi <= l0_data_max[0 + 1][count_pointer_x + 1] * p3_l0_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p3_bi <= 0;
      else  p3_bi <= l0_data_max[0 + 1][count_pointer_x + 1] * p3_l0_point2;
    end

end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p0_bi_l1 <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p0_bi_l1 <= 0;
      else   p0_bi_l1 <= l1_data_max[0][count_pointer_x] * p0_l1_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p0_bi_l1 <= 0;
      else   p0_bi_l1 <= l1_data_max[0][count_pointer_x] * p0_l1_point2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p1_bi_l1 <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p1_bi_l1 <= 0;
      else   p1_bi_l1 <= l1_data_max[0][count_pointer_x + 1] * p1_l1_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p1_bi_l1 <= 0;
      else   p1_bi_l1 <= l1_data_max[0][count_pointer_x + 1] * p1_l1_point2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p2_bi_l1 <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p2_bi_l1 <= 0;
      else   p2_bi_l1 <= l1_data_max[1][count_pointer_x] * p2_l1_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p2_bi_l1 <= 0;
      else   p2_bi_l1 <= l1_data_max[1][count_pointer_x] * p2_l1_point2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        p3_bi_l1 <= 0;
    end
    else if (c_s == S3_CAL_BI) begin
      if(count_pointer_x==10) p3_bi_l1 <= 0;
      else  p3_bi_l1 <= l1_data_max[1][count_pointer_x + 1] * p3_l1_point1;
    end
    else if (c_s == S4_CAL_BI_p2) begin
      if(count_pointer_x==10) p3_bi_l1 <= 0;
      else  p3_bi_l1 <= l1_data_max[1][count_pointer_x + 1] * p3_l1_point2;
    end
end

assign bi_l0    = p0_bi + p1_bi + p2_bi + p3_bi;
assign bi_l0_p2 = p0_bi + p1_bi + p2_bi + p3_bi;
assign bi_l1    = p0_bi_l1 + p1_bi_l1 + p2_bi_l1 + p3_bi_l1;
assign bi_l1_p2 = p0_bi_l1 + p1_bi_l1 + p2_bi_l1 + p3_bi_l1;




always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_bi_p2_x <= 0;
    end
    else count_bi_p2_x <= count_pointer_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_bi_p2_y <= 0;
    end
    else count_bi_p2_y <= count_pointer_y;
end







always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_bi_p2_x_l1 <= 0;
    end
    else count_bi_p2_x_l1 <= count_pointer_x;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_bi_p2_y_l1 <= 0;
    end
    else count_bi_p2_y_l1 <= count_pointer_y;
end

//================================================================
//                STATE SAD
//================================================================
// --------c_s == S5_SAD-----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_pointer_sad_x <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 7)count_pointer_sad_x <= 0;
        else if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) count_pointer_sad_x <= 0;
        else if (count_pointer_sad_x == 7 && count_pointer_sad_y == 7) count_pointer_sad_x <= 0;
        else count_pointer_sad_x <= count_pointer_sad_x + 1;
    end
    else if (c_s == S2_LOAD_MV) begin
        count_pointer_sad_x <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_pointer_sad_y <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 7)count_pointer_sad_y <= count_pointer_sad_y + 1;
        else if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) count_pointer_sad_y <= 0;
        else if (count_pointer_sad_x == 7 && count_pointer_sad_y == 7) count_pointer_sad_y <= 0;
        else count_pointer_sad_y <= count_pointer_sad_y;
    end
    else if (c_s == S2_LOAD_MV) begin
        count_pointer_sad_y <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_start_sad_x <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 1 && count_pointer_sad_y == 8 && count_start_sad_x == 2) count_start_sad_x <= 0;
        else if (count_pointer_sad_x == 1 && count_pointer_sad_y == 8) count_start_sad_x <= count_start_sad_x + 1;
        else count_start_sad_x <= count_start_sad_x;
    end
    else if (c_s == S2_LOAD_MV) begin
        count_start_sad_x <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_start_sad_y <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 1 && count_pointer_sad_y == 8 && count_start_sad_x == 2) count_start_sad_y <= count_start_sad_y + 1;
        else count_start_sad_y <= count_start_sad_y;
    end
    else if (c_s == S2_LOAD_MV) begin
        count_start_sad_y <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        l0_data_sad_p1 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x < 2 && count_pointer_sad_y == 0) l0_data_sad_p1 <= 0;
        else if (count_pointer_sad_x < 5 && count_pointer_sad_y == 8 && count_pointer_sad_x > 1) l0_data_sad_p1 <= 0;
        else l0_data_sad_p1 <= bi_l0_p1_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        l1_data_sad_p1 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x < 2 && count_pointer_sad_y == 0) l1_data_sad_p1 <= 0;
        else if (count_pointer_sad_x < 5 && count_pointer_sad_y == 8 && count_pointer_sad_x > 1) l1_data_sad_p1 <= 0;
        else l1_data_sad_p1 <= bi_l1_p1_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sad_point1 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (l0_data_sad_p1 > l1_data_sad_p1) begin
            sad_point1 <= l0_data_sad_p1 - l1_data_sad_p1;
        end
        else sad_point1 <= l1_data_sad_p1 - l0_data_sad_p1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sad_sum_point1 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) sad_sum_point1 <= 0;
        else sad_sum_point1 <= sad_sum_point1 + sad_point1;
    end
end
// point2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        l0_data_sad_p2 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x < 2 && count_pointer_sad_y == 0) l0_data_sad_p2 <= 0;
        else if (count_pointer_sad_x < 5 && count_pointer_sad_y == 8 && count_pointer_sad_x > 1) l0_data_sad_p2 <= 0;
        else l0_data_sad_p2 <= bi_l0_p2_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        l1_data_sad_p2 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x < 2 && count_pointer_sad_y == 0) l1_data_sad_p2 <= 0;
        else if (count_pointer_sad_x < 5 && count_pointer_sad_y == 8 && count_pointer_sad_x > 1) l1_data_sad_p2 <= 0;
        else l1_data_sad_p2 <= bi_l1_p2_out;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sad_point2 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (l0_data_sad_p2 > l1_data_sad_p2) begin
            sad_point2 <= l0_data_sad_p2 - l1_data_sad_p2;
        end
        else sad_point2 <= l1_data_sad_p2 - l0_data_sad_p2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sad_sum_point2 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) sad_sum_point2 <= 0;
        else sad_sum_point2 <= sad_sum_point2 + sad_point2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_sad <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8 && c_s == S5_SAD) begin
            count_sad <= count_sad + 1;
        end
        else count_sad <= count_sad;
    end
    else if (c_s == S2_LOAD_MV) begin
        count_sad <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_sad_d <= 0;
    end
    else count_sad_d <= count_sad;
end

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_sad_reg_point1 <= 0;
//     end
//     else if (c_s == S5_SAD) begin
//         if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) begin
//             out_sad_reg_point1 <= {count_sad ,sad_sum_point1[23:0]};
//         end
//         else out_sad_reg_point1 <= out_sad_reg_point1;
//     end
// end

// always @(posedge clk) begin
//     if (c_s == S5_SAD) begin
//         out_sad_reg_point1_max[count_sad_d] <= out_sad_reg_point1;
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        compare_reg_p1 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) begin
            compare_reg_p1 <= {count_sad ,sad_sum_point1[23:0]};
        end
        else compare_reg_p1 <= compare_reg_p1;
    end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n)  min_value_p1 <= 0;
  else if(c_s==S2_LOAD_MV)                                min_value_p1 <= 'hfffffff;
  else if(count_pointer_sad_y == 0 && count_sad!=0 && c_s == S5_SAD && count_sad!=10)begin
    if(min_value_p1[23:0] > compare_reg_p1[23:0])    min_value_p1 <= compare_reg_p1;
  end
  else                                               min_value_p1 <= min_value_p1;
end

// always @(*) begin
//     min_value_p1 = out_sad_reg_point1_max[0];

//     for (g = 0; g < 9; g = g + 1) begin
// 		if (out_sad_reg_point1_max[g][23:0] < min_value_p1[23:0]) begin
// 			min_value_p1 = out_sad_reg_point1_max[g];
// 		end
// 	end
// end

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_sad_reg_point2 <= 0;
//     end
//     else if (c_s == S5_SAD) begin
//         if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) begin
//             out_sad_reg_point2 <= {count_sad ,sad_sum_point2[23:0]};
//         end
//         else out_sad_reg_point2 <= out_sad_reg_point2;
//     end
// end

// always @(posedge clk) begin
//     if (c_s == S5_SAD) begin
//         out_sad_reg_point2_max[count_sad_d] <= out_sad_reg_point2;
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        compare_reg_p2 <= 0;
    end
    else if (c_s == S5_SAD) begin
        if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) begin
            compare_reg_p2 <= {count_sad ,sad_sum_point2[23:0]};
        end
        else compare_reg_p2 <= compare_reg_p2;
    end
end


// always @(posedge clk) begin
//     if (count_pointer_sad_x == 4 && count_pointer_sad_y == 8) begin
//         compare_reg_p2 <= {count_sad ,sad_sum_point2[23:0]};
//     end
// end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)  min_value_p2  <= 0;
  else if(c_s==S2_LOAD_MV)                                min_value_p2 <= 'hfffffff;
//   else if(min_value_p2[23:0] > compare_reg_p2[23:0]) min_value_p2 <= compare_reg_p2;
  else if(count_pointer_sad_y == 0 && count_sad!=0 && c_s == S5_SAD && count_sad!=10)begin
    if(min_value_p2[23:0] > compare_reg_p2[23:0]) min_value_p2 <= compare_reg_p2;
  end
  else                                               min_value_p2 <= min_value_p2;
end

// always @(*) begin
//     min_value_p2 = out_sad_reg_point2_max[0];

//     for (g = 0; g < 9; g = g + 1) begin
// 		if (out_sad_reg_point2_max[g][23:0] < min_value_p2[23:0]) begin
// 			min_value_p2 = out_sad_reg_point2_max[g];
// 		end
// 	end
// end


assign out_sad_data = {min_value_p2, min_value_p1};

// --------c_s == S5_SAD-----------


//================================================================
//                OUTPUT
//================================================================
//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_valid <= 0;
//     end
//     else out_valid <= out_valid;
//   end

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_sad <= 0;
//     end
//     else out_sad <= out_sad;
//   end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_out <= 0;
    end
    else if (c_s == S6_OUT) begin
        count_out <= count_out + 1;
    end
    else count_out <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (c_s == S6_OUT) begin
        if (count_out == 56) out_valid <= 0;
        else out_valid <= 1;
    end
    else out_valid <= out_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_sad <= 0;
    end
    else if (c_s == S6_OUT) begin
        if (count_out == 56) out_sad <= 0;
        else out_sad <= out_sad_data[count_out];
    end
    else out_sad <= 0;
end


//================================================================
//              Call SRAM 
//================================================================
  SUMA180_16384X8X1BM8 L0SRAM    (.A0  (addres[0]),
                                .A1  (addres[1]),
                                .A2  (addres[2]),
                                .A3  (addres[3]),
                                .A4  (addres[4]),
                                .A5  (addres[5]),
                                .A6  (addres[6]),

                                .A7  (addres[7]),
                                .A8  (addres[8]),
                                .A9  (addres[9]),
                                .A10 (addres[10]),
                                .A11 (addres[11]),
                                .A12 (addres[12]),
                                .A13 (addres[13]),

                                .DO0 (in_data_out_l0[0]),
                                .DO1 (in_data_out_l0[1]),
                                .DO2 (in_data_out_l0[2]),
                                .DO3 (in_data_out_l0[3]),
                                .DO4 (in_data_out_l0[4]),
                                .DO5 (in_data_out_l0[5]),
                                .DO6 (in_data_out_l0[6]),
                                .DO7 (in_data_out_l0[7]),

                                .DI0 (in_data_d[0]),
                                .DI1 (in_data_d[1]),
                                .DI2 (in_data_d[2]),
                                .DI3 (in_data_d[3]),
                                .DI4 (in_data_d[4]),
                                .DI5 (in_data_d[5]),
                                .DI6 (in_data_d[6]),
                                .DI7 (in_data_d[7]),

                                .CK  (clk),
                                .WEB (web_input_l0),
                                .OE  (1'b1), 
                                .CS  (1'b1));

  SUMA180_16384X8X1BM8 L1SRAM    (.A0  (addres_1[0]),
                                .A1  (addres_1[1]),
                                .A2  (addres_1[2]),
                                .A3  (addres_1[3]),
                                .A4  (addres_1[4]),
                                .A5  (addres_1[5]),
                                .A6  (addres_1[6]),

                                .A7  (addres_1[7]),
                                .A8  (addres_1[8]),
                                .A9  (addres_1[9]),
                                .A10 (addres_1[10]),
                                .A11 (addres_1[11]),
                                .A12 (addres_1[12]),
                                .A13 (addres_1[13]),

                                .DO0 (in_data_out_l1[0]),
                                .DO1 (in_data_out_l1[1]),
                                .DO2 (in_data_out_l1[2]),
                                .DO3 (in_data_out_l1[3]),
                                .DO4 (in_data_out_l1[4]),
                                .DO5 (in_data_out_l1[5]),
                                .DO6 (in_data_out_l1[6]),
                                .DO7 (in_data_out_l1[7]),

                                .DI0 (in_data_d[0]),
                                .DI1 (in_data_d[1]),
                                .DI2 (in_data_d[2]),
                                .DI3 (in_data_d[3]),
                                .DI4 (in_data_d[4]),
                                .DI5 (in_data_d[5]),
                                .DI6 (in_data_d[6]),
                                .DI7 (in_data_d[7]),

                                .CK  (clk),
                                .WEB (web_input_l1),
                                .OE  (1'b1), 
                                .CS  (1'b1));
  // SRAM for Bi point1 L0 {countter_y[0-9],counter_x[0-9]}
  SUMA180_128X16X1BM1 Bi_l0_p1_SRAM    (.A0  (addres_bi_p1_l0[0]),
                                      .A1  (addres_bi_p1_l0[1]),
                                      .A2  (addres_bi_p1_l0[2]),
                                      .A3  (addres_bi_p1_l0[3]),

                                      .A4  (addres_bi_p1_l0[4]),
                                      .A5  (addres_bi_p1_l0[5]),
                                      .A6  (addres_bi_p1_l0[6]),
      
                                      .DO0  (bi_l0_p1_out[0]),
                                      .DO1  (bi_l0_p1_out[1]),
                                      .DO2  (bi_l0_p1_out[2]),
                                      .DO3  (bi_l0_p1_out[3]),
                                      .DO4  (bi_l0_p1_out[4]),
                                      .DO5  (bi_l0_p1_out[5]),
                                      .DO6  (bi_l0_p1_out[6]),
                                      .DO7  (bi_l0_p1_out[7]),
                                      .DO8  (bi_l0_p1_out[8]),
                                      .DO9  (bi_l0_p1_out[9]),
                                      .DO10 (bi_l0_p1_out[10]),
                                      .DO11 (bi_l0_p1_out[11]),
                                      .DO12 (bi_l0_p1_out[12]),
                                      .DO13 (bi_l0_p1_out[13]),
                                      .DO14 (bi_l0_p1_out[14]),
                                      .DO15 (bi_l0_p1_out[15]),
      
                                      .DI0  (L0_p1_BiSRAM_in[0]),
                                      .DI1  (L0_p1_BiSRAM_in[1]),
                                      .DI2  (L0_p1_BiSRAM_in[2]),
                                      .DI3  (L0_p1_BiSRAM_in[3]),
                                      .DI4  (L0_p1_BiSRAM_in[4]),
                                      .DI5  (L0_p1_BiSRAM_in[5]),
                                      .DI6  (L0_p1_BiSRAM_in[6]),
                                      .DI7  (L0_p1_BiSRAM_in[7]),
                                      .DI8  (L0_p1_BiSRAM_in[8]),
                                      .DI9  (L0_p1_BiSRAM_in[9]),
                                      .DI10 (L0_p1_BiSRAM_in[10]),
                                      .DI11 (L0_p1_BiSRAM_in[11]),
                                      .DI12 (L0_p1_BiSRAM_in[12]),
                                      .DI13 (L0_p1_BiSRAM_in[13]),
                                      .DI14 (L0_p1_BiSRAM_in[14]),
                                      .DI15 (L0_p1_BiSRAM_in[15]),

                                      .CK  (clk),
                                      .WEB (web_bi_l0_p1),
                                      .OE  (1'b1), 
                                      .CS  (1'b1));
  // SRAM for Bi point1 L1
  SUMA180_128X16X1BM1 Bi_l1_p1_SRAM    (.A0  (addres_bi_p1_l1[0]),
                                      .A1  (addres_bi_p1_l1[1]),
                                      .A2  (addres_bi_p1_l1[2]),
                                      .A3  (addres_bi_p1_l1[3]),

                                      .A4  (addres_bi_p1_l1[4]),
                                      .A5  (addres_bi_p1_l1[5]),
                                      .A6  (addres_bi_p1_l1[6]),
      
                                      .DO0  (bi_l1_p1_out[0]),
                                      .DO1  (bi_l1_p1_out[1]),
                                      .DO2  (bi_l1_p1_out[2]),
                                      .DO3  (bi_l1_p1_out[3]),
                                      .DO4  (bi_l1_p1_out[4]),
                                      .DO5  (bi_l1_p1_out[5]),
                                      .DO6  (bi_l1_p1_out[6]),
                                      .DO7  (bi_l1_p1_out[7]),
                                      .DO8  (bi_l1_p1_out[8]),
                                      .DO9  (bi_l1_p1_out[9]),
                                      .DO10 (bi_l1_p1_out[10]),
                                      .DO11 (bi_l1_p1_out[11]),
                                      .DO12 (bi_l1_p1_out[12]),
                                      .DO13 (bi_l1_p1_out[13]),
                                      .DO14 (bi_l1_p1_out[14]),
                                      .DO15 (bi_l1_p1_out[15]),
      
                                      .DI0  (L1_p1_BiSRAM_in[0]),
                                      .DI1  (L1_p1_BiSRAM_in[1]),
                                      .DI2  (L1_p1_BiSRAM_in[2]),
                                      .DI3  (L1_p1_BiSRAM_in[3]),
                                      .DI4  (L1_p1_BiSRAM_in[4]),
                                      .DI5  (L1_p1_BiSRAM_in[5]),
                                      .DI6  (L1_p1_BiSRAM_in[6]),
                                      .DI7  (L1_p1_BiSRAM_in[7]),
                                      .DI8  (L1_p1_BiSRAM_in[8]),
                                      .DI9  (L1_p1_BiSRAM_in[9]),
                                      .DI10 (L1_p1_BiSRAM_in[10]),
                                      .DI11 (L1_p1_BiSRAM_in[11]),
                                      .DI12 (L1_p1_BiSRAM_in[12]),
                                      .DI13 (L1_p1_BiSRAM_in[13]),
                                      .DI14 (L1_p1_BiSRAM_in[14]),
                                      .DI15 (L1_p1_BiSRAM_in[15]),

                                      .CK  (clk),
                                      .WEB (web_bi_l1_p1),
                                      .OE  (1'b1), 
                                      .CS  (1'b1));
  // SRAM for Bi point2 L0        
  SUMA180_128X16X1BM1 Bi_l0_p2_SRAM    (.A0  (addres_bi_p2_l0[0]),
                                      .A1  (addres_bi_p2_l0[1]),
                                      .A2  (addres_bi_p2_l0[2]),
                                      .A3  (addres_bi_p2_l0[3]),

                                      .A4  (addres_bi_p2_l0[4]),
                                      .A5  (addres_bi_p2_l0[5]),
                                      .A6  (addres_bi_p2_l0[6]),
      
                                      .DO0  (bi_l0_p2_out[0]),
                                      .DO1  (bi_l0_p2_out[1]),
                                      .DO2  (bi_l0_p2_out[2]),
                                      .DO3  (bi_l0_p2_out[3]),
                                      .DO4  (bi_l0_p2_out[4]),
                                      .DO5  (bi_l0_p2_out[5]),
                                      .DO6  (bi_l0_p2_out[6]),
                                      .DO7  (bi_l0_p2_out[7]),
                                      .DO8  (bi_l0_p2_out[8]),
                                      .DO9  (bi_l0_p2_out[9]),
                                      .DO10 (bi_l0_p2_out[10]),
                                      .DO11 (bi_l0_p2_out[11]),
                                      .DO12 (bi_l0_p2_out[12]),
                                      .DO13 (bi_l0_p2_out[13]),
                                      .DO14 (bi_l0_p2_out[14]),
                                      .DO15 (bi_l0_p2_out[15]),
      
                                      .DI0  (L0_p2_BiSRAM_in[0]),
                                      .DI1  (L0_p2_BiSRAM_in[1]),
                                      .DI2  (L0_p2_BiSRAM_in[2]),
                                      .DI3  (L0_p2_BiSRAM_in[3]),
                                      .DI4  (L0_p2_BiSRAM_in[4]),
                                      .DI5  (L0_p2_BiSRAM_in[5]),
                                      .DI6  (L0_p2_BiSRAM_in[6]),
                                      .DI7  (L0_p2_BiSRAM_in[7]),
                                      .DI8  (L0_p2_BiSRAM_in[8]),
                                      .DI9  (L0_p2_BiSRAM_in[9]),
                                      .DI10 (L0_p2_BiSRAM_in[10]),
                                      .DI11 (L0_p2_BiSRAM_in[11]),
                                      .DI12 (L0_p2_BiSRAM_in[12]),
                                      .DI13 (L0_p2_BiSRAM_in[13]),
                                      .DI14 (L0_p2_BiSRAM_in[14]),
                                      .DI15 (L0_p2_BiSRAM_in[15]),

                                      .CK  (clk),
                                      .WEB (web_bi_l0_p2),
                                      .OE  (1'b1), 
                                      .CS  (1'b1));                              
  // SRAM for Bi point2 L0        
  SUMA180_128X16X1BM1 Bi_l1_p2_SRAM    (.A0  (addres_bi_p2_l1[0]),
                                      .A1  (addres_bi_p2_l1[1]),
                                      .A2  (addres_bi_p2_l1[2]),
                                      .A3  (addres_bi_p2_l1[3]),

                                      .A4  (addres_bi_p2_l1[4]),
                                      .A5  (addres_bi_p2_l1[5]),
                                      .A6  (addres_bi_p2_l1[6]),
      
                                      .DO0  (bi_l1_p2_out[0]),
                                      .DO1  (bi_l1_p2_out[1]),
                                      .DO2  (bi_l1_p2_out[2]),
                                      .DO3  (bi_l1_p2_out[3]),
                                      .DO4  (bi_l1_p2_out[4]),
                                      .DO5  (bi_l1_p2_out[5]),
                                      .DO6  (bi_l1_p2_out[6]),
                                      .DO7  (bi_l1_p2_out[7]),
                                      .DO8  (bi_l1_p2_out[8]),
                                      .DO9  (bi_l1_p2_out[9]),
                                      .DO10 (bi_l1_p2_out[10]),
                                      .DO11 (bi_l1_p2_out[11]),
                                      .DO12 (bi_l1_p2_out[12]),
                                      .DO13 (bi_l1_p2_out[13]),
                                      .DO14 (bi_l1_p2_out[14]),
                                      .DO15 (bi_l1_p2_out[15]),
      
                                      .DI0  (L1_p2_BiSRAM_in[0]),
                                      .DI1  (L1_p2_BiSRAM_in[1]),
                                      .DI2  (L1_p2_BiSRAM_in[2]),
                                      .DI3  (L1_p2_BiSRAM_in[3]),
                                      .DI4  (L1_p2_BiSRAM_in[4]),
                                      .DI5  (L1_p2_BiSRAM_in[5]),
                                      .DI6  (L1_p2_BiSRAM_in[6]),
                                      .DI7  (L1_p2_BiSRAM_in[7]),
                                      .DI8  (L1_p2_BiSRAM_in[8]),
                                      .DI9  (L1_p2_BiSRAM_in[9]),
                                      .DI10 (L1_p2_BiSRAM_in[10]),
                                      .DI11 (L1_p2_BiSRAM_in[11]),
                                      .DI12 (L1_p2_BiSRAM_in[12]),
                                      .DI13 (L1_p2_BiSRAM_in[13]),
                                      .DI14 (L1_p2_BiSRAM_in[14]),
                                      .DI15 (L1_p2_BiSRAM_in[15]),

                                      .CK  (clk),
                                      .WEB (web_bi_l1_p2),
                                      .OE  (1'b1), 
                                      .CS  (1'b1));              
endmodule
