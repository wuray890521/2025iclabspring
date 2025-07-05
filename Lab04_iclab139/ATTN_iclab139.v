//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Two Head Attention
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : ATTN.v
//   Module Name : ATTN
//   Release version : V1.0 (Release Date: 2025-3)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module ATTN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    in_str,
    q_weight,
    k_weight,
    v_weight,
    out_weight,

    //Output Port
    out_valid,
    out
    );

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
parameter sqare_root_2 = 32'b00111111101101010000010011110011;

parameter one = 32'b00111111100000000000000000000000;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] in_str, q_weight, k_weight, v_weight, out_weight;
reg [inst_sig_width+inst_exp_width:0] in_str_d, q_weight_d, k_weight_d, v_weight_d, out_weight_d;


output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
// --------FSM----------
reg [3:0] c_s, n_s;

parameter S_IDLE     = 4'd0;
parameter S_LOAD     = 4'd1;
parameter S_MULT     = 4'd2;
parameter S_SCOR     = 4'd3;
parameter S_HEAD_1   = 4'd4;
parameter S_HEAD_2   = 4'd5;
parameter S_FINAL    = 4'd6;
parameter S_EXP      = 4'd7;
parameter S_EXP_1    = 4'd8;
parameter S_OUT_MAX  = 4'd9;
// parameter S_OUT      = 4'd10;
// --------FSM----------
// ---------S_LOAD------
reg [5:0] count_x;
reg [5:0] count_y;
reg [inst_sig_width+inst_exp_width:0] in_str_max    [0:4][0:3];
reg [inst_sig_width+inst_exp_width:0] q_weight_max  [0:4][0:4];
reg [inst_sig_width+inst_exp_width:0] k_weight_max  [0:4][0:4];
reg [inst_sig_width+inst_exp_width:0] v_weight_max  [0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] out_weight_max[0:3][0:3]; //can't move
reg [inst_sig_width+inst_exp_width:0] K_matrix[0:4][0:3];
reg [inst_sig_width+inst_exp_width:0] Q_matrix[0:4][0:3];
reg [inst_sig_width+inst_exp_width:0] V_matrix[0:4][0:3];
integer i, j;
// ---------S_LOAD------
// ----------S_MULT-----

reg [inst_sig_width+inst_exp_width:0] in_str_0;
reg [inst_sig_width+inst_exp_width:0] in_str_1;
reg [inst_sig_width+inst_exp_width:0] in_str_2;
reg [inst_sig_width+inst_exp_width:0] in_str_3;

reg [inst_sig_width+inst_exp_width:0] weight_0;
reg [inst_sig_width+inst_exp_width:0] weight_1;
reg [inst_sig_width+inst_exp_width:0] weight_2;
reg [inst_sig_width+inst_exp_width:0] weight_3;

reg [inst_sig_width+inst_exp_width:0] in_str_0_1;
reg [inst_sig_width+inst_exp_width:0] in_str_1_1;
reg [inst_sig_width+inst_exp_width:0] in_str_2_1;
reg [inst_sig_width+inst_exp_width:0] in_str_3_1;

reg [inst_sig_width+inst_exp_width:0] weight_0_1;
reg [inst_sig_width+inst_exp_width:0] weight_1_1;
reg [inst_sig_width+inst_exp_width:0] weight_2_1;
reg [inst_sig_width+inst_exp_width:0] weight_3_1;

reg [inst_sig_width+inst_exp_width:0] test0;
reg [inst_sig_width+inst_exp_width:0] test1;
reg [inst_sig_width+inst_exp_width:0] test2;
reg [inst_sig_width+inst_exp_width:0] test3;
reg [inst_sig_width+inst_exp_width:0] test4;
reg [inst_sig_width+inst_exp_width:0] test5;
reg [inst_sig_width+inst_exp_width:0] addr0;
reg [inst_sig_width+inst_exp_width:0] addr1;
reg [inst_sig_width+inst_exp_width:0] test6;

reg [inst_sig_width+inst_exp_width:0] test0_1;
reg [inst_sig_width+inst_exp_width:0] test1_1;
reg [inst_sig_width+inst_exp_width:0] test2_1;
reg [inst_sig_width+inst_exp_width:0] test3_1;
reg [inst_sig_width+inst_exp_width:0] test4_1;
reg [inst_sig_width+inst_exp_width:0] test5_1;
reg [inst_sig_width+inst_exp_width:0] addr0_1;
reg [inst_sig_width+inst_exp_width:0] addr1_1;
reg [inst_sig_width+inst_exp_width:0] test6_1;

reg [inst_sig_width+inst_exp_width:0] head_temp;

reg [inst_sig_width+inst_exp_width:0] div_in;
reg [inst_sig_width+inst_exp_width:0] div_out;
reg [inst_sig_width+inst_exp_width:0] div_num;

reg [inst_sig_width+inst_exp_width:0] div_in_1;
reg [inst_sig_width+inst_exp_width:0] div_out_1;
reg [inst_sig_width+inst_exp_width:0] div_num_1;

reg [inst_sig_width+inst_exp_width:0] head_out_2;

reg [inst_sig_width+inst_exp_width:0] exp_in;
reg [inst_sig_width+inst_exp_width:0] exp_out;

reg [inst_sig_width+inst_exp_width:0] exp_in_1;
reg [inst_sig_width+inst_exp_width:0] exp_out_1;


// reg [inst_sig_width+inst_exp_width:0] head_out[0:4][0:3];
// head1 除 root 2
// reg [inst_sig_width+inst_exp_width:0] exp_score_1[0:4][0:4];
// head2 除 root 2
// reg [inst_sig_width+inst_exp_width:0] exp_score_2[0:4][0:4];

// reg [inst_sig_width+inst_exp_width:0] final_max[0:4][0:3];
// reg [inst_sig_width+inst_exp_width:0] exp_max[0:4][0:3];
// reg [inst_sig_width+inst_exp_width:0] nornolize[0:4];
// reg [inst_sig_width+inst_exp_width:0] nornolize_1[0:4];
// reg [inst_sig_width+inst_exp_width:0] score[0:4][0:4];
// reg [inst_sig_width+inst_exp_width:0] score_1[0:4][0:4];

reg [7:0] count_2;
reg [4:0] count_2_x;
reg [4:0] count_2_y;

reg [4:0] count_2_sx;
reg [4:0] count_2_sy;

reg flag_SCOR;

reg [20:0] count_head;
reg [20:0] count_head_x;
reg [20:0] count_head_y;

reg [20:0] count_final;
reg [2:0] count_final_x;
reg [2:0] count_final_y;


reg [4:0] count_exp;
reg [2:0] count_exp_x;
reg [2:0] count_exp_y;
reg [2:0] count_exp_out;

reg [4:0] count_out;
reg [4:0] count_head_out_x;
reg [4:0] count_head_out_y;

reg [5:0] count_out_max;
// ----------S_MULT-----
//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
// ex.
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL1 ( .a(in_str_0), .b(weight_0), .rnd(3'b000), .z(test0), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL2 ( .a(in_str_1), .b(weight_1), .rnd(3'b000), .z(test1), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL3 ( .a(in_str_2), .b(weight_2), .rnd(3'b000), .z(test2), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL4 ( .a(in_str_3), .b(weight_3), .rnd(3'b000), .z(test3), .status());


DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD1 ( .a(test0), .b(test1), .rnd(3'b000), .z(test4), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD2 ( .a(test3), .b(test2), .rnd(3'b000), .z(test5), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD3 ( .a(addr0), .b(addr1), .rnd(3'b000), .z(test6), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL5 ( .a(in_str_0_1), .b(weight_0_1), .rnd(3'b000), .z(test0_1), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL6 ( .a(in_str_1_1), .b(weight_1_1), .rnd(3'b000), .z(test1_1), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL7 ( .a(in_str_2_1), .b(weight_2_1), .rnd(3'b000), .z(test2_1), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
MUL8 ( .a(in_str_3_1), .b(weight_3_1), .rnd(3'b000), .z(test3_1), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD4 ( .a(test0_1), .b(test1_1), .rnd(3'b000), .z(test4_1), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD5 ( .a(test3_1), .b(test2_1), .rnd(3'b000), .z(test5_1), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD6 ( .a(addr0_1), .b(addr1_1), .rnd(3'b000), .z(test6_1), .status());

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
DIV1 ( .a(div_in), .b(div_num), .rnd(3'b000), .z(div_out), .status());

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
DIV2 ( .a(div_in_1), .b(div_num_1), .rnd(3'b000), .z(div_out_1), .status());

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
EXP1 (.a(exp_in), .z(exp_out));

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
EXP2 (.a(exp_in_1), .z(exp_out_1));

//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------
// ----------FSM------------
always @(posedge clk or negedge rst_n)begin
    if (!rst_n)
        c_s <= S_IDLE;
    else
        c_s <= n_s;
end
always @(*)begin
      case (c_s)
          S_IDLE:
            begin
                if (in_valid)
                    n_s = S_LOAD;
                else
                    n_s = S_IDLE;
            end                                                        
          S_LOAD:
            begin
                if (~in_valid)
                    n_s = S_MULT;
                else
                    n_s = S_LOAD;
            end                                                        
          S_MULT:
            begin
                if (count_2 == 21)
                    n_s = S_SCOR;
                else
                    n_s = S_MULT;
            end                                                        
          S_SCOR:
            begin
                if (count_2 == 27)
                    n_s = S_HEAD_1;
                else
                    n_s = S_SCOR;
            end                                                        
          S_HEAD_1:
            begin
                if (count_head == 7)
                    n_s = S_HEAD_2;
                else
                    n_s = S_HEAD_1;
            end                                                        
          S_HEAD_2:
            begin
                if (count_head == 7)
                    n_s = S_FINAL;
                else
                    n_s = S_HEAD_2;
            end                                                        
          S_FINAL:
            begin
                if (count_final == 26)
                    n_s = S_EXP;
                else
                    n_s = S_FINAL;
            end                                                        
          S_EXP:
            begin
                if (count_exp == 12)
                    n_s = S_EXP_1;
                else
                    n_s = S_EXP;
            end                                                        
          S_EXP_1:
            begin
                if (count_exp == 12)
                    n_s = S_OUT_MAX;
                else
                    n_s = S_EXP_1;
            end                                                        
          S_OUT_MAX:
            begin
                if (count_out_max == 22)
                    n_s = S_IDLE;
                else
                    n_s = S_OUT_MAX;
            end                                                        
        //   S_OUT:
        //     begin
        //         if (count_out == 21)
        //             n_s = S_IDLE;
        //         else
        //             n_s = S_OUT;
        //     end                                                        
          default:
              n_s = S_IDLE;
      endcase
end
// ----------FSM------------
// --------------input_delay---------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_d     <= 0;
        q_weight_d   <= 0;
        k_weight_d   <= 0;
        v_weight_d   <= 0;
        out_weight_d <= 0;
    end
    else begin
        in_str_d     <= in_str    ;
        q_weight_d   <= q_weight  ;
        k_weight_d   <= k_weight  ;
        v_weight_d   <= v_weight  ;
        out_weight_d <= out_weight;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_x <= 0;
    end
    else if (c_s == S_LOAD) begin
        if (count_x == 3) count_x <= 0;
        else count_x <= count_x + 1;
    end
    else count_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_y <= 0;
    end
    else if (c_s == S_LOAD) begin
        if (count_x == 3) count_y <= count_y + 1;
        else count_y <= count_y;
    end
    else count_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                in_str_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_LOAD) begin
        in_str_max[count_y][count_x] <= in_str_d;
    end
    // -------------origin head_out------------------------
    else if (c_s == S_EXP) begin
        in_str_max[count_head_out_x][count_head_out_y] <= test6_1;
    end  
    else if (c_s == S_EXP_1) begin
        in_str_max[count_head_out_x][count_head_out_y] <= test6_1;
    end  
    // -------------origin head_out------------------------    
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                in_str_max[i][j] <= in_str_max[i][j];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                q_weight_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_LOAD) begin
        q_weight_max[count_y][count_x] <= q_weight_d;
    end
    // ---------original exp_score_1-------------
    else if (c_s == S_SCOR) begin
        q_weight_max[count_2_sy][count_2_sx] <= exp_out;
    end
    // ---------original score-------------
    else if (c_s == S_FINAL) begin
        q_weight_max[count_final_y][count_final_x] <= div_out;
    end    
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                q_weight_max[i][j] <= q_weight_max[i][j];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                k_weight_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_LOAD) begin
        k_weight_max[count_y][count_x] <= k_weight_d;
    end
    // -----origin exp_score_2---------------------------
    else if (c_s == S_SCOR) begin
        k_weight_max[count_2_sy][count_2_sx] <= exp_out_1;
    end
    // -----origin score_1---------------------------
    else if (c_s == S_FINAL) begin
        k_weight_max[count_final_y][count_final_x] <= div_out_1;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                k_weight_max[i][j] <= k_weight_max[i][j];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                v_weight_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_LOAD) begin
        v_weight_max[count_y][count_x] <= v_weight_d;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                v_weight_max[i][j] <= v_weight_max[i][j];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                out_weight_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_LOAD) begin
        out_weight_max[count_y][count_x] <= out_weight_d;
    end
    else begin
        for (i = 0; i < 4 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                out_weight_max[i][j] <= out_weight_max[i][j];
            end
        end
    end
end
// --------------input_delay---------
// ----------mult-------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_2 <= 0;
    end
    else if (c_s == S_MULT) begin
        if (count_2 == 21) count_2 <= 0;
        else count_2 <= count_2 + 1;
    end
    else if (c_s == S_SCOR) begin
        count_2 <= count_2 + 1;
    end
    else count_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_0 <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR) begin
        if (count_2 < 27 && count_2 >= 20) in_str_0 <= 0;
        else in_str_0 <= in_str_max[count_2/4][0];
    end
    else if (c_s == S_HEAD_1) begin
        in_str_0 <= q_weight_max[count_head][0];
    end
    else if (c_s == S_HEAD_2) begin
        in_str_0 <= k_weight_max[count_head][0];
    end
    else if (c_s == S_EXP) begin
        in_str_0 <= q_weight_max[count_exp%5][0];
    end
    else if (c_s == S_EXP_1) begin
        in_str_0 <= k_weight_max[count_exp%5][0];
    end
    else if (c_s == S_OUT_MAX) begin
        in_str_0 <= in_str_max[count_out_max / 4][0];
    end
    else in_str_0 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_1 <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR) begin
        if (count_2 < 27 && count_2 >= 20) in_str_1 <= 0;
        else in_str_1 <= in_str_max[count_2/4][1];
    end
    else if (c_s == S_HEAD_1) begin
        in_str_1 <= q_weight_max[count_head][1];
    end
    else if (c_s == S_HEAD_2) begin
        in_str_1 <= k_weight_max[count_head][1];
    end
    else if (c_s == S_EXP) begin
        in_str_1 <= q_weight_max[count_exp%5][1];
    end
    else if (c_s == S_EXP_1) begin
        in_str_1 <= k_weight_max[count_exp%5][1];
    end
    else if (c_s == S_OUT_MAX) begin
        in_str_1 <= in_str_max[count_out_max / 4][1];
    end
    else in_str_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_2 <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR) begin
        if (count_2 < 27 && count_2 >= 20) in_str_2 <= 0;
        else in_str_2 <= in_str_max[count_2/4][2];
    end
    else if (c_s == S_HEAD_1) begin
        in_str_2 <= q_weight_max[count_head][2];
    end       
    else if (c_s == S_HEAD_2) begin
        in_str_2 <= k_weight_max[count_head][2];
    end
    else if (c_s == S_EXP) begin
        in_str_2 <= q_weight_max[count_exp%5][2];
    end
    else if (c_s == S_EXP_1) begin
        in_str_2 <= k_weight_max[count_exp%5][2];
    end
    else if (c_s == S_OUT_MAX) begin
        in_str_2 <= in_str_max[count_out_max / 4][2]; //edited 
    end
    else in_str_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_3 <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR) begin
        if (count_2 < 27 && count_2 >= 20) in_str_3 <= 0;
        else in_str_3 <= in_str_max[count_2/4][3];
    end
    else if (c_s == S_HEAD_1) begin
        in_str_3 <= q_weight_max[count_head][3];
    end
    else if (c_s == S_HEAD_2) begin
        in_str_3 <= k_weight_max[count_head][3];
    end
    else if (c_s == S_EXP) begin
        in_str_3 <= q_weight_max[count_exp%5][3];
    end
    else if (c_s == S_EXP_1) begin
        in_str_3 <= k_weight_max[count_exp%5][3];
    end
    else if (c_s == S_OUT_MAX) begin
        in_str_3 <= in_str_max[count_out_max / 4][3];
    end
    else in_str_3 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_0_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        if (count_2 == 20 || count_2 == 21 || count_2 == 25 || count_2 == 26) in_str_0_1 <= 0;
        else in_str_0_1 <= in_str_max[count_2/4][0];
    end
    else if (c_s == S_SCOR) begin
        in_str_0_1 <= Q_matrix[count_2/5][0];
    end
    else if (c_s == S_HEAD_1) begin
        in_str_0_1 <= q_weight_max[count_head][4];
    end
    else if (c_s == S_HEAD_2) begin
        in_str_0_1 <= k_weight_max[count_head][4];
    end
    else if (c_s == S_EXP) begin
        in_str_0_1 <= q_weight_max[count_exp%5][4];
    end
    else if (c_s == S_EXP_1) begin
        in_str_0_1 <= k_weight_max[count_exp%5][4];
    end
    else in_str_0_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_1_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        if (count_2 == 20 || count_2 == 21) in_str_1_1 <= 0;
        else in_str_1_1 <= in_str_max[count_2/4][1];
    end
    else if (c_s == S_SCOR) begin
        in_str_1_1 <= Q_matrix[count_2/5][1];
    end
    else in_str_1_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_2_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        if (count_2 == 20 || count_2 == 21) in_str_2_1 <= 0;
        else in_str_2_1 <= in_str_max[count_2/4][2];
    end
    else if (c_s == S_SCOR) begin
        in_str_2_1 <= Q_matrix[count_2/5][2];
    end    
    else in_str_2_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_str_3_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        if (count_2 == 20 || count_2 == 21) in_str_3_1 <= 0;
        else in_str_3_1 <= in_str_max[count_2/4][3];
    end
    else if (c_s == S_SCOR) begin
        in_str_3_1 <= Q_matrix[count_2/5][3];
    end
    else in_str_3_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_0 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_0 <= k_weight_max[count_2%4][0];
    end
    else if (c_s == S_SCOR) begin
        weight_0 <= v_weight_max[count_2%4][0];
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2) begin
        weight_0 <= one;
    end
    else if (c_s == S_EXP) begin
        weight_0 <= V_matrix[0][count_exp/5];
    end
    else if (c_s == S_EXP_1) begin
        weight_0 <= V_matrix[0][count_exp/5 + 2];
    end
    else if (c_s == S_OUT_MAX) begin
        weight_0 <= out_weight_max[count_out_max%4][0];
    end
    else weight_0 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_1 <= k_weight_max[count_2%4][1];
    end
    else if (c_s == S_SCOR) begin
        weight_1 <= v_weight_max[count_2%4][1];
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2) begin
        weight_1 <= one;
    end
    else if (c_s == S_EXP) begin
        weight_1 <= V_matrix[1][count_exp/5];
    end
    else if (c_s == S_EXP_1) begin
        weight_1 <= V_matrix[1][count_exp/5 + 2];
    end
    else if (c_s == S_OUT_MAX) begin
        weight_1 <= out_weight_max[count_out_max%4][1];
    end
    else weight_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_2 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_2 <= k_weight_max[count_2%4][2];
    end
    else if (c_s == S_SCOR) begin
        weight_2 <= v_weight_max[count_2%4][2];
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2) begin
        weight_2 <= one;
    end
    else if (c_s == S_EXP) begin
        weight_2 <= V_matrix[2][count_exp/5];
    end
    else if (c_s == S_EXP_1) begin
        weight_2 <= V_matrix[2][count_exp/5 + 2];
    end
    else if (c_s == S_OUT_MAX) begin
        weight_2 <= out_weight_max[count_out_max%4][2];
    end
    else weight_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_3 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_3 <= k_weight_max[count_2%4][3];
    end
    else if (c_s == S_SCOR) begin
        weight_3 <= v_weight_max[count_2%4][3];
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2) begin
        weight_3 <= one;
    end
    else if (c_s == S_EXP) begin
        weight_3 <= V_matrix[3][count_exp/5];
    end
    else if (c_s == S_EXP_1) begin
        weight_3 <= V_matrix[3][count_exp/5 + 2];
    end
    else if (c_s == S_OUT_MAX) begin
        weight_3 <= out_weight_max[count_out_max%4][3];
    end
    else weight_3 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_0_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_0_1 <= q_weight_max[count_2%4][0];
    end
    else if (c_s == S_SCOR) begin
        weight_0_1 <= K_matrix[count_2%5][0];
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2) begin
        weight_0_1 <= one;
    end
    else if (c_s == S_EXP) begin
        weight_0_1 <= V_matrix[4][count_exp/5];
    end
    else if (c_s == S_EXP_1) begin
        weight_0_1 <= V_matrix[4][count_exp/5 + 2];
    end
    else weight_0_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_1_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_1_1 <= q_weight_max[count_2%4][1];
    end
    else if (c_s == S_SCOR) begin
        weight_1_1 <= K_matrix[count_2%5][1];
    end
    else weight_1_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_2_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_2_1 <= q_weight_max[count_2%4][2];
    end
    else if (c_s == S_SCOR) begin
        weight_2_1 <= K_matrix[count_2%5][2];
    end
    else weight_2_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_3_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        weight_3_1 <= q_weight_max[count_2%4][3];
    end
    else if (c_s == S_SCOR) begin
        weight_3_1 <= K_matrix[count_2%5][3];
    end    
    else weight_3_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr0 <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR || c_s == S_HEAD_1 || c_s == S_HEAD_2 || c_s == S_EXP || c_s == S_EXP_1 || c_s == S_OUT_MAX) begin
        addr0 <= test4;
    end
    else addr0 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr1 <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR || c_s == S_HEAD_1 || c_s == S_HEAD_2 || c_s == S_EXP || c_s == S_EXP_1 || c_s == S_OUT_MAX) begin
        addr1 <= test5;
    end
    else addr1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr0_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        addr0_1 <= test4_1;
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2 || c_s == S_EXP || c_s == S_EXP_1) begin
        addr0_1 <= test6;
    end
    else addr0_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        head_temp <= 0;
    end
    else head_temp <= test0_1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr1_1 <= 0;
    end
    else if (c_s == S_MULT) begin
        addr1_1 <= test5_1;
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2 || c_s == S_EXP || c_s == S_EXP_1) begin
        addr1_1 <= head_temp;
    end
    else addr1_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_2_x <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR) begin
        if (count_2 < 2) count_2_x <= 0;
        else begin
            if (count_2_x == 3) count_2_x <= 0;
            else count_2_x <= count_2_x + 1;
        end
    end
    else count_2_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_2_y <= 0;
    end
    else if (c_s == S_MULT || c_s == S_SCOR) begin
        if (count_2 < 2) count_2_y <= 0;
        else begin
            if (count_2_x == 3) count_2_y <= count_2_y + 1;
            else count_2_y <= count_2_y;
        end
    end
    else count_2_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                K_matrix[i][j] <= 0;
            end
        end        
    end
    else if (c_s == S_MULT) begin
        K_matrix[count_2_y][count_2_x] <= test6;
    end
    // origin nornolize
    else if (c_s == S_HEAD_1) begin
        K_matrix[count_exp_out][0] <= test6_1;
    end
    // origin nornolize_1
    else if (c_s == S_HEAD_2) begin
        K_matrix[count_exp_out][1] <= test6_1;
    end    
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                K_matrix[i][j] <= K_matrix[i][j];
            end
        end          
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                Q_matrix[i][j] <= 0;
            end
        end        
    end
    else if (c_s == S_MULT) begin
        Q_matrix[count_2_y][count_2_x] <= test6_1;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                Q_matrix[i][j] <= Q_matrix[i][j];
            end
        end          
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                V_matrix[i][j] <= 0;
            end
        end        
    end
    else if (c_s == S_SCOR) begin
        if (flag_SCOR) V_matrix[count_2_y][count_2_x] <= test6;
        else begin
            for (i = 0; i < 5 ; i = i + 1 ) begin
                for (j = 0; j < 4 ; j = j + 1 ) begin
                    V_matrix[i][j] <= V_matrix[i][j];
                end
            end            
        end
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                V_matrix[i][j] <= V_matrix[i][j];
            end
        end          
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_SCOR <= 0;
    end
    else if (c_s == S_SCOR) begin
        if (count_2 >= 1 && count_2 <= 21) flag_SCOR <= 1;
        else flag_SCOR <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_in <= 0;
    end
    else if (c_s == S_SCOR) begin
        div_in <= test4_1;
    end
    else if (c_s == S_HEAD_2) begin
        div_in <= test6_1;
    end
    else if (c_s == S_FINAL) begin
        div_in <= q_weight_max[count_final/5][count_final%5];
    end
    // else if (c_s == S_OUT) begin
    //     div_in <= exp_max[count_out%5][count_out/5];
    // end
    else div_in <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_num <= 0;
    end
    else if (c_s == S_SCOR || c_s == S_HEAD_2) begin
        div_num <= sqare_root_2;
    end
    else if (c_s == S_FINAL) begin
        div_num <= K_matrix[count_final/5][0];
    end
    // else if (c_s == S_OUT) begin
    //     div_num <= nornolize[count_out / 5];
    // end
    else div_num <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_2_sx <= 0;
    end
    else if (c_s == S_SCOR) begin
        if (count_2 < 3) count_2_sx <= 0;
        else begin
            if (count_2_sx == 4) count_2_sx <= 0;
            else count_2_sx <= count_2_sx + 1;
        end
    end
    else count_2_sx <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_2_sy <= 0;
    end
    else if (c_s == S_SCOR) begin
        if (count_2 < 3) count_2_sy <= 0;
        else begin
            if (count_2_sx == 4) count_2_sy <= count_2_sy + 1;
            else count_2_sy <= count_2_sy;
        end
    end
    else count_2_sy <= 0;
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                exp_score_1[i][j] <= 0;
            end
        end        
    end
    else if (c_s == S_SCOR) begin
        exp_score_1[count_2_sy][count_2_sx] <= exp_out;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                exp_score_1[i][j] <= exp_score_1[i][j];
            end
        end
    end
end*/

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_in_1 <= 0;
    end
    else if (c_s == S_SCOR) begin
        div_in_1 <= test5_1;
    end
    else if (c_s == S_FINAL) begin
        div_in_1 <= k_weight_max[count_final/5][count_final%5];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_num_1 <= 0;
    end
    else if (c_s == S_SCOR) begin
        div_num_1 <= sqare_root_2;
    end
    else if (c_s == S_FINAL) begin
        div_num_1 <= K_matrix[count_final/5][1];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp_in_1 <= 0;
    end
    else if (c_s == S_SCOR) begin
        exp_in_1 <= div_out_1;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                exp_score_2[i][j] <= 0;
            end
        end        
    end
    else if (c_s == S_SCOR) begin
        exp_score_2[count_2_sy][count_2_sx] <= exp_out_1;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                exp_score_2[i][j] <= exp_score_2[i][j];
            end
        end          
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_head <= 0;
    end
    else if (c_s == S_HEAD_1) begin
        if (count_head == 7) count_head <= 0;
        else count_head <= count_head + 1;
    end
    else if (c_s == S_HEAD_2) begin
        count_head <= count_head + 1;
    end
    else count_head <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_head_x <= 0;
    end
    else if (c_s == S_HEAD_1) begin
        if(count_head <= 2) count_head_x <= 0;
        else begin
            if (count_head_x == 4) count_head_x <= 0;
            else count_head_x <= count_head_x + 1;
        end
    end
    else if (c_s == S_HEAD_2) begin
        if(count_head <= 3) count_head_x <= 0;
        else begin
            if (count_head_x == 4) count_head_x <= 0;
            else count_head_x <= count_head_x + 1;
        end
    end
    else count_head_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_head_y <= 0;
    end
    else if (c_s == S_HEAD_1) begin
        if(count_head <= 2) count_head_y <= 0;
        else begin
            if (count_head_x == 4) count_head_y <= count_head_y + 1;
            else count_head_y <= count_head_y;
        end
    end
    else if (c_s == S_HEAD_2) begin
        if(count_head <= 3) count_head_y <= 2;
        else begin
            if (count_head_x == 4) count_head_y <= count_head_y + 1;
            else count_head_y <= count_head_y;
        end
    end
    else count_head_y <= 0;
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                head_out[i][j] <= 0;
            end
        end        
    end 
    else if (c_s == S_EXP) begin
        head_out[count_head_out_x][count_head_out_y] <= test6_1;
    end  
    else if (c_s == S_EXP_1) begin
        head_out[count_head_out_x][count_head_out_y] <= test6_1;
    end  
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                head_out[i][j] <= head_out[i][j];
            end
        end            
    end 
end */

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_final <= 0;
    end
    else if (c_s == S_FINAL) begin
        count_final <= count_final + 1;
    end
    else if (c_s == S_LOAD) begin
        count_final <= 0;        
    end
    else count_final <= count_final;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_final_x <= 0;
    end
    else if (c_s == S_FINAL) begin
        if (count_final < 1) count_final_x <= 0;
        else begin
            if (count_final_x == 4) begin
                count_final_x <= 0;
            end
            else count_final_x <= count_final_x + 1;
        end
    end
    else count_final_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_final_y <= 0;
    end
    else if (c_s == S_FINAL) begin
        if (count_final < 1) count_final_y <= 0;
        else begin
            if (count_final_x == 4) begin
                count_final_y <= count_final_y + 1;
            end
            else count_final_y <= count_final_y;
        end
    end
    else count_final_y <= 0;
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                final_max[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_FINAL) begin
        final_max[count_final_y][count_final_x] <= test6;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 4 ; j = j + 1 ) begin
                final_max[i][j] <= final_max[i][j];
            end
        end
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_exp <= 0;
    end
    else if (c_s == S_EXP) begin
        if (count_exp == 12) count_exp <= 0;
        else count_exp <= count_exp + 1;
    end
    else if (c_s == S_EXP_1) begin
        if (count_exp == 12) count_exp <= 0;
        else count_exp <= count_exp + 1;
    end
    else count_exp <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_exp_x <= 0;
    end
    else if (c_s == S_FINAL) begin
        count_exp_x <= count_final_x;
    end
    else count_exp_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_exp_y <= 0;
    end
    else if (c_s == S_FINAL) begin
        count_exp_y <= count_final_y;
    end
    else count_exp_y <= 0;
end

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         for (i = 0; i < 5 ; i = i + 1 ) begin
//             for (j = 0; j < 4 ; j = j + 1 ) begin
//                 exp_max[i][j] <= 0;
//             end
//         end
//     end
//     else if (c_s == S_FINAL) begin
//         exp_max[count_exp_y][count_exp_x] <= exp_out;
//     end
//     else begin
//         for (i = 0; i < 5 ; i = i + 1 ) begin
//             for (j = 0; j < 4 ; j = j + 1 ) begin
//                 exp_max[i][j] <= exp_max[i][j];
//             end
//         end
//     end
// end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            nornolize[i] <= 0;
        end
    end
    else if (c_s == S_HEAD_1) begin
        nornolize[count_exp_out] <= test6_1;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            nornolize[i] <= nornolize[i];
        end
    end
end*/
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            nornolize_1[i] <= 0;
        end
    end
    else if (c_s == S_HEAD_2) begin
        nornolize_1[count_exp_out] <= test6_1;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            nornolize_1[i] <= nornolize_1[i];
        end
    end
end*/
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                score[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_FINAL) begin
        score[count_final_y][count_final_x] <= div_out;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                score[i][j] <= score[i][j];
            end
        end
    end
end*/
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                score_1[i][j] <= 0;
            end
        end
    end
    else if (c_s == S_FINAL) begin
        score_1[count_final_y][count_final_x] <= div_out_1;
    end
    else begin
        for (i = 0; i < 5 ; i = i + 1 ) begin
            for (j = 0; j < 5 ; j = j + 1 ) begin
                score_1[i][j] <= score_1[i][j];
            end
        end
    end
end */


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp_in <= 0;
    end
    else if (c_s == S_SCOR) begin
        exp_in <= div_out;
    end
    else exp_in <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_exp_out <= 0;
    end
    else if (c_s == S_HEAD_1 || c_s == S_HEAD_2) begin
        if (count_head <= 2) count_exp_out <= 0;
        else if (count_exp_out == 4) begin
            count_exp_out <= 0; 
        end
        else count_exp_out <= count_exp_out + 1;
    end
    else count_exp_out <= 0;
end

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         count_out <= 0;
//     end
//     else if (c_s == S_OUT) begin
//         count_out <= count_out + 1;
//     end
//     else if (c_s == S_LOAD) begin
//         count_out <= 0;
//     end
//     else count_out <= count_out;
// end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_head_out_x <= 0;
    end
    else if (c_s == S_EXP || c_s == S_EXP_1) begin
        if (count_exp < 3) begin
            count_head_out_x <= 0;
        end
        else begin
            if (count_head_out_x == 4) begin
                count_head_out_x <= 0;
            end
            else begin
                count_head_out_x <= count_head_out_x + 1;
            end            
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_head_out_y <= 0;
    end
    else if (c_s == S_EXP) begin
        if (count_exp < 3) begin
            count_head_out_y <= 0;
        end
        else begin
            if (count_head_out_x == 4) begin
                count_head_out_y <= count_head_out_y + 1;
            end
            else begin
                count_head_out_y <= count_head_out_y;
            end            
        end
    end
    else if (c_s == S_EXP_1) begin
        if (count_exp < 3) begin
            count_head_out_y <= 2;
        end
        else begin
            if (count_head_out_x == 4) begin
                count_head_out_y <= count_head_out_y + 1;
            end
            else begin
                count_head_out_y <= count_head_out_y;
            end            
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_out_max <= 0;
    end
    else if (c_s == S_OUT_MAX) begin
        count_out_max <= count_out_max + 1;
    end
    else if (c_s == S_LOAD) begin
        count_out_max <= 0;
    end
end
// ----------mult-------------
// ---------out_put---------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (c_s == S_OUT_MAX) begin
        if (count_out_max == 1 || count_out_max == 0) out_valid <= 0;
        else if (count_out_max == 22) out_valid <= 0;
        else out_valid <= 1;
    end
    else out_valid <= out_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 0;
    end
    else if (c_s == S_OUT_MAX) begin
        if (count_out_max == 1 || count_out_max == 0) out <= 0;
        else if (count_out_max == 22) out <= 0;
        else out <= test6;
    end
    else out <= out;
end
// ---------out_put---------------
endmodule
