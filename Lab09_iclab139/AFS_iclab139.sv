//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		dateseq.D		: 2025/4
//		Version		: v1.0
//   	File Name   : AFS.sv
//   	Module Name : AFS
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module AFS(input clk, INF.AFS_inf inf);
import usertype::*;
    //==============================================//
    //              logic declaration               //
    // ============================================ //

typedef enum logic [3:0]{
    S0_IDLE,
    S1_LOAD1,
    S2_PURCHASE,
    S3_RESOTCK,
    S4_CHECK_DATE,
    S5_READ_DRAM,
    S6_RESOTCK1,
    S7_WRITE_BACK_DRAM,
    S8_OUT,
    S9_CHECK_DATE1,
    S10_PURCHASE1,
    S11_PURCHASE2
} state_t;

typedef logic [3:0] Month;
typedef logic [4:0] Day;

typedef struct packed {
    Month M;
    Day D;
} Date; // Date

// FSM ============================================= FSM //
// REGISTERS
state_t state, nstate;
Date dateseq;
// ----------- INPUT ----------- //
logic [1:0]               actseq;
logic [2:0]         strategy_seq;
logic [1:0]             mode_seq;
logic [11:0]        rose_resotck;
logic [11:0]        lily_resotck;
logic [11:0]   carnation_resotck;
logic [11:0] baby_breath_resotck;
// ----------- INPUT ----------- //
// ----- state == s3 ------- //
logic [2:0] counter_resotck;

// ----- state == s3 ------- //
// ----------------- DRAM READ ---------------- //
logic [7:0] dram_addres;
logic flag_read;

logic [11:0]        rose_origin;
logic [11:0]        lily_origin;
logic [11:0]   carnation_origin;
logic [11:0] baby_breath_origin;
logic [4:0]          date_orgin;
logic [3:0]        mounth_orgin;
// ----------------- DRAM READ ---------------- //
logic [1:0] warning_temp;

logic [12:0]        rose_temp;
logic [12:0]        lily_temp;
logic [12:0]   carnation_temp;
logic [12:0] baby_breath_temp;

logic [11:0]        rose_temp_writeback;
logic [11:0]        lily_temp_writeback;
logic [11:0]   carnation_temp_writeback;
logic [11:0] baby_breath_temp_writeback;

logic [63:0] write_back_data;

logic [1:0] flag_resotck1;
// ------------- S11_PURCHASE2 -------- //
logic [11:0]        rose_need;
logic [11:0]        lily_need;
logic [11:0]   carnation_need;
logic [11:0] baby_breath_need;
// ------------- S11_PURCHASE2 -------- //
logic flag_s10;

// -------------- FSM ----------------- //
always_ff @( posedge clk or negedge inf.rst_n) begin : TOP_FSM_SEQ
    if (!inf.rst_n) state <= S0_IDLE;
    else state <= nstate;
end
always_comb begin : TOP_FSM_COMB
    case(state)
        S0_IDLE: begin
            if (inf.sel_action_valid) nstate = S1_LOAD1;
            else nstate = S0_IDLE;
        end
        S1_LOAD1 : begin
            if (inf.data_no_valid && actseq == 2'b00) begin
                nstate = S2_PURCHASE;
            end
            else if (inf.data_no_valid && actseq == 2'b01) begin
                nstate = S3_RESOTCK;
            end            
            else if (inf.data_no_valid && actseq == 2'b10) begin
                nstate = S4_CHECK_DATE;
            end
            else nstate = S1_LOAD1;
        end
        S2_PURCHASE : begin
            nstate = S5_READ_DRAM;
        end
        S3_RESOTCK : begin
            if (counter_resotck == 4) begin
                nstate = S5_READ_DRAM;
            end
            else nstate = S3_RESOTCK;
        end
        S4_CHECK_DATE : begin
            nstate = S5_READ_DRAM;
        end
        S5_READ_DRAM : begin
            if (inf.R_VALID && actseq == 2'b01) begin
                nstate = S6_RESOTCK1;
            end
            else if (inf.R_VALID && actseq == 2'b10) begin
                nstate = S9_CHECK_DATE1;
            end
            else if (inf.R_VALID && actseq == 2'b00) begin
                nstate = S10_PURCHASE1;
            end
            else nstate = S5_READ_DRAM;
        end
        S6_RESOTCK1 : begin
            if (flag_resotck1 == 2) begin
                nstate = S7_WRITE_BACK_DRAM;
            end
            else if (warning_temp == 2'b01) begin
                nstate = S8_OUT;    
            end
            else nstate = S6_RESOTCK1;
        end
        S7_WRITE_BACK_DRAM : begin
            if (inf.B_VALID) begin
                nstate = S8_OUT;
            end
            else nstate = S7_WRITE_BACK_DRAM;
        end
        S9_CHECK_DATE1 : begin
            nstate = S8_OUT;
        end
        S10_PURCHASE1 : begin
            if (warning_temp == 2'b01 && flag_s10) begin
                nstate = S8_OUT;
            end
            else if (warning_temp == 2'b10 && flag_s10) begin
                nstate = S8_OUT;
            end
            else if (warning_temp == 2'b00 && flag_s10) begin
                nstate = S11_PURCHASE2;
            end
            else nstate = S10_PURCHASE1;
        end
        S11_PURCHASE2 : begin
            if (flag_resotck1 == 1) begin
                nstate = S7_WRITE_BACK_DRAM;
            end
            else nstate = S11_PURCHASE2;
        end
        S8_OUT : begin
            nstate = S0_IDLE;
        end
        default: nstate = state;
    endcase
end
// -------------- FSM ----------------- //
// -------------- INPUT --------------- //
// acttion
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     actseq <= 0;
    // end
    // else if (inf.sel_action_valid)begin
    if (inf.sel_action_valid)begin
        actseq <= inf.D.d_act[0];
    end
    else actseq <= actseq;
end
// strategy_seq
always_ff@(posedge clk) begin
    // if (!inf.rst_n) begin
    //     strategy_seq <= 0;
    // end
    // else if (inf.strategy_valid) begin
    if (inf.strategy_valid) begin
        strategy_seq <= inf.D.d_strategy[0];
    end
    else strategy_seq <= strategy_seq;
end
// mode_seq
always_ff@(posedge clk) begin
    // if (!inf.rst_n) begin
    //     mode_seq <= 0;
    // end
    // else if (inf.mode_valid) begin
    if (inf.mode_valid) begin
        mode_seq <= inf.D.d_mode[0];
    end
    else mode_seq <= mode_seq;
end
// mounthy day from pattern
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     dateseq <= 0;
    // end
    // else if (inf.date_valid == 1)begin
    if (inf.date_valid == 1)begin
        dateseq <= inf.D.d_date[0];
    end
    else dateseq <= dateseq;
end
// DRAM ADDRES
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     dram_addres <= 0;
    // end
    // else if (inf.data_no_valid) begin
    if (inf.data_no_valid) begin
        dram_addres <= inf.D.d_data_no[0];
    end
    else dram_addres <= dram_addres;
end
// rose restock
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     rose_resotck <= 0;
    // end
    // else if (state == S3_RESOTCK) begin
    if (state == S3_RESOTCK) begin
        if (inf.restock_valid && counter_resotck == 0) begin
            rose_resotck <= inf.D.d_stock[0];
        end
        else rose_resotck <= rose_resotck;
    end
    else rose_resotck <= rose_resotck;
end
// lily restock
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     lily_resotck <= 0;
    // end
    // else if (state == S3_RESOTCK) begin
    if (state == S3_RESOTCK) begin
        if (inf.restock_valid && counter_resotck == 1) lily_resotck <= inf.D.d_stock[0];
        else lily_resotck <= lily_resotck;
    end
    else lily_resotck <= lily_resotck;
end
// carnation_resotck
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     carnation_resotck <= 0;
    // end
    // else if (state == S3_RESOTCK) begin
    if (state == S3_RESOTCK) begin
        if (inf.restock_valid && counter_resotck == 2) carnation_resotck <= inf.D.d_stock[0];
        else carnation_resotck <= carnation_resotck;
    end
    else carnation_resotck <= carnation_resotck;
end
// baby_breath_resotck
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     baby_breath_resotck <= 0;
    // end
    // else if (state == S3_RESOTCK) begin
    if (state == S3_RESOTCK) begin
        if (inf.restock_valid && counter_resotck == 3) baby_breath_resotck <= inf.D.d_stock[0];
        else baby_breath_resotck <= baby_breath_resotck;
    end
    else baby_breath_resotck <= baby_breath_resotck;
end
// -------------- INPUT --------------- //
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     counter_resotck <= 0;
    // end
    // else if (state == S3_RESOTCK) begin
    if (state == S3_RESOTCK) begin
        if (inf.restock_valid) begin
            counter_resotck <= counter_resotck + 1;
        end
        else counter_resotck <= counter_resotck;
    end
    else counter_resotck <= 0;
end
// --------------- DRAM --------------- //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        flag_read <= 0;
    end
    else if (state == S5_READ_DRAM) flag_read <= 1;
    else flag_read <= 0;
end
// ----------------- DRAM READ ---------------- //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) inf.AR_VALID <= 0;
    else if (state == S5_READ_DRAM) begin
        if (flag_read == 0) inf.AR_VALID <= 1;
        else if (inf.AR_READY) inf.AR_VALID <= 0;
        else inf.AR_VALID <= inf.AR_VALID;
    end
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) inf.R_READY <= 0;
    else if (inf.AR_READY && inf.AR_VALID) inf.R_READY <= 1;
    else if (inf.R_VALID) inf.R_READY <= 0;
    else inf.R_READY <= inf.R_READY;
end
assign inf.AR_ADDR = {6'b100000, dram_addres, 3'b000};
// ----------------- DRAM READ ---------------- //
// ----------------- DRAM READ OUT DATA ------- //
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     rose_origin <= 0;
    // end
    // else if (state == S5_READ_DRAM) begin
    if (state == S5_READ_DRAM) begin
        if (inf.R_VALID) rose_origin <= inf.R_DATA[63:52];
        else rose_origin <= rose_origin;
    end
    else rose_origin <= rose_origin;
end

always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     lily_origin <= 0;
    // end
    // else if (state == S5_READ_DRAM) begin
    if (state == S5_READ_DRAM) begin
        if (inf.R_VALID) lily_origin <= inf.R_DATA[51:40];
        else lily_origin <= lily_origin;
    end
    else lily_origin <= lily_origin;
end

always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     carnation_origin <= 0;
    // end
    // else if (state == S5_READ_DRAM) begin
    if (state == S5_READ_DRAM) begin
        if (inf.R_VALID) carnation_origin <= inf.R_DATA[31:20];
        else carnation_origin <= carnation_origin;
    end
    else carnation_origin <= carnation_origin;
end

always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     baby_breath_origin <= 0;
    // end
    // else if (state == S5_READ_DRAM) begin
    if (state == S5_READ_DRAM) begin
        if (inf.R_VALID) baby_breath_origin <= inf.R_DATA[19:8];
        else baby_breath_origin <= baby_breath_origin;
    end
    else baby_breath_origin <= baby_breath_origin;
end

always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     mounth_orgin <= 0;
    // end
    // else if (state == S5_READ_DRAM) begin
    if (state == S5_READ_DRAM) begin
        if (inf.R_VALID) mounth_orgin <= inf.R_DATA[39:32];
        else mounth_orgin <= mounth_orgin;
    end
    else mounth_orgin <= mounth_orgin;
end

always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     date_orgin <= 0;
    // end
    // else if (state == S5_READ_DRAM) begin
    if (state == S5_READ_DRAM) begin
        if (inf.R_VALID) date_orgin <= inf.R_DATA[4:0];
        else date_orgin <= date_orgin;
    end
    else date_orgin <= date_orgin;
end
// ----------------- DRAM READ OUT DATA ------- //
// -------------- DRAM WRITE --------------- //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        flag_resotck1 <= 0;
    end
    else if (state == S6_RESOTCK1) begin
        flag_resotck1 <= flag_resotck1 + 1;
    end
    else if (state == S11_PURCHASE2) begin
        flag_resotck1 <= flag_resotck1 + 1;
    end
    else flag_resotck1 <= 0;
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AW_VALID <= 0;
    end
    else if (state == S7_WRITE_BACK_DRAM) begin
        if (flag_resotck1) inf.AW_VALID <= 1;
        else if (inf.AW_READY) inf.AW_VALID <= 0;
        else inf.AW_VALID <= inf.AW_VALID;
    end
    else inf.AW_VALID <= inf.AW_VALID;
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AW_ADDR <= 0;
    end
    else if (state == S7_WRITE_BACK_DRAM) begin
        if (flag_resotck1) inf.AW_ADDR <= {6'b100000, dram_addres, 3'b000};
        else if (inf.AW_READY) inf.AW_ADDR <= 0;
        else inf.AW_ADDR <= inf.AW_ADDR;
    end
    else inf.AW_ADDR <= inf.AW_ADDR;
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.W_DATA <= 0;
    end
    else if (state == S7_WRITE_BACK_DRAM) begin
        if (inf.AW_READY && inf.AW_VALID) inf.W_DATA <= write_back_data;
        else inf.W_DATA <= inf.W_DATA;
    end
    else inf.W_DATA <= inf.W_DATA;
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.W_VALID <= 0;
    else if (inf.AW_VALID && inf.AW_READY) inf.W_VALID <= 1;
    else if (inf.W_READY) inf.W_VALID <= 0;
    else inf.W_VALID <= inf.W_VALID;
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) inf.B_READY <= 0;
    else if (inf.AW_VALID && inf.AW_READY) inf.B_READY <= 1;
    else if (inf.B_VALID) inf.B_READY <= 0;
    else inf.B_READY <= inf.B_READY;
end
// -------------- DRAM WRITE --------------- //
// ---------- warn_msg_temp -------------- //
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     warning_temp <= 0;
    // end
    // else if (state == S0_IDLE || state == S1_LOAD1) begin
    if (state == S0_IDLE || state == S1_LOAD1) begin
        warning_temp <= 0;
    end
    else if (actseq == 0) begin
        if (mounth_orgin > dateseq.M) begin
            warning_temp <= 2'b01;
        end
        else if (mounth_orgin == dateseq.M && date_orgin > dateseq.D) begin
            warning_temp <= 2'b01;
        end
        else if (rose_temp[12] || lily_temp[12] || carnation_temp[12] || baby_breath_temp[12]) begin
            warning_temp <= 2'b10;
        end
        else warning_temp <= 2'b00;
    end
    else if (actseq == 1) begin
        if (rose_temp[12] || lily_temp[12] || carnation_temp[12] || baby_breath_temp[12]) begin
            warning_temp <= 2'b11;
        end
        else warning_temp <= warning_temp;
    end
    else if (actseq == 2) begin
        if (mounth_orgin > dateseq.M) begin
            warning_temp <= 2'b01;
        end
        else if (mounth_orgin == dateseq.M && date_orgin > dateseq.D) begin
            warning_temp <= 2'b01;
        end
        else warning_temp <= 2'b00;
    end

    else warning_temp <= warning_temp;
end
// ---------- warn_msg_temp -------------- //
// ---------------- S6_RESOTCK1 ---------------- //
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     rose_temp <= 0;
    // end
    // else if (state == S0_IDLE) begin
    if (state == S0_IDLE) begin
        rose_temp <= 0;
    end
    else if (state == S6_RESOTCK1) begin
        if (warning_temp == 2'b01) begin
            rose_temp <= rose_origin;
        end
        else rose_temp <= rose_origin + rose_resotck;
    end
    else if (state == S11_PURCHASE2) begin
        rose_temp <= rose_origin - rose_need;
    end
    else rose_temp <= rose_temp;
end
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     lily_temp <= 0;
    // end
    // else if (state == S0_IDLE) begin
    if (state == S0_IDLE) begin
        lily_temp <= 0;
    end
    else if (state == S6_RESOTCK1) begin
        if (warning_temp == 2'b01) begin
            lily_temp <= lily_origin;
        end
        else lily_temp <= lily_origin + lily_resotck;
    end
    else if (state == S11_PURCHASE2) begin
        lily_temp <= lily_origin - lily_need;
    end
    else lily_temp <= lily_temp;
end
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     carnation_temp <= 0;
    // end
    // else if (state == S0_IDLE) begin
    if (state == S0_IDLE) begin
        carnation_temp <= 0;
    end
    else if (state == S6_RESOTCK1) begin
        if (warning_temp == 2'b01) begin
            carnation_temp <= carnation_origin;
        end
        else carnation_temp <= carnation_origin + carnation_resotck;
    end
    else if (state == S11_PURCHASE2) begin
        carnation_temp <= carnation_origin - carnation_need;
    end
    else carnation_temp <= carnation_temp;
end
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     baby_breath_temp <= 0;
    // end
    // else if (state == S0_IDLE) begin
    if (state == S0_IDLE) begin
        baby_breath_temp <= 0;
    end
    else if (state == S6_RESOTCK1) begin
        if (warning_temp == 2'b01) begin
            baby_breath_temp <= baby_breath_origin;
        end
        else baby_breath_temp <= baby_breath_origin + baby_breath_resotck;
    end
    else if (state == S11_PURCHASE2) begin
        baby_breath_temp <= baby_breath_origin - baby_breath_need;
    end
    else baby_breath_temp <= baby_breath_temp;
end


assign        rose_temp_writeback = (       rose_temp[12]) ? 4095 :        rose_temp;
assign        lily_temp_writeback = (       lily_temp[12]) ? 4095 :        lily_temp;
assign   carnation_temp_writeback = (  carnation_temp[12]) ? 4095 :   carnation_temp;
assign baby_breath_temp_writeback = (baby_breath_temp[12]) ? 4095 : baby_breath_temp;

// ---------------- S6_RESOTCK1 ---------------- //
always_ff @(posedge clk) begin
    // if (!inf.rst_n) begin
    //     write_back_data <= 0;
    // end
    // else if (state == S7_WRITE_BACK_DRAM) begin
    if (state == S7_WRITE_BACK_DRAM) begin
        if (actseq == 0) begin 
            if (warning_temp == 0) write_back_data <= {rose_temp_writeback,lily_temp_writeback,4'b0000,mounth_orgin,carnation_temp_writeback,baby_breath_temp_writeback,3'b000,date_orgin};
            else write_back_data <= {rose_origin,lily_origin,4'b0000,mounth_orgin,carnation_origin,baby_breath_origin,3'b000,date_orgin};
        end
        else if (actseq == 1) write_back_data <= {rose_temp_writeback,lily_temp_writeback,4'b0000,dateseq.M,carnation_temp_writeback,baby_breath_temp_writeback,3'b000,dateseq.D};
    end
    else write_back_data <= write_back_data;
end
// ---------------- S11_PURCHASE2 ----------------- //
always_ff@(posedge clk)begin
    // if (!inf.rst_n) begin
    //     flag_s10 <= 0;
    // end
    // else if (state == S10_PURCHASE1) begin
    if (state == S10_PURCHASE1) begin
        flag_s10 <= 1;
    end
    else flag_s10 <= 0;
end

always_ff @(posedge clk)begin
    // if (!inf.rst_n) begin
    //     rose_need <= 0;
    // end
    // else if (state == S11_PURCHASE2) begin
    if (state == S11_PURCHASE2) begin
        if (mode_seq == 0) begin
            case (strategy_seq)
                0: rose_need <= 120;
                1: rose_need <= 0;
                2: rose_need <= 0;
                3: rose_need <= 0;
                4: rose_need <= 60;
                5: rose_need <= 0;
                6: rose_need <= 60;
                7: rose_need <= 30;
                default: rose_need <= rose_need;
            endcase
        end
        if (mode_seq == 1) begin
            case (strategy_seq)
                0: rose_need <= 480;
                1: rose_need <= 0;
                2: rose_need <= 0;
                3: rose_need <= 0;
                4: rose_need <= 240;
                5: rose_need <= 0;
                6: rose_need <= 240;
                7: rose_need <= 120;
                default: rose_need <= rose_need;
            endcase
        end
        if (mode_seq == 3) begin
            case (strategy_seq)
                0: rose_need <= 960;
                1: rose_need <= 0;
                2: rose_need <= 0;
                3: rose_need <= 0;
                4: rose_need <= 480;
                5: rose_need <= 0;
                6: rose_need <= 480;
                7: rose_need <= 240;
                default: rose_need <= rose_need;
            endcase
        end
    end
end

always_ff @(posedge clk)begin
    // if (!inf.rst_n) begin
    //     lily_need <= 0;
    // end
    // else if (state == S11_PURCHASE2) begin
    if (state == S11_PURCHASE2) begin
        if (mode_seq == 0) begin
            case (strategy_seq)
                0: lily_need <= 0;
                1: lily_need <= 120;
                2: lily_need <= 0;
                3: lily_need <= 0;
                4: lily_need <= 60;
                5: lily_need <= 0;
                6: lily_need <= 0;
                7: lily_need <= 30;
                default: lily_need <= lily_need;
            endcase
        end
        if (mode_seq == 1) begin
            case (strategy_seq)
                0: lily_need <= 0;
                1: lily_need <= 480;
                2: lily_need <= 0;
                3: lily_need <= 0;
                4: lily_need <= 240;
                5: lily_need <= 0;
                6: lily_need <= 0;
                7: lily_need <= 120;
                default: lily_need <= lily_need;
            endcase
        end
        if (mode_seq == 3) begin
            case (strategy_seq)
                0: lily_need <= 0;
                1: lily_need <= 960;
                2: lily_need <= 0;
                3: lily_need <= 0;
                4: lily_need <= 480;
                5: lily_need <= 0;
                6: lily_need <= 0;
                7: lily_need <= 240;
                default: lily_need <= lily_need;
            endcase
        end
    end
end

always_ff @(posedge clk)begin
    // if (!inf.rst_n) begin
    //     carnation_need <= 0;
    // end
    // else if (state == S11_PURCHASE2) begin
    if (state == S11_PURCHASE2) begin
        if (mode_seq == 0) begin
            case (strategy_seq)
                0: carnation_need <= 0;
                1: carnation_need <= 0;
                2: carnation_need <= 120;
                3: carnation_need <= 0;
                4: carnation_need <= 0;
                5: carnation_need <= 60;
                6: carnation_need <= 60;
                7: carnation_need <= 30;
                default: carnation_need <= carnation_need;
            endcase
        end
        if (mode_seq == 1) begin
            case (strategy_seq)
                0: carnation_need <= 0;
                1: carnation_need <= 0;
                2: carnation_need <= 480;
                3: carnation_need <= 0;
                4: carnation_need <= 0;
                5: carnation_need <= 240;
                6: carnation_need <= 240;
                7: carnation_need <= 120;
                default: carnation_need <= carnation_need;
            endcase
        end
        if (mode_seq == 3) begin
            case (strategy_seq)
                0: carnation_need <= 0;
                1: carnation_need <= 0;
                2: carnation_need <= 960;
                3: carnation_need <= 0;
                4: carnation_need <= 0;
                5: carnation_need <= 480;
                6: carnation_need <= 480;
                7: carnation_need <= 240;
                default: carnation_need <= carnation_need;
            endcase
        end
    end
end

always_ff @(posedge clk)begin
    // if (!inf.rst_n) begin
    //     baby_breath_need <= 0;
    // end
    // else if (state == S11_PURCHASE2) begin
    if (state == S11_PURCHASE2) begin
        if (mode_seq == 0) begin
            case (strategy_seq)
                0: baby_breath_need <= 0;
                1: baby_breath_need <= 0;
                2: baby_breath_need <= 0;
                3: baby_breath_need <= 120;
                4: baby_breath_need <= 0;
                5: baby_breath_need <= 60;
                6: baby_breath_need <= 0;
                7: baby_breath_need <= 30;
                default: baby_breath_need <= baby_breath_need;
            endcase
        end
        if (mode_seq == 1) begin
            case (strategy_seq)
                0: baby_breath_need <= 0;
                1: baby_breath_need <= 0;
                2: baby_breath_need <= 0;
                3: baby_breath_need <= 480;
                4: baby_breath_need <= 0;
                5: baby_breath_need <= 240;
                6: baby_breath_need <= 0;
                7: baby_breath_need <= 120;
                default: baby_breath_need <= baby_breath_need;
            endcase
        end
        if (mode_seq == 3) begin
            case (strategy_seq)
                0: baby_breath_need <= 0;
                1: baby_breath_need <= 0;
                2: baby_breath_need <= 0;
                3: baby_breath_need <= 960;
                4: baby_breath_need <= 0;
                5: baby_breath_need <= 480;
                6: baby_breath_need <= 0;
                7: baby_breath_need <= 240;
                default: baby_breath_need <= baby_breath_need;
            endcase
        end
    end
end
// ---------------- S11_PURCHASE2 ----------------- //

// ---------------- OUT DATA -------------- //
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
    end
    else if (state == S8_OUT) begin
        inf.out_valid <= 1;
    end
    else begin
        inf.out_valid <= 0;
    end 
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.warn_msg <= 0;
    end
    else if (state == S8_OUT) begin
        inf.warn_msg <= warning_temp;
    end
    else begin
        inf.warn_msg <= 0;
    end 
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.complete <= 0;
    end
    else if (state == S8_OUT) begin
        inf.complete <= (warning_temp == 0) ? 1 : 0;
    end
    else begin
        inf.complete <= 0;
    end 
end
endmodule



