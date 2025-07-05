//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
       bready_m_inf,
                    
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
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;

// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;

// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;
//###########################################
//
// Wrtie down your design below
//
//###########################################
reg arvalid_ins;
reg arvalid_data;
reg [31:0] araddr_ins;
reg [31:0] araddr_data;
reg [31:0] araddr_data_0;

reg rready_ins;
reg rready_data;

reg [6:0] counter_sram;

wire rlast_ins;
wire rlast_data;

reg [6:0] addres_ins;
reg [15:0] ins_seq;
reg [15:0] ins;
reg [15:0] reg_ins;
reg web_ins;

reg [1:0]counter_fetch;
reg [2:0]         op_code;
reg [3:0]         rs;
reg [3:0]         rt;
reg [3:0]         rd;
reg               func;
reg signed [4:0]  imm;

parameter offset = 16'h1000;

reg signed [15:0] rs_data;

reg signed [15:0] rs_calculate;
reg signed [15:0] rt_calculate;
reg signed [15:0] calculate;

reg awvalid;
reg [31:0] awaddr_data;
reg wvalid_data;
reg wlast;
reg signed [15:0] wdata;
reg bready;
// ------- branch --------- //
reg signed [15:0] branch;
reg flag_branch;
reg [1:0] counter_branch;
reg [11:0] branch_addres;
// ------- branch --------- //

reg signed [15:0] cs_pc;

wire [4:0] imm_data;
// ------ jump address -------- //
reg [12:0] jumpaddres;
reg flag_jump;
reg [1:0] counter_jump;
reg [11:0] jump;
// ------ jump address -------- //
// ------------ for APR DEBUG ------------- //
reg [15:0] dramtosram;
reg arready_ins;
reg arready_data;
reg [63:0] araddr_m;

// ------------ for APR DEBUG ------------- //

//####################################################
//               reg & wire
//####################################################
// ---------------- FSM reg ---------------- //
reg [4:0] c_s, n_s;
parameter S0_IDLE     = 0;
parameter S1_READINS  = 1;
parameter S2_DRAMREAD = 2;
parameter S3_FETCH    = 3;
parameter S4_ADD      = 4;
parameter S5_SUB      = 5;
parameter S6_SET      = 6;

parameter S7_MUL      = 7;

parameter S8_LOAD_ins        = 8;
parameter S12_LOAD_addr     = 12;

parameter S9_STORE_ins     = 9;
parameter S14_STORE_addr    = 14;

parameter S10_BRANCH  = 10;
parameter S11_JUMP    = 11;
parameter S13_FINAL   = 13;
// ---------------- FSM reg ---------------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) c_s <= S0_IDLE;
  else c_s <= n_s;
end
always @(*) begin
    case (c_s)
      S0_IDLE : begin
        n_s = S1_READINS;
      end
      S1_READINS : begin
        if (arready_ins) n_s = S2_DRAMREAD;
        else n_s = S1_READINS;
      end
      S2_DRAMREAD : begin
        if (addres_ins == 127) begin 
          n_s = S3_FETCH;
        end
        else n_s = S2_DRAMREAD;
      end
      S3_FETCH : begin
        if (counter_fetch == 3) begin
          if (op_code == 3'b010) begin
            n_s = S8_LOAD_ins;
          end
          else if (op_code == 3'b000) begin
            if (func == 1) begin
              n_s = S5_SUB;
            end
            else n_s = S4_ADD;
          end
          else if (op_code == 3'b001) begin
            if (func == 1) begin
              n_s = S7_MUL;
            end
            else n_s = S6_SET;
          end
          else if (op_code == 3'b011) begin
            n_s = S9_STORE_ins;
          end
          else if (op_code == 3'b100) begin
            n_s = S10_BRANCH;
          end
          else if (op_code == 3'b101) begin
            n_s = S11_JUMP;
          end
          else n_s = S3_FETCH;
        end
        else n_s = S3_FETCH;
      end

      S4_ADD, S5_SUB, S7_MUL, S6_SET : begin
        n_s = S13_FINAL;
      end

      S8_LOAD_ins : begin
        if (arready_data) n_s = S12_LOAD_addr;
        else n_s = S8_LOAD_ins;
      end
      S12_LOAD_addr : begin
        if (rlast_data) n_s = S13_FINAL;
        else n_s = S12_LOAD_addr;
      end

      S9_STORE_ins : begin
        if (awready_m_inf == 1 && awvalid_m_inf == 1) n_s = S14_STORE_addr;
        else n_s = S9_STORE_ins;
      end
      S14_STORE_addr : begin
        if (bvalid_m_inf && bready_m_inf) n_s = S13_FINAL;
        else n_s = S14_STORE_addr;
      end

      S10_BRANCH : begin
        if (counter_branch == 1) begin
          n_s = S13_FINAL;
        end
        else n_s = S10_BRANCH;
      end

      S11_JUMP : begin
        if (counter_jump == 1) begin
          n_s = S13_FINAL;
        end
        else n_s = S11_JUMP;
      end

      S13_FINAL : begin
        if (flag_jump && (jump > 127) || (flag_jump && (araddr_ins > jumpaddres))) begin
          n_s = S0_IDLE;
        end
        else if (flag_branch && (branch_addres > 127)) begin
          n_s = S0_IDLE;
        end
        else if (!flag_branch && !flag_jump && addres_ins == 127) begin
          n_s = S0_IDLE;
        end
        else n_s = S3_FETCH;
      end
      default: n_s = c_s;
    endcase
end
// --------------------- DRAM READ INS -------------------- //
assign arid_m_inf = 0;
assign arburst_m_inf = 4'b0101;
assign arsize_m_inf = 6'b001001;
// brust ins 128 data 1
assign arlen_m_inf = 14'b11_1111_1000_0000;
// ----------------- ARVALID --------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    arvalid_ins <= 0;
  end
  else if (c_s == S1_READINS) begin
    if (arready_ins) arvalid_ins <= 0;
    else arvalid_ins <= 1;
  end
  else arvalid_ins <= arvalid_ins;
end
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    arvalid_data <= 0;
  end
  else if (c_s == S8_LOAD_ins) begin
    if (arready_data) arvalid_data <= 0;
    else arvalid_data <= 1;
  end
  else arvalid_data <= arvalid_data;
end
assign arvalid_m_inf = {arvalid_ins,arvalid_data};

always @(*) begin
  arready_ins = arready_m_inf[1];
end

always @(*) begin
  arready_data = arready_m_inf[0];
end
// ----------------- ARVALID --------- //
// ----------------- ARADDR ---------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    araddr_ins <= 32'h00001000;
  end
  else if (c_s == S13_FINAL) begin
    if (flag_jump && jump > 127) begin
      if ({3'b0,jumpaddres} > 16'h1f00) araddr_ins <= 16'h1f00;
      else araddr_ins <= {3'b0,jumpaddres};      
    end
    else if (flag_branch && branch_addres > 127) begin
      if (cs_pc > 16'h1f00) araddr_ins <= 16'h1f00;
      else araddr_ins <= cs_pc;
    end
    else if (!flag_branch && !flag_jump && addres_ins == 127) begin
      araddr_ins <= cs_pc + 2;
    end
    else araddr_ins <= araddr_ins;
  end
  else araddr_ins <= araddr_ins;
end

always @(*) begin
  araddr_data_0 = (rs_data + imm) <<< 1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    araddr_data <= 32'h00001000;
  end
  else if (c_s == S8_LOAD_ins) begin
    araddr_data <= araddr_data_0[11:0] + offset;
  end
  else araddr_data <= araddr_data;
end

always @(*) begin
  araddr_m = {araddr_ins,araddr_data};
end

assign araddr_m_inf = (rst_n) ? araddr_m : 0;
// ----------------- ARADDR ---------- //
assign rvalid_ins = rvalid_m_inf[1];
assign rvalid_data = rvalid_m_inf[0];
assign rlast_ins = rlast_m_inf[1];
assign rlast_data = rlast_m_inf[0];
// --------- RREADY ----------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) rready_ins <= 0;
  else if (arvalid_m_inf[1] && arready_ins) rready_ins <= 1;
  else if (rlast_ins) rready_ins <= 0;
  else rready_ins <= rready_ins;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) rready_data <= 0;
  else if (arvalid_m_inf[0] && arready_data) rready_data <= 1;
  else if (rlast_data) rready_data <= 0;
  else rready_data <= rready_data;
end

assign rready_m_inf = {rready_ins,rready_data};
// --------- RREADY ----------- //
// --------------------- DRAM READ INS -------------------- //
// --------------------- DRAM WRITE ----------------------- //
assign awid_m_inf = 0;
assign awburst_m_inf = 2'b01;
assign awsize_m_inf = 3'b001;
assign awlen_m_inf = 7'b000_0000;
assign awvalid_m_inf = awvalid;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    awvalid <= 0;
  end
  else if (c_s == S9_STORE_ins && n_s == S9_STORE_ins) begin
    awvalid <= 1;
  end
  else awvalid <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    awaddr_data <= 32'h0000;
  end
  else if (c_s == S9_STORE_ins) begin
    awaddr_data <= araddr_data_0 + offset;
  end
  else awaddr_data <= awaddr_data;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wdata <= 0;
  end
  else if (c_s == S14_STORE_addr) begin
    case (rt)
      0 : wdata <= core_r0 ;
      1 : wdata <= core_r1 ;
      2 : wdata <= core_r2 ;
      3 : wdata <= core_r3 ;
      4 : wdata <= core_r4 ;
      5 : wdata <= core_r5 ;
      6 : wdata <= core_r6 ;
      7 : wdata <= core_r7 ;
      8 : wdata <= core_r8 ;
      9 : wdata <= core_r9 ;
      10: wdata <= core_r10;
      11: wdata <= core_r11;
      12: wdata <= core_r12;
      13: wdata <= core_r13;
      14: wdata <= core_r14;
      15: wdata <= core_r15;
      default: wdata <= 0;
    endcase
  end
  else wdata <= wdata;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wvalid_data <= 0;
  end
  else if (c_s == S14_STORE_addr || n_s == S14_STORE_addr) begin
    if (awvalid_m_inf && awready_m_inf) wvalid_data <= 1;
    else if (wready_m_inf) begin
      wvalid_data <= 0;
    end
    else wvalid_data <= wvalid_data;
  end
  else wvalid_data <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wlast <= 0;
  end
  else if (c_s == S14_STORE_addr || n_s == S14_STORE_addr) begin
    if (awvalid_m_inf && awready_m_inf) wlast <= 1;
    else if (wready_m_inf) begin
      wlast <= 0;
    end
    else wlast <= wlast;
  end
  else wlast <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    bready <= 0;
  end
  else if (awvalid_m_inf && awready_m_inf) bready <= 1;
  else if (bvalid_m_inf) begin
    bready <= 0;
  end
  else bready <= bready;
end

assign wdata_m_inf = wdata;
assign wlast_m_inf = wlast;
assign awaddr_m_inf = awaddr_data;
assign wvalid_m_inf = wvalid_data;
assign bready_m_inf = 1;
// --------------------- DRAM WRITE ----------------------- //
assign imm_data = (imm[4]) ? -imm : imm;
// SRAM INS ------------ SRAM INS //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    addres_ins <= 0;
  end
  else if (c_s == S0_IDLE) begin
    addres_ins <= 0;
  end
  
  else if (c_s == S1_READINS) begin
    addres_ins <= 0;
  end
  
  else if (c_s == S3_FETCH) begin
    if (counter_fetch == 0) begin
      if (cs_pc > 16'h1f00 && (flag_branch || flag_jump) && ((jump > 127) || (branch_addres > 127))) begin
        addres_ins <= cs_pc[7:0] >> 1;
      end    
      else if (flag_jump && jump < 128) begin
        if (jump < 128) begin
          addres_ins <= addres_ins;
        end
        else addres_ins <= 0;
      end
      else addres_ins <= addres_ins;
    end
    else addres_ins <= addres_ins;
  end

  else if (c_s == S2_DRAMREAD) begin
    if (web_ins) begin
      addres_ins <= addres_ins;
    end
    else begin
      if (addres_ins < 127) begin
        addres_ins <= addres_ins + 1;
      end
      else if (addres_ins == 127) begin
        addres_ins <= 0;
      end
    end
  end

  else if (c_s == S13_FINAL) begin
    if (flag_branch) addres_ins <= addres_ins;
    else if (flag_jump) begin
      if (jump < 128) begin
        addres_ins <= addres_ins + ((jumpaddres - cs_pc) / 2);
      end
      else if (cs_pc > 16'h1f00) begin
        addres_ins <= cs_pc[7:0] >> 1;
      end
      else addres_ins <= 0;
    end
    else addres_ins <= addres_ins + 1;
  end

  else if (c_s == S10_BRANCH) begin
    if (branch == 0 && counter_branch == 0) begin
      if (imm[4] == 1) begin
        if (addres_ins + 1 - imm_data < 127) begin
            addres_ins <= addres_ins - imm_data + 1;
        end
        else addres_ins <= 0;
      end
      else begin
        if (addres_ins + 1 + imm_data < 127) begin
            addres_ins <= addres_ins + imm_data + 1;
        end
        else addres_ins <= 127;
      end
    end
    else addres_ins <= addres_ins;
  end
  else addres_ins <= addres_ins;
end

always @(*) begin
  ins_seq = dramtosram;
end
// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     ins_seq <= 0;
//   end
//   else ins_seq <= rdata_m_inf[31:16];
// end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dramtosram <= 0;
  end
  else dramtosram <= rdata_m_inf[31:16];
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    web_ins <= 1;
  end
  else if (rvalid_ins && rready_ins) begin
    web_ins <= 0;
  end
  else web_ins <= 1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    reg_ins <= 0;
  end
  else reg_ins <= ins;
end
// SRAM INS ------------ SRAM INS //
always @(*) begin
  if (!rst_n) begin
    op_code = 0;
    rs 	    = 0;
    rt 	    = 0;
    rd 	    = 0;
    func    = 0;
    imm 	  = 0;
  end
  else begin
    op_code = reg_ins[15:13];
    rs 	    = reg_ins[12:9];
    rt 	    = reg_ins[8:5];
    rd 	    = reg_ins[4:1];
    func    = reg_ins[0];
    imm 	  = reg_ins[4:0];
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    jumpaddres <= 0;
  end
  else if (c_s == S3_FETCH) begin
    jumpaddres <= reg_ins[12:0];
  end
  else jumpaddres <= jumpaddres;
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_fetch <= 0;
  end
  else if (c_s == S3_FETCH) begin
    counter_fetch <= counter_fetch + 1;
  end
  else counter_fetch <= 0;
end

always @(*) begin
  case (rs) 
    0  : rs_data =  core_r0;
    1  : rs_data =  core_r1;
    2  : rs_data =  core_r2;
    3  : rs_data =  core_r3;
    4  : rs_data =  core_r4;
    5  : rs_data =  core_r5;
    6  : rs_data =  core_r6;
    7  : rs_data =  core_r7;
    8  : rs_data =  core_r8;
    9  : rs_data =  core_r9;
    10 : rs_data = core_r10;
    11 : rs_data = core_r11;
    12 : rs_data = core_r12;
    13 : rs_data = core_r13;
    14 : rs_data = core_r14;
    15 : rs_data = core_r15;
  endcase
end
// ---------------------- S4_ADD S5_SUB S6_SET S7_MUL -------------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rs_calculate <= 0;
  end
  else if (c_s == S3_FETCH) begin
    case (rs) 
      0  : rs_calculate <=  core_r0;
      1  : rs_calculate <=  core_r1;
      2  : rs_calculate <=  core_r2;
      3  : rs_calculate <=  core_r3;
      4  : rs_calculate <=  core_r4;
      5  : rs_calculate <=  core_r5;
      6  : rs_calculate <=  core_r6;
      7  : rs_calculate <=  core_r7;
      8  : rs_calculate <=  core_r8;
      9  : rs_calculate <=  core_r9;
      10 : rs_calculate <= core_r10;
      11 : rs_calculate <= core_r11;
      12 : rs_calculate <= core_r12;
      13 : rs_calculate <= core_r13;
      14 : rs_calculate <= core_r14;
      15 : rs_calculate <= core_r15;
      default: rs_calculate <= rs_calculate;
    endcase
  end
  else rs_calculate <= rs_calculate;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rt_calculate <= 0;
  end
  else if (c_s == S3_FETCH) begin
    case (rt) 
      0  : rt_calculate <=  core_r0;
      1  : rt_calculate <=  core_r1;
      2  : rt_calculate <=  core_r2;
      3  : rt_calculate <=  core_r3;
      4  : rt_calculate <=  core_r4;
      5  : rt_calculate <=  core_r5;
      6  : rt_calculate <=  core_r6;
      7  : rt_calculate <=  core_r7;
      8  : rt_calculate <=  core_r8;
      9  : rt_calculate <=  core_r9;
      10 : rt_calculate <= core_r10;
      11 : rt_calculate <= core_r11;
      12 : rt_calculate <= core_r12;
      13 : rt_calculate <= core_r13;
      14 : rt_calculate <= core_r14;
      15 : rt_calculate <= core_r15;
      default: rt_calculate <= rt_calculate;
    endcase
  end
  else rt_calculate <= rt_calculate;
end

always @(*) begin
  if (!rst_n) begin
    calculate = 0;
  end
  else if (c_s == S4_ADD) begin
    calculate = rs_calculate + rt_calculate;
  end
  else if (c_s == S5_SUB) begin
    calculate = rs_calculate - rt_calculate;
  end
  else if (c_s == S6_SET) begin
    calculate = (rs_calculate < rt_calculate) ? 1 : 0;
  end
  else if (c_s == S7_MUL) begin
    calculate = rs_calculate * rt_calculate;
  end
  else calculate = 0;
end
// ---------------------- S4_ADD S5_SUB S6_SET S7_MUL -------------- // 
// ---------------- S10_BRANCH ----------- //
always @(*) begin
  branch = rs_calculate - rt_calculate;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_branch <= 0;
  end
  else if (c_s == S10_BRANCH) begin
    counter_branch <= counter_branch + 1;
  end
  else counter_branch <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    flag_branch <= 0;
  end
  else if (c_s == S10_BRANCH) begin
    if (branch == 0) begin
      flag_branch <= 1;
    end
    else flag_branch <= 0;
  end
  else if (c_s == S3_FETCH) begin
    flag_branch <= 0;
  end
  else flag_branch <= flag_branch;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    branch_addres <= 0;
  end
  else if (c_s == S10_BRANCH) begin
    branch_addres <= (cs_pc - araddr_ins) / 2;
  end
  else branch_addres <= branch_addres;
end
// ---------------- S10_BRANCH ----------- //

// -------------- core ---------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r0 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 0) core_r0 <= rdata_m_inf[15:0];
    else core_r0 <= core_r0;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 0) core_r0 <= calculate;
    else core_r0 <= core_r0;
  end
  else core_r0 <= core_r0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r1 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 1) core_r1 <= rdata_m_inf[15:0];
    else core_r1 <= core_r1;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 1) core_r1 <= calculate;
    else core_r1 <= core_r1;
  end
  else core_r1 <= core_r1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r2 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 2) core_r2 <= rdata_m_inf[15:0];
    else core_r2 <= core_r2;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 2) core_r2 <= calculate;
    else core_r2 <= core_r2;
  end
  else core_r2 <= core_r2;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r3 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 3) core_r3 <= rdata_m_inf[15:0];
    else core_r3 <= core_r3;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 3) core_r3 <= calculate;
    else core_r3 <= core_r3;
  end
  else core_r3 <= core_r3;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r4 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 4) core_r4 <= rdata_m_inf[15:0];
    else core_r4 <= core_r4;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 4) core_r4 <= calculate;
    else core_r4 <= core_r4;
  end
  else core_r4 <= core_r4;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r5 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 5) core_r5 <= rdata_m_inf[15:0];
    else core_r5 <= core_r5;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 5) core_r5 <= calculate;
    else core_r5 <= core_r5;
  end
  else core_r5 <= core_r5;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r6 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 6) core_r6 <= rdata_m_inf[15:0];
    else core_r6 <= core_r6;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 6) core_r6 <= calculate;
    else core_r6 <= core_r6;
  end
  else core_r6 <= core_r6;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r7 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 7) core_r7 <= rdata_m_inf[15:0];
    else core_r7 <= core_r7;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 7) core_r7 <= calculate;
    else core_r7 <= core_r7;
  end
  else core_r7 <= core_r7;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r8 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 8) core_r8 <= rdata_m_inf[15:0];
    else core_r8 <= core_r8;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 8) core_r8 <= calculate;
    else core_r8 <= core_r8;
  end
  else core_r8 <= core_r8;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r9 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 9) core_r9 <= rdata_m_inf[15:0];
    else core_r9 <= core_r9;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 9) core_r9 <= calculate;
    else core_r9 <= core_r9;
  end
  else core_r9 <= core_r9;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r10 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 10) core_r10 <= rdata_m_inf[15:0];
    else core_r10 <= core_r10;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 10) core_r10 <= calculate;
    else core_r10 <= core_r10;
  end
  else core_r10 <= core_r10;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r11 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 11) core_r11 <= rdata_m_inf[15:0];
    else core_r11 <= core_r11;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 11) core_r11 <= calculate;
    else core_r11 <= core_r11;
  end
  else core_r11 <= core_r11;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r12 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 12) core_r12 <= rdata_m_inf[15:0];
    else core_r12 <= core_r12;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 12) core_r12 <= calculate;
    else core_r12 <= core_r12;
  end
  else core_r12 <= core_r12;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r13 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 13) core_r13 <= rdata_m_inf[15:0];
    else core_r13 <= core_r13;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 13) core_r13 <= calculate;
    else core_r13 <= core_r13;
  end
  else core_r13 <= core_r13;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r14 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 14) core_r14 <= rdata_m_inf[15:0];
    else core_r14 <= core_r14;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 14) core_r14 <= calculate;
    else core_r14 <= core_r14;
  end
  else core_r14 <= core_r14;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    core_r15 <= 0;
  end
  else if (c_s == S12_LOAD_addr) begin
    if (rt == 15) core_r15 <= rdata_m_inf[15:0];
    else core_r15 <= core_r15;
  end
  else if (c_s == S4_ADD || c_s == S5_SUB || c_s == S6_SET || c_s == S7_MUL) begin
    if (rd == 15) core_r15 <= calculate;
    else core_r15 <= core_r15;
  end
  else core_r15 <= core_r15;
end
// -------------- core ---------- //
// -------------- cs_pc ----------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cs_pc <= 16'h1000;
  end
  else if (c_s == S10_BRANCH && counter_branch == 0) begin
    if ((branch == 0)) begin
      if (imm[4]) begin
        cs_pc <= cs_pc - (imm_data * 2) + 2;
      end
      else cs_pc <= cs_pc + (imm_data * 2) + 2;
      // cs_pc <= cs_pc + (imm * 2) + 2;
    end
    else cs_pc <= cs_pc;
  end
  else if (c_s == S13_FINAL) begin
    if (flag_branch) cs_pc <= cs_pc;
    else if (flag_jump) begin
      cs_pc <= {3'b000,jumpaddres};
    end
    else cs_pc <= cs_pc + 2;
  end
  else cs_pc <= cs_pc;
end
// -------------- cs_pc ----------- //
// -------------- jump  ----------- //
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) flag_jump <= 0;
  else if (c_s == S11_JUMP) flag_jump <= 1;
  else if (c_s == S3_FETCH) flag_jump <= 0;
  else flag_jump <= flag_jump;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) counter_jump <= 0;
  else if (c_s == S11_JUMP) counter_jump <= counter_jump + 1;
  else counter_jump <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    jump <= 0;
  end
  else if (c_s == S11_JUMP) begin
    jump <= (jumpaddres - araddr_ins) / 2;
  end
  else jump <= jump;
end
// -------------- jump  ----------- //
// ------------- output ----------- //
always @(*) begin
  IO_stall = (c_s == S13_FINAL) ? 0 : 1;
end
// ------------- output ----------- //


// ---------------------------------------------------------------------------- //
// SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM
// SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM
// SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM   SRAM
// ---------------------------------------------------------------------------- //
SUMA180_128X16X1BM1 inssram( .A0(addres_ins[0]),
                             .A1(addres_ins[1]),
                             .A2(addres_ins[2]),
                             .A3(addres_ins[3]),
                             .A4(addres_ins[4]),
                             .A5(addres_ins[5]),
                             .A6(addres_ins[6]),

                             .DO0 (ins[0]),
                             .DO1 (ins[1]),
                             .DO2 (ins[2]),
                             .DO3 (ins[3]),
                             .DO4 (ins[4]),
                             .DO5 (ins[5]),
                             .DO6 (ins[6]),
                             .DO7 (ins[7]),
                             .DO8 (ins[8]),
                             .DO9 (ins[9]),
                             .DO10(ins[10]),
                             .DO11(ins[11]),
                             .DO12(ins[12]),
                             .DO13(ins[13]),
                             .DO14(ins[14]),
                             .DO15(ins[15]),

                             .DI0 (ins_seq[0]),
                             .DI1 (ins_seq[1]),
                             .DI2 (ins_seq[2]),
                             .DI3 (ins_seq[3]),
                             .DI4 (ins_seq[4]),
                             .DI5 (ins_seq[5]),
                             .DI6 (ins_seq[6]),
                             .DI7 (ins_seq[7]),
                             .DI8 (ins_seq[8]),
                             .DI9 (ins_seq[9]),
                             .DI10(ins_seq[10]),
                             .DI11(ins_seq[11]),
                             .DI12(ins_seq[12]),
                             .DI13(ins_seq[13]),
                             .DI14(ins_seq[14]),
                             .DI15(ins_seq[15]),

                             .CK(clk),
                             .WEB(web_ins),
                             .OE(1'b1), 
                             .CS(1'b1));
// ============ INS SRAM ================= //
endmodule



















