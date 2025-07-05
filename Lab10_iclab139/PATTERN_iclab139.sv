/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2025 Spring IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: April-2025)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"
`define PATNUM 6000

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter DRAM_p_w = "../00_TESTBED/DRAM/output_dram.dat";
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box

integer i, j, latency, total_latency, i_pat, t;
Date date;

logic [3:0] today_mouth;
logic [4:0] today_day;

logic [11:0] rose_restock       ;
logic [11:0] lily_restock       ;
logic [11:0] carnation_restock  ;
logic [11:0] Baby_Breath_restock;

logic [11:0] golden_rose       ;
logic [11:0] golden_lily       ;
logic [11:0] golden_carnation  ;
logic [11:0] golden_Baby_Breath;

logic [11:0] golden_month      ;
logic [11:0] golden_day        ;

logic [12:0] golden_rose_restock       ;
logic [12:0] golden_lily_restock       ;
logic [12:0] golden_carnation_restock  ;
logic [12:0] golden_Baby_Breath_restock;

logic [12:0] golden_rose_used       ;
logic [12:0] golden_lily_used       ;
logic [12:0] golden_carnation_used  ;
logic [12:0] golden_Baby_Breath_used;

parameter rose_100_rose_s = 120;
parameter rose_100_rose_g = 480;
parameter rose_100_rose_e = 960;

parameter lily_100_lily_s = 120;
parameter lily_100_lily_g = 480;
parameter lily_100_lily_e = 960;

parameter carnation_100_carnation_s = 120;
parameter carnation_100_carnation_g = 480;
parameter carnation_100_carnation_e = 960;

parameter baby_breath_100_baby_breath_s = 120;
parameter baby_breath_100_baby_breath_g = 480;
parameter baby_breath_100_baby_breath_e = 960;

parameter rose_50_lily_50_rose_s =  60;
parameter rose_50_lily_50_rose_g = 240;
parameter rose_50_lily_50_rose_e = 480;

parameter rose_50_lily_50_lily_s =  60;
parameter rose_50_lily_50_lily_g = 240;
parameter rose_50_lily_50_lily_e = 480;

parameter carnation_50_baby_breath_50_carnation_s =  60;
parameter carnation_50_baby_breath_50_carnation_g = 240;
parameter carnation_50_baby_breath_50_carnation_e = 480;

parameter carnation_50_baby_breath_50_baby_breath_s =  60;
parameter carnation_50_baby_breath_50_baby_breath_g = 240;
parameter carnation_50_baby_breath_50_baby_breath_e = 480;

parameter rose_50_carnation_50_rose_s =  60;
parameter rose_50_carnation_50_rose_g = 240;
parameter rose_50_carnation_50_rose_e = 480;

parameter rose_50_carnation_50_carnation_s =  60;
parameter rose_50_carnation_50_carnation_g = 240;
parameter rose_50_carnation_50_carnation_e = 480;

parameter all_rose_s  =  30;
parameter all_rose_g  = 120;
parameter all_rose_e  = 240;

parameter all_lily_s  =  30;
parameter all_lily_g  = 120;
parameter all_lily_e  = 240;

parameter all_carnation_s  =  30;
parameter all_carnation_g  = 120;
parameter all_carnation_e  = 240;

parameter all_baby_breath_s  =  30;
parameter all_baby_breath_g  = 120;
parameter all_baby_breath_e  = 240;

logic golden_complete;
logic [1:0] golden_err_msg;

logic [20:0] pat_num_count;

Action input_action;
Strategy_Type flowertype;
Mode mode_input;
//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    randc Action act_id;
    constraint range{
        act_id inside{Purchase, Restock, Check_Valid_Date};
    }
    function void set_seed(int seed);
        
        this.srandom(seed);
    endfunction
endclass
/**
 * Class representing a random box from 0 to 31.
 */
class random_data;
    randc logic [7:0] dataid;
    constraint range{
        // dataid inside{[0:5]};
        dataid inside{[0:255]};
    }
endclass
/**
 * Class representing a random strategy type.
 */
class random_strategy;
    randc Strategy_Type strategy;
    constraint range{
        strategy inside{ Strategy_A,
                         Strategy_B,
                         Strategy_C,
                         Strategy_D,
                         Strategy_E,
                         Strategy_F,
                         Strategy_G,
                         Strategy_H};
    }
endclass
/**
 * Class representing a random bev type.
 */
class random_mode;
    randc Mode mode;
    constraint range{
        mode inside{Single     ,
                    Group_Order,
                    Event      };
    }
endclass

//================================================================
// initial
//================================================================

// initial $readmemh(DRAM_p_r, golden_DRAM);
random_act            act_rand;
random_strategy  strategy_rand;
random_mode          mode_rand;
random_data          data_rand;
initial begin 
    $readmemh(DRAM_p_r, golden_DRAM);
    act_rand      = new();
    strategy_rand = new();
    mode_rand     = new();
    data_rand     = new();

    golden_complete = 'b0;
    golden_err_msg = 2'b0;
    total_latency = 0;
	reset_signal_task;
    pat_num_count = 0;
    t = $urandom_range(0, 3);
    repeat(t) @(negedge clk);
    for(i_pat = 0; i_pat < `PATNUM; i_pat = i_pat + 1) begin
		input_task;
        check_ans_task;
        wait_out_valid_task;
		$display ("\033[0;38;5;219mPass Pattern NO. %d  latency = %d ACT = Action\033[m", i_pat, latency, input_action);
        pat_num_count = pat_num_count + 1;
        repeat($urandom_range(0,3)) @(negedge clk);
	end
    $writememh(DRAM_p_w, golden_DRAM);
	pass_task;
end
// check 
task reset_signal_task; 
  begin 
    inf.rst_n = 1;
    #(0.5);  inf.rst_n <= 0;
	inf.D 	       = 'bx;
    inf.sel_action_valid = 0;
    inf.strategy_valid = 0; 
    inf.mode_valid = 0; 
    inf.date_valid = 0; 
    inf.data_no_valid = 0; 
    inf.restock_valid = 0;
	#(5);
    #(10);  inf.rst_n <= 1;
  end 
endtask

// input task ========================= input task //
task input_task;
    begin
    repeat(1) @(negedge clk);
    inf.sel_action_valid = 'b1;
    act_rand.randomize();

    if (pat_num_count < 2400) begin
        input_action = Purchase;
    end
    else if (i_pat >= 2400 && i_pat <= 2700) begin
        input_action = Restock;
    end
    else if (i_pat >= 2700 && i_pat <= 3000) begin
        input_action = Check_Valid_Date;
    end
    else input_action = act_rand.act_id;
    
    inf.D = input_action;
    @(negedge clk);
    inf.sel_action_valid = 'b0;
    inf.D = 'bx;
    repeat($urandom_range(0, 3)) @(negedge clk);
        if (input_action == Purchase) begin
            purchase_task;
        end
        else if (input_action == Restock) begin
            restock_task;
        end
        else if (input_action == Check_Valid_Date) begin
            check_valid_day_task;
        end
    end
endtask
// input task ========================= input task //

task purchase_task ;
    begin
        inf.strategy_valid = 'b1;
        strategy_rand.randomize();

        if (i_pat <= 299) begin
            flowertype = Strategy_A;
        end
        else if (i_pat >= 300 && i_pat <= 599) begin
            flowertype = Strategy_B;
        end
        else if (i_pat >= 600 && i_pat <= 899) begin
            flowertype = Strategy_C;
        end
        else if (i_pat >= 900 && i_pat <= 1199) begin
            flowertype = Strategy_D;
        end
        else if (i_pat >= 1200 && i_pat <= 1499) begin
            flowertype = Strategy_E;
        end
        else if (i_pat >= 1500 && i_pat <= 1799) begin
            flowertype = Strategy_F;
        end
        else if (i_pat >= 1800 && i_pat <= 2099) begin
            flowertype = Strategy_G;
        end
        else if (i_pat >= 2100 && i_pat <= 2399) begin
            flowertype = Strategy_H;
        end
        else begin
            flowertype = strategy_rand.strategy;            
        end
        
        inf.D = flowertype;
        @(negedge clk);
        inf.strategy_valid = 'b0;
        inf.D = 'bx;
        repeat(3) @(negedge clk);
        

        inf.mode_valid = 'b1;
        mode_rand.randomize();
        if (i_pat <= 99) begin
            mode_input = Single;
        end
        else if (i_pat >= 100 && i_pat <= 199) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 200 && i_pat <= 299) begin
            mode_input = Event;
        end
        else if (i_pat >= 300 && i_pat <= 399) begin
            mode_input = Single;
        end
        else if (i_pat >= 400 && i_pat <= 499) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 500 && i_pat <= 599) begin
            mode_input = Event;
        end
        else if (i_pat >= 600 && i_pat <= 699) begin
            mode_input = Single;
        end
        else if (i_pat >= 700 && i_pat <= 799) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 800 && i_pat <= 899) begin
            mode_input = Event;
        end
        else if (i_pat >= 900 && i_pat <= 999) begin
            mode_input = Single;
        end
        else if (i_pat >= 1000 && i_pat <= 1099) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 1100 && i_pat <= 1199) begin
            mode_input = Event;
        end
        else if (i_pat >= 1200 && i_pat <= 1299) begin
            mode_input = Single;
        end
        else if (i_pat >= 1300 && i_pat <= 1399) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 1400 && i_pat <= 1499) begin
            mode_input = Event;
        end
        else if (i_pat >= 1500 && i_pat <= 1599) begin
            mode_input = Single;
        end
        else if (i_pat >= 1600 && i_pat <= 1699) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 1700 && i_pat <= 1799) begin
            mode_input = Event;
        end
        else if (i_pat >= 1800 && i_pat <= 1899) begin
            mode_input = Single;
        end
        else if (i_pat >= 1900 && i_pat <= 1999) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 2000 && i_pat <= 2099) begin
            mode_input = Event;
        end
        else if (i_pat >= 2100 && i_pat <= 2199) begin
            mode_input = Single;
        end
        else if (i_pat >= 2200 && i_pat <= 2299) begin
            mode_input = Group_Order;
        end
        else if (i_pat >= 2300 && i_pat <= 2399) begin
            mode_input = Event;
        end
        else mode_input = mode_rand.mode;
        
        inf.D = mode_input;
        @(negedge clk);
        inf.mode_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);    
        
        date_task;

        data_task;
        repeat(t) @(negedge clk);
    end
endtask
// supply_task ============ supply_task //
task restock_task ;
    begin
        // date 
        date_task;

        // data_no_valid
        data_task;
        // inf.data_no_valid = 'b1;
        // data_rand.randomize();
        // inf.D = data_rand.dataid;
        // @(negedge clk);
        // inf.data_no_valid = 'b0;
        // inf.D = 'bx;
        repeat(t) @(negedge clk);

        // restock_valid
        // rose
        inf.restock_valid = 'b1;
        rose_restock = $urandom_range(0, 4095);
        inf.D = rose_restock;
        @(negedge clk);
        inf.restock_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);

        // lily
        inf.restock_valid = 'b1;
        lily_restock = $urandom_range(0, 4095);
        inf.D = lily_restock;
        @(negedge clk);
        inf.restock_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);

        // carnation
        inf.restock_valid = 'b1;
        carnation_restock = $urandom_range(0, 4095);
        inf.D = carnation_restock;
        @(negedge clk);
        inf.restock_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);

        // Baby_Breath 
        inf.restock_valid = 'b1;
        Baby_Breath_restock = $urandom_range(0, 4095);
        inf.D = Baby_Breath_restock;
        @(negedge clk);
        inf.restock_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);
    end
endtask

// check_valid_day_task ============ check_valid_day_task //
task check_valid_day_task ;
    begin
        // date 
        date_task;
        // box_no_valid
        // inf.data_no_valid = 'b1;
        // data_rand.randomize();
        // inf.D = data_rand.dataid;
        // @(negedge clk);
        // inf.data_no_valid = 'b0;
        // inf.D = 'bx;
        data_task;
    end
endtask
// check_valid_day_task ============ check_valid_day_task //

// supply_task ============ supply_task //
task wait_out_valid_task;
    begin
    latency = -1;
    while(inf.out_valid !== 1'b1) begin
        latency = latency + 1;
        if(latency == 1000) begin
            $display("*************************************************************************");
            $display("        \033[0;38;5;219mfail pattern: %d\033[m                           ", i_pat);
            $display("             The execution latency is limited in 1000 cycle              ");
            $display("*************************************************************************");
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
    end
endtask

task check_ans_task ;
    begin
        golden_rose        = {golden_DRAM[65536 + 7 + (data_rand.dataid * 8)],      golden_DRAM[65536 + 6 + (data_rand.dataid * 8)][7:4]};
        golden_lily        = {golden_DRAM[65536 + 6 + (data_rand.dataid * 8)][3:0], golden_DRAM[65536 + 5 + (data_rand.dataid * 8)]};
        golden_carnation   = {golden_DRAM[65536 + 3 + (data_rand.dataid * 8)],      golden_DRAM[65536 + 2 + (data_rand.dataid * 8)][7:4]};
        golden_Baby_Breath = {golden_DRAM[65536 + 2 + (data_rand.dataid * 8)][3:0], golden_DRAM[65536 + 1 + (data_rand.dataid * 8)]};
        golden_month       = {golden_DRAM[65536 + 4 + (data_rand.dataid * 8)]};
        golden_day         = {golden_DRAM[65536 +     (data_rand.dataid * 8)]};
    end
    if (input_action == Purchase) begin
        check_day_purchase_task;
        repeat(1) @(negedge clk);
        check_ans_purchase_task;
        if (golden_err_msg == 2'b00) begin
            check_inf_purchase_task;
        end
    end
    if (input_action == Restock) begin
        check_ans_restock_task;
    end
    if (input_action == Check_Valid_Date) begin
        check_ans_cvd_task;
    end
endtask

initial begin
	forever@(posedge clk)begin
		if(inf.out_valid)begin
		    @(negedge clk);
			if((inf.warn_msg !== golden_err_msg)||(inf.complete !== golden_complete))
            begin
            $display ("--------------------------------------------------------------------------------------------");
            $display ("                               Wrong Answer                                                 ");
            $display ("                               \033[0;38;5;219mWrong Answer\033[m                           ");
            $display ("--------------------------------------------------------------------------------------------");
            repeat(4) @(negedge clk);
            $finish;
			end
		end
	end
end


task check_day_purchase_task;
    begin
        if ((today_mouth < golden_month) || (today_mouth == golden_month && today_day < golden_day)) begin
            golden_err_msg = 2'b01;
            golden_complete = 'b0;
        end
        else begin 
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end
    end
endtask

task check_ans_purchase_task;
    begin
        if (golden_err_msg == 2'b00) begin
            case (flowertype)
                0 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose        - rose_100_rose_s;
                        golden_lily_used        = golden_lily                         ;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose        - rose_100_rose_g;
                        golden_lily_used        = golden_lily                         ;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose        - rose_100_rose_e;
                        golden_lily_used        = golden_lily                         ;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                end  
                1 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose                         ;
                        golden_lily_used        = golden_lily        - lily_100_lily_s;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose                  ;
                        golden_lily_used        = golden_lily - lily_100_lily_g;
                        golden_carnation_used   = golden_carnation             ;
                        golden_Baby_Breath_used = golden_Baby_Breath           ;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose                  ;
                        golden_lily_used        = golden_lily - lily_100_lily_e;
                        golden_carnation_used   = golden_carnation             ;
                        golden_Baby_Breath_used = golden_Baby_Breath           ;
                    end
                end  
                2 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose                                 ;
                        golden_lily_used        = golden_lily                                 ;
                        golden_carnation_used   = golden_carnation - carnation_100_carnation_s;
                        golden_Baby_Breath_used = golden_Baby_Breath                          ;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose                                 ;
                        golden_lily_used        = golden_lily                                 ;
                        golden_carnation_used   = golden_carnation - carnation_100_carnation_g;
                        golden_Baby_Breath_used = golden_Baby_Breath                          ;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose                                 ;
                        golden_lily_used        = golden_lily                                 ;
                        golden_carnation_used   = golden_carnation - carnation_100_carnation_e;
                        golden_Baby_Breath_used = golden_Baby_Breath                          ;
                    end
                end  
                3 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose                                       ;
                        golden_lily_used        = golden_lily                                       ;
                        golden_carnation_used   = golden_carnation                                  ;
                        golden_Baby_Breath_used = golden_Baby_Breath - baby_breath_100_baby_breath_s;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose                                       ;
                        golden_lily_used        = golden_lily                                       ;
                        golden_carnation_used   = golden_carnation                                  ;
                        golden_Baby_Breath_used = golden_Baby_Breath - baby_breath_100_baby_breath_g;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose                                       ;
                        golden_lily_used        = golden_lily                                       ;
                        golden_carnation_used   = golden_carnation                                  ;
                        golden_Baby_Breath_used = golden_Baby_Breath - baby_breath_100_baby_breath_e;
                    end
                end  
                4 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose - rose_50_lily_50_rose_s;
                        golden_lily_used        = golden_lily - rose_50_lily_50_lily_s;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose - rose_50_lily_50_rose_g;
                        golden_lily_used        = golden_lily - rose_50_lily_50_lily_g;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose - rose_50_lily_50_rose_e;
                        golden_lily_used        = golden_lily - rose_50_lily_50_lily_e;
                        golden_carnation_used   = golden_carnation                    ;
                        golden_Baby_Breath_used = golden_Baby_Breath                  ;
                    end
                end  
                5 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose                                                   ;
                        golden_lily_used        = golden_lily                                                   ;
                        golden_carnation_used   = golden_carnation   -   carnation_50_baby_breath_50_carnation_s;
                        golden_Baby_Breath_used = golden_Baby_Breath - carnation_50_baby_breath_50_baby_breath_s;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose                                                   ;
                        golden_lily_used        = golden_lily                                                   ;
                        golden_carnation_used   = golden_carnation   -   carnation_50_baby_breath_50_carnation_g;
                        golden_Baby_Breath_used = golden_Baby_Breath - carnation_50_baby_breath_50_baby_breath_g;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose                                                   ;
                        golden_lily_used        = golden_lily                                                   ;
                        golden_carnation_used   = golden_carnation   -   carnation_50_baby_breath_50_carnation_e;
                        golden_Baby_Breath_used = golden_Baby_Breath - carnation_50_baby_breath_50_baby_breath_e;
                    end
                end  
                6 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose -           rose_50_carnation_50_rose_s;
                        golden_lily_used        = golden_lily                                        ;
                        golden_carnation_used   = golden_carnation - rose_50_carnation_50_carnation_s;
                        golden_Baby_Breath_used = golden_Baby_Breath                                 ;
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose -           rose_50_carnation_50_rose_g;
                        golden_lily_used        = golden_lily                                        ;
                        golden_carnation_used   = golden_carnation - rose_50_carnation_50_carnation_g;
                        golden_Baby_Breath_used = golden_Baby_Breath                                 ;
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose -           rose_50_carnation_50_rose_e;
                        golden_lily_used        = golden_lily                                        ;
                        golden_carnation_used   = golden_carnation - rose_50_carnation_50_carnation_e;
                        golden_Baby_Breath_used = golden_Baby_Breath                                 ;
                    end
                end  
                7 : begin
                    if (mode_input == 0) begin
                        golden_rose_used        = golden_rose        -        all_rose_s;
                        golden_lily_used        = golden_lily        -        all_lily_s;
                        golden_carnation_used   = golden_carnation   -   all_carnation_s;
                        golden_Baby_Breath_used = golden_Baby_Breath - all_baby_breath_s;                   
                    end
                    else if (mode_input == 1) begin
                        golden_rose_used        = golden_rose        -        all_rose_g;
                        golden_lily_used        = golden_lily        -        all_lily_g;
                        golden_carnation_used   = golden_carnation   -   all_carnation_g;
                        golden_Baby_Breath_used = golden_Baby_Breath - all_baby_breath_g;                      
                    end
                    else if (mode_input == 3) begin
                        golden_rose_used        = golden_rose        -        all_rose_e;
                        golden_lily_used        = golden_lily        -        all_lily_e;
                        golden_carnation_used   = golden_carnation   -   all_carnation_e;
                        golden_Baby_Breath_used = golden_Baby_Breath - all_baby_breath_e;                   
                    end
                end  
            endcase 
                @(negedge clk);
                golden_DRAM[65536 + 7 + (8 * data_rand.dataid)]      = golden_rose_used[11:4];
                golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][7:4] = golden_rose_used[3:0];

                golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][3:0] = golden_lily_used[11:8];
                golden_DRAM[65536 + 5 + (8 * data_rand.dataid)]      = golden_lily_used[7:0];

                golden_DRAM[65536 + 3 + (8 * data_rand.dataid)]      = golden_carnation_used[11:4];
                golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][7:4] = golden_carnation_used[3:0];

                golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][3:0] = golden_Baby_Breath_used[11:8];
                golden_DRAM[65536 + 1 + (8 * data_rand.dataid)]      = golden_Baby_Breath_used[7:0];
        end
        else if (golden_err_msg == 2'b01) begin
            golden_rose_used        = golden_rose       ;
            golden_lily_used        = golden_lily       ;
            golden_carnation_used   = golden_carnation  ;
            golden_Baby_Breath_used = golden_Baby_Breath;

            golden_DRAM[65536 + 7 + (8 * data_rand.dataid)]      = golden_rose_used[11:4];
            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][7:4] = golden_rose_used[3:0];

            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][3:0] = golden_lily_used[11:8];
            golden_DRAM[65536 + 5 + (8 * data_rand.dataid)]      = golden_lily_used[7:0];

            golden_DRAM[65536 + 3 + (8 * data_rand.dataid)]      = golden_carnation_used[11:4];
            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][7:4] = golden_carnation_used[3:0];

            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][3:0] = golden_Baby_Breath_used[11:8];
            golden_DRAM[65536 + 1 + (8 * data_rand.dataid)]      = golden_Baby_Breath_used[7:0];
        end
    end
endtask 

task check_inf_purchase_task;
    begin
        if (golden_rose_used > 4095 || golden_lily_used > 4095 || golden_carnation_used > 4095 || golden_Baby_Breath_used > 4095) begin
            golden_err_msg = 2'b10;
            golden_complete = 'b0;
        end
        else begin 
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end
        if (golden_err_msg == 2'b10) begin
            golden_rose_used        = golden_rose       ;
            golden_lily_used        = golden_lily       ;
            golden_carnation_used   = golden_carnation  ;
            golden_Baby_Breath_used = golden_Baby_Breath;
 
            golden_DRAM[65536 + 7 + (8 * data_rand.dataid)]      = golden_rose_used[11:4];
            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][7:4] = golden_rose_used[3:0];

            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][3:0] = golden_lily_used[11:8];
            golden_DRAM[65536 + 5 + (8 * data_rand.dataid)]      = golden_lily_used[7:0];

            golden_DRAM[65536 + 3 + (8 * data_rand.dataid)]      = golden_carnation_used[11:4];
            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][7:4] = golden_carnation_used[3:0];

            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][3:0] = golden_Baby_Breath_used[11:8];
            golden_DRAM[65536 + 1 + (8 * data_rand.dataid)]      = golden_Baby_Breath_used[7:0];
        end
    end
endtask

task check_ans_cvd_task ;
    begin
        if ((today_mouth < golden_month) || (today_mouth == golden_month && today_day < golden_day)) begin
            golden_err_msg = 2'b01;
            golden_complete = 'b0;
        end
        else begin
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end
    end
endtask

task check_ans_restock_task;
    begin
        golden_rose_restock       = golden_rose        +        rose_restock;
        golden_lily_restock       = golden_lily        +        lily_restock;
        golden_carnation_restock  = golden_carnation   +   carnation_restock;
        golden_Baby_Breath_restock= golden_Baby_Breath + Baby_Breath_restock;
        if (golden_rose_restock[12] || golden_lily_restock[12] || golden_carnation_restock[12] || golden_Baby_Breath_restock[12]) begin
            golden_err_msg = 2'b11;
            golden_complete = 'b0;
        end
        else begin
            golden_err_msg = 2'b00;
            golden_complete = 'b1;
        end

        golden_DRAM[65536 + 4 + (8 * data_rand.dataid)] = today_mouth;
        golden_DRAM[65536 + 0 + (8 * data_rand.dataid)] = today_day;

        if (golden_rose_restock > 4095) begin
            golden_DRAM[65536 + 7 + (8 * data_rand.dataid)]      = 8'b1111_1111;
            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][7:4] = 4'b1111;
        end
        else begin
            golden_DRAM[65536 + 7 + (8 * data_rand.dataid)]      = golden_rose_restock[11:4];
            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][7:4] = golden_rose_restock[3:0];
        end

        if (golden_lily_restock > 4095) begin
            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][3:0] = 4'b1111;
            golden_DRAM[65536 + 5 + (8 * data_rand.dataid)]      = 8'b1111_1111;
        end
        else begin
            golden_DRAM[65536 + 6 + (8 * data_rand.dataid)][3:0] = golden_lily_restock[11:8];
            golden_DRAM[65536 + 5 + (8 * data_rand.dataid)]      = golden_lily_restock[7:0];
        end

        if (golden_carnation_restock > 4095) begin
            golden_DRAM[65536 + 3 + (8 * data_rand.dataid)]      = 8'b1111_1111;
            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][7:4] = 4'b1111;
        end
        else begin
            golden_DRAM[65536 + 3 + (8 * data_rand.dataid)]      = golden_carnation_restock[11:4];
            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][7:4] = golden_carnation_restock[3:0];
        end

        if (golden_Baby_Breath_restock > 4095) begin
            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][3:0] = 4'b1111;
            golden_DRAM[65536 + 1 + (8 * data_rand.dataid)]      = 8'b1111_1111;
        end
        else begin
            golden_DRAM[65536 + 2 + (8 * data_rand.dataid)][3:0] = golden_Baby_Breath_restock[11:8];
            golden_DRAM[65536 + 1 + (8 * data_rand.dataid)]      = golden_Baby_Breath_restock[7:0];
        end
    end
endtask

task date_task; 
begin
        date.M = $urandom_range(1, 12);
        if (date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 || date.M == 10 || date.M == 12) begin
            date.D = $urandom_range(1,31);
        end
        if (date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) begin
            date.D = $urandom_range(1,30);
        end
        if (date.M == 2) begin
            date.D = $urandom_range(1,28);
        end

        today_mouth = date.M;
        today_day = date.D;
        inf.date_valid = 1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        repeat($urandom_range(0, 3)) @(negedge clk);
end
endtask

task data_task; 
begin
        inf.data_no_valid = 'b1;
        data_rand.randomize();
        inf.D = data_rand.dataid;
        @(negedge clk);
        inf.data_no_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
end
endtask
// check if reste == 0
initial begin
	forever@(posedge clk)begin
		if(inf.rst_n == 0) begin
		    @(negedge clk);
			if((inf.complete !== 0) || (inf.warn_msg !== 0) || (inf.out_valid !== 0))
            begin
            $display ("--------------------------------------------------------------------------------------------");
            $display ("            FAIL! Output signal should be 0 after the reset signal is asserted              ");
            $display ("--------------------------------------------------------------------------------------------");
			  repeat(3) @(negedge clk);
              $finish;
			end
		end
	end
end

task pass_task; begin	
    $display("********************************************************************");
    $display("                        \033[0;38;5;219mCongratulations!\033[m      ");
    $display("                 \033[0;38;5;219mYou have passed all patterns!\033[m");
    $display("********************************************************************");
    $finish;
    repeat (5) @(negedge clk);
    $finish;
    end 
endtask

endprogram
