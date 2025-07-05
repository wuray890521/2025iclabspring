/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2025 Spring IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: May-2025)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

class Strategy_and_mode;
    Strategy_Type f_type;
    Mode f_mode;
endclass

Strategy_and_mode fm_info = new();


always_ff @(posedge clk iff inf.strategy_valid) fm_info.f_type = inf.D.d_strategy[0];

always_ff @(posedge clk iff inf.mode_valid) fm_info.f_mode = inf.D.d_mode[0];

covergroup Spec1 @(posedge clk iff inf.strategy_valid);
    option.per_instance = 1;
    option.at_least = 100;
    fstrategy:coverpoint inf.D.d_strategy[0] {
        bins f_f_type [] = {3'h0,3'h1,3'h2,3'h3,3'h4,3'h5,3'h6,3'h7};
    }
endgroup

Spec1 spec1_inst = new() ;

covergroup Spec2 @(posedge clk iff inf.mode_valid);
    option.per_instance = 1;
    option.at_least = 100;
    fmode : coverpoint inf.D.d_mode[0] {
        bins f_f_mode [] = {2'b00, 2'b01, 2'b11} ;
    }
endgroup

Spec2 spec2_inst = new() ;

covergroup Spec3 @(posedge clk iff inf.mode_valid);
    option.per_instance = 1;
    option.at_least = 100 ;
    fstrategy_fmode: cross fm_info.f_type, fm_info.f_mode;
endgroup

Spec3 spec3_inst = new() ;

covergroup Spec4 @(posedge clk iff inf.out_valid);
    option.per_instance = 1;
    option.at_least = 10;
	out : coverpoint inf.warn_msg {
		bins e_err [] = {2'h0, 2'h1, 2'h2, 2'h3} ;
	}
endgroup

Spec4 spec4_inst = new() ;

covergroup Spec5 @(posedge clk iff inf.sel_action_valid);
    option.per_instance = 1 ;
    option.at_least = 300 ;
	act : coverpoint inf.D.d_act[0] {
		bins a_act [] = (2'h0,2'h1,2'h2=>2'h0,2'h1,2'h2) ;
	}
endgroup

Spec5 spec5_inst = new() ;

covergroup Spec6 @(posedge clk iff inf.restock_valid);
    option.per_instance = 1 ;
    option.at_least = 1 ;
	input_ing : coverpoint inf.D.d_stock[0] {
		option.auto_bin_max = 32 ;
	}
endgroup

Spec6 spec6_inst = new() ;


Action action_span ;

always_ff @ (posedge clk or negedge inf.rst_n) begin  
	if (!inf.rst_n) action_span = Purchase ;
	else begin 
		if (inf.sel_action_valid) action_span = inf.D.d_act[0] ;
	end
end

logic [2:0] counter ;

always_ff @ (posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) begin 
		counter = 0 ;
	end
	else begin 
		if (inf.restock_valid) counter = counter + 1 ;
		else if (counter == 4) counter = 0 ;
	end
end

/*
    1. All outputs signals (including AFS.sv) should be zero after reset.
*/
always @ (negedge inf.rst_n) begin 
	#(5) ;
	Assertion1 : assert (inf.out_valid === 0 && inf.warn_msg === 0 && inf.complete === 0 
    && inf.AR_VALID === 0 && inf.AR_ADDR === 0 && inf.R_READY === 0 && inf.AW_VALID === 0
    && inf.AW_ADDR === 0 && inf.W_VALID === 0 && inf.W_DATA === 0 && inf.B_READY === 0) 
    else begin 
        $fatal(0, "Assertion 1 is violated");
    end
end
						
/*
    2.	Latency should be less than 1000 cycles for each operation.
*/
always @ (posedge clk) begin
Asseration2_1 : assert property (@(negedge clk) (action_span == 2'd0 && inf.data_no_valid === 1) |-> (##[1:1000] inf.out_valid))
else begin
    $fatal(0, "Assertion 2 is violated");
end
end
always @ (posedge clk) begin
Asseration2_2 : assert property (@(negedge clk) (action_span == 2'd1 && inf.restock_valid === 1) |-> (##[1:1000] inf.out_valid))
else begin
    $fatal(0, "Assertion 2 is violated");
end
end
always @ (posedge clk) begin
Asseration2_3 : assert property (@(negedge clk) (action_span == 2'd2 && inf.data_no_valid === 1) |-> (##[1:1000] inf.out_valid))
else begin
    $fatal(0, "Assertion 2 is violated");
end
end
/*
    3. If out_valid does not pull up, complete should be 0.
*/
always @ (posedge clk) begin
	Assertion3 : assert property (@ (negedge clk) inf.complete |-> (inf.warn_msg == No_Warn))
    else begin 
        $fatal(0, "Assertion 3 is violated");
    end
end

/*
    4. Next input valid will be valid 1-4 cycles after previous input valid fall.
*/
always @ (posedge clk) begin
    Asseration4_1 : assert property (@(negedge clk) (inf.strategy_valid === 1) |-> (##[1:4] (inf.mode_valid === 1)))
    else begin
        $fatal(0, "Assertion 4 is violated");
    end
    Asseration4_2 : assert property (@(negedge clk) (inf.mode_valid === 1) |-> (##[1:4] (inf.date_valid === 1)))
    else begin
        $fatal(0, "Assertion 4 is violated");
    end
    Asseration4_3 : assert property (@(negedge clk) (inf.date_valid === 1) |-> (##[1:4] (inf.data_no_valid === 1)))
    else begin
        $fatal(0, "Assertion 4 is violated");
    end
    Asseration4_4 : assert property (@(negedge clk) (action_span == 1 && inf.data_no_valid === 1) |-> (##[1:4] (inf.restock_valid === 1)))
    else begin
        $fatal(0, "Assertion 4 is violated");
    end
    Asseration4_5 : assert property (@(negedge clk) (counter < 4 && inf.restock_valid === 1) |-> (##[1:4] (inf.restock_valid === 1)))
    else begin
        $fatal(0, "Assertion 4 is violated");
    end
end
/*
    5. All input valid signals won't overlap with each other. 
*/
always @ (posedge clk) begin 
	Asseration_action_overlap : assert property (@ (negedge clk) inf.sel_action_valid |-> ((inf.strategy_valid | inf.mode_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid) == 0))
    else begin 
        $fatal(0, "Assertion 5 is violated");
    end
	Asseration_type_overlap   : assert property (@ (negedge clk) inf.strategy_valid |-> ((inf.sel_action_valid | inf.mode_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid) == 0))
    else begin 
        $fatal(0, "Assertion 5 is violated");
    end
	Asseration_size_overlap   : assert property (@ (negedge clk) inf.mode_valid |-> ((inf.sel_action_valid | inf.sel_action_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid) == 0))
    else begin 
        $fatal(0, "Assertion 5 is violated");
    end
	Asseration_date_overlap   : assert property (@ (negedge clk) inf.date_valid |-> ((inf.strategy_valid | inf.mode_valid | inf.sel_action_valid | inf.data_no_valid | inf.restock_valid) == 0))
    else begin 
        $fatal(0, "Assertion 5 is violated");
    end
	Asseration_boxno_overlap  : assert property (@ (negedge clk) inf.data_no_valid |-> ((inf.strategy_valid | inf.mode_valid | inf.date_valid | inf.sel_action_valid | inf.restock_valid) == 0))
    else begin 
        $fatal(0, "Assertion 5 is violated");
    end
	Asseration_boxsup_overlap : assert property (@ (negedge clk) inf.restock_valid |-> ((inf.strategy_valid | inf.mode_valid | inf.date_valid | inf.data_no_valid | inf.sel_action_valid) == 0))
    else begin 
        $fatal(0, "Assertion 5 is violated");
    end
end


/*
    6. Out_valid can only be high for exactly one cycle.
*/
always @ (posedge clk)
	Asseration_outvalid : assert property (@ (negedge clk) inf.out_valid |-> (##1 (inf.out_valid == 0)))
    else begin 
        $fatal(0, "Assertion 6 is violated");
    end
/*
    7. Next operation will be valid 1-4 cycles after out_valid fall.
*/
always @ (posedge clk)
	Asseration_gap : assert property (@(negedge clk) (inf.out_valid) |-> ##[2:5] (inf.sel_action_valid))
else begin
        $fatal(0, "Assertion 7 is violated");
end
/*
    8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)
*/
always @ (posedge clk) begin
	Asseration_check_month : assert property (@ (negedge clk) inf.date_valid |-> (inf.D.d_date[0].M <= 12 && inf.D.d_date[0].M >= 1))
    else begin 
        $fatal(0, "Assertion 8 is violated");
    end
	Asseration_big_month : assert property (@ (negedge clk) (inf.date_valid && (inf.D.d_date[0].M == 1 | inf.D.d_date[0].M == 3 |inf.D.d_date[0].M == 5 |inf.D.d_date[0].M == 7 |inf.D.d_date[0].M == 8 |inf.D.d_date[0].M == 10 | inf.D.d_date[0].M == 12)) |-> (inf.D.d_date[0].D <= 31 && inf.D.d_date[0].D >= 1))
    else begin 
        $fatal(0, "Assertion 8 is violated");
    end
	Asseration_small_month : assert property (@ (negedge clk) (inf.date_valid && (inf.D.d_date[0].M == 4 | inf.D.d_date[0].M == 6 |inf.D.d_date[0].M == 9 |inf.D.d_date[0].M == 11)) |-> (inf.D.d_date[0].D <= 30 && inf.D.d_date[0].D >= 1))
    else begin 
        $fatal(0, "Assertion 8 is violated");
    end					
	Asseration_february : assert property (@ (negedge clk) (inf.date_valid && (inf.D.d_date[0].M == 2)) |-> (inf.D.d_date[0].D <= 28 && inf.D.d_date[0].D >= 1))
    else begin 
        $fatal(0, "Assertion 8 is violated");
    end
end
/*
9. The AR_VALID signal should not overlap with the AW_VALID signal.
*/
always @ (posedge clk) begin 
	Asseration_AR_VALID : assert property (@ (negedge clk) inf.AR_VALID |-> ((inf.AW_VALID) == 0))
    else begin 
        $fatal(0, "Assertion 9 is violated");
    end
end
endmodule