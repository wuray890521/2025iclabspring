//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2025
//		Version		: v1.0
//   	File Name   : BCH_TOP.v
//   	Module Name : BCH_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "Division_IP.v"

module BCH_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_syndrome, 
    // Output signals
    out_valid, 
	out_location
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_syndrome;

output reg out_valid;
output reg [3:0] out_location;

parameter IP_WIDTH = 7;
// ===============================================================
// Reg & Wire Declaration
// ===============================================================
integer i, j, k;

wire [0:3] log_table[15:0];
wire [0:3] exp_table[15:0];


reg in_valid_d;
reg [3:0] in_syndrome_d;
// reg [IP_WIDTH*4-1:0] dividend;
reg [3:0] omega_0[6:0]; // omega 0
reg [3:0] omega_n1[6:0]; // omega -1
reg [3:0] count_input;

// ------ c_s == S2_IP_1 --------
reg [27:0] dividend;
reg [27:0] divisor;

reg [3:0] sigma_1[6:0]; // sigma_1 = q1
reg [4:0] counter_ip_1;
reg [3:0] omega_1[6:0];
wire [27:0] out_divi_ip;
reg [4:0] counter_mult_ip_1;
wire [27:0] OUT_Quotient;
reg [3:0] out_div[6:0];
reg [3:0] mult_poly[12:0];
reg [3:0] add_poly[12:0];

reg [3:0] mult_poly_sigma[12:0];
reg [3:0] add_poly_sigma[12:0];
reg [3:0] add_poly_sigma_so[6:0];
reg [3:0] sigma_0[6:0];
reg [3:0] sigma_n1[6:0];


reg [3:0] counter_add_ip;
reg [3:0] power_of_div[6:0];

reg [3:0] add_poly_omega[6:0];
// ------ c_s == S2_IP_1 --------

// ------ c_s == S3_IP_ADD ------
reg [3:0] power_sigma_1;
reg [3:0] power_omega_1;

reg flag_power_sigma_1;
reg flag_power_omega_1;

reg [3:0] counter_s3;
reg [3:0] power_count;
// ------ c_s == S3_IP_ADD ------
// ------ c_s == S4_SOL ---------
reg [4:0] counter_s4;
reg [3:0] locator[3:0];
reg [3:0] evaluator[3:0];
reg [3:0] eelement[3:0];

wire [3:0] sol;

reg [1:0] counter_flag;
reg flag_sol;

reg [3:0] counter_id;
reg [3:0] counter_id_d;

reg [3:0] sol_max[2:0];
// ------ c_s == S4_SOL ---------

// ------ c_s == S5_OUT ---------
reg [1:0] counter_out;
// ------ c_s == S5_OUT ---------
// --------- FSM ----------
reg [3:0] c_s, n_s;
parameter S0_IDLE   = 4'd0;
parameter S1_LOAD   = 4'd1;
parameter S2_IP_1   = 4'd2;
parameter S3_IP_ADD = 4'd3;
parameter S4_SOL    = 4'd4;
parameter S5_OUT    = 4'd5;
// --------- FSM ----------
// --------- FSM ----------
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
                    n_s = S1_LOAD;
                else
                    n_s = S0_IDLE;
            end
          S1_LOAD:
            begin
                if (count_input == 5)
                    n_s = S2_IP_1;
                else
                    n_s = S1_LOAD;
            end
          S2_IP_1:
            begin
                if (counter_add_ip == power_of_div[0] + 1)
                    n_s = S3_IP_ADD;
                else
                    n_s = S2_IP_1;
            end
          S3_IP_ADD:
            begin
                if (counter_s3 == 7) begin
                    if (power_sigma_1 <= 3 && power_omega_1 <= 2) begin
                        n_s = S4_SOL;
                    end
                    else n_s = S2_IP_1;
                end
                else
                    n_s = S3_IP_ADD;
            end
          S3_IP_ADD:
            begin
                if (counter_s3 == 7) begin
                    if (power_sigma_1 <= 3 && power_omega_1 <= 2) begin
                        n_s = S4_SOL;
                    end
                    else n_s = S2_IP_1;
                end
                else
                    n_s = S3_IP_ADD;
            end
          S4_SOL:
            begin
                if (counter_s4 == 5'd17)
                // if (counter_id == 4'd15)
                    n_s = S5_OUT;
                else
                    n_s = S4_SOL;
            end
          S5_OUT:
            begin
                if (counter_out == 3)
                    n_s = S0_IDLE;
                else
                    n_s = S5_OUT;
            end
          default:
              n_s = S0_IDLE;
      endcase
  end

// --------- FSM ----------
// ------------ input data ------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_syndrome_d <= 0;
    end
    else in_syndrome_d <= in_syndrome;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_input <= 0;
    end
    else if (c_s == S1_LOAD) begin
        count_input <= count_input + 1;
    end
    else count_input <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7; i = i + 1) begin
            omega_0[i] <= 4'd15;
        end
    end
    else if (c_s == S1_LOAD) begin
        omega_0[count_input] <= in_syndrome_d;
    end
    else if (c_s == S3_IP_ADD) begin
        if (counter_s3 == 7) begin
            for (i = 0; i < 7; i = i + 1) begin
                omega_0[i] <= omega_1[i];
            end
        end
        else begin
            for (i = 0; i < 7; i = i + 1) begin
                omega_0[i] <= omega_0[i];
            end 
        end        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7; i = i + 1) begin
            omega_n1[i] <= 4'd0;
        end
    end
    else if (c_s == S1_LOAD) begin
        for (i = 0; i < 6 ; i = i + 1) begin
            omega_n1[i] <= 4'd15;
        end
        omega_n1[6] <= 4'd0;
    end
    else if (c_s == S3_IP_ADD) begin
        if (counter_s3 == 7) begin
            for (i = 0; i < 7; i = i + 1) begin
                omega_n1[i] <= omega_0[i];
            end            
        end
        else begin
            for (i = 0; i < 7; i = i + 1) begin
                omega_n1[i] <= omega_n1[i];
            end 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dividend <= 28'hfffffff;
    end

    else if (c_s == S2_IP_1) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            dividend[(i * 4) +: 4] <= omega_n1[i];
        end
    end
    else dividend <= dividend;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        divisor <= 28'hfffffff;
    end
    else if (c_s == S2_IP_1) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            divisor[(i * 4) +: 4] <= omega_0[i];
        end
    end
    else divisor <= divisor;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_ip_1 <= 0;
    end
    else if (c_s == S2_IP_1) begin
        counter_ip_1 <= counter_ip_1 + 1;
    end
    else counter_ip_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_mult_ip_1 <= 0;
    end
    else if (c_s == S2_IP_1) begin
        if (counter_ip_1 < 2) counter_mult_ip_1 <= 0;
        else counter_mult_ip_1 <= counter_mult_ip_1 + 1;
    end
    else counter_mult_ip_1 <= 0;
end

Division_IP #(.IP_WIDTH(IP_WIDTH)) I_Division_IP(.IN_Dividend(dividend), .IN_Divisor(divisor), .OUT_Quotient(OUT_Quotient)); 

assign out_divi_ip = OUT_Quotient;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            out_div[i] <= 0;
        end
    end
    else if (c_s == S2_IP_1) begin
        if (counter_ip_1 == 1) begin
            for (i = 0; i < 7 ; i = i + 1) begin
                out_div[i] <= out_divi_ip[i*4 +: 4];
            end
        end
        else begin
            for (i = 0; i < 7 ; i = i + 1) begin
                out_div[i] <= out_div[i];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            mult_poly[i] <= 4'hf;
        end
    end
    else if (c_s == S2_IP_1) begin
        for (i = 0;i < 7;i = i + 1) begin
            if (out_div[counter_mult_ip_1] == 4'd15) begin
                mult_poly[i] <= 4'd15; 
            end
            else if (omega_0[i] == 4'd15) begin
                mult_poly[i] <= 4'd15; 
            end
            else begin
                mult_poly[i] <= (omega_0[i] + out_div[counter_mult_ip_1])%15; 
            end
        end
    end
    else if (c_s == S3_IP_ADD) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            mult_poly[i] <= 4'hf;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_add_ip <= 0;
    end
    else if (c_s == S2_IP_1) begin
        if (counter_mult_ip_1 == 0) begin
            counter_add_ip <= 0;        
        end
        else counter_add_ip <= counter_add_ip + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            add_poly[i] <= 4'd15;
        end
    end
    else if (c_s == S2_IP_1) begin
        if (counter_mult_ip_1 == 0) begin
            for (j = 0; j < 13 ; j = j + 1) begin
                add_poly[j] <= 4'd15;
            end            
        end
        else begin
            for (i = 0;i < 7;i = i + 1) begin
                if (add_poly[i + counter_add_ip] == mult_poly[i]) add_poly[i + counter_add_ip] <= 4'd15;
                else add_poly[i + counter_add_ip] <= log_table[exp_table[add_poly[i + counter_add_ip]]^exp_table[mult_poly[i]]];
            end            
        end
    end
    else if (c_s == S3_IP_ADD) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            add_poly[i] <= 4'd15;
        end
    end
end

always @(*) begin
    for (i = 6; i >= 0; i = i - 1) begin
        power_of_div[6] = 6;              
        if (out_div[i] != 15) begin
            power_of_div[i-1] = power_of_div[i];
        end
        else if (out_div[i] == 15 && power_of_div[i] == i)begin
            power_of_div[i-1] = power_of_div[i]-1;
        end
        else power_of_div[i-1] = power_of_div[i];
    end
end
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         power_of_div <= 0;
//     end
//     else if (c_s == S2_IP_1) begin
//         if (counter_ip_1 == 2) begin
//             for (k = 0; k < 7 ; k = k + 1) begin
//                 if (out_div[k] == 15 && power_of_div == k) begin
//                     power_of_div <= power_of_div;
//                 end
//                 else power_of_div <= power_of_div + 1;
//             end
//         end
//         else power_of_div <= power_of_div;
//     end
//     else power_of_div <= 0;
// end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            add_poly_omega[i] <= 4'd15;
        end
    end
    else if (c_s == S2_IP_1) begin
        for (k = 0; k < 7 ; k = k + 1) begin
            add_poly_omega[k] <= add_poly[k];
        end
    end
    else begin
        for (i = 0; i < 7 ; i = i + 1) begin
            add_poly_omega[i] <= add_poly_omega[i];
        end        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            sigma_0[i] <= 4'hf;
        end
    end
    else if (c_s == S1_LOAD) begin
        for (i = 1; i < 7 ; i = i + 1) begin
            sigma_0[i] <= 4'hf;
        end      
        sigma_0[0] <= 0;  
    end
    else if (c_s == S3_IP_ADD) begin
        if (counter_s3 == 7) begin
            for (i = 0; i < 7; i = i + 1) begin
                sigma_0[i] <= sigma_1[i];
            end            
        end
        else begin
            for (i = 0; i < 7; i = i + 1) begin
                sigma_0[i] <= sigma_0[i];
            end 
        end        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            sigma_n1[i] <= 4'hf;
        end
    end
    else if (c_s == S1_LOAD) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            sigma_n1[i] <= 4'hf;
        end
    end
    else if (c_s == S3_IP_ADD) begin
        if (counter_s3 == 7) begin
            for (i = 0; i < 7; i = i + 1) begin
                sigma_n1[i] <= sigma_0[i];
            end            
        end
        else begin
            for (i = 0; i < 7; i = i + 1) begin
                sigma_n1[i] <= sigma_n1[i];
            end 
        end        
    end
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            mult_poly_sigma[i] <= 4'hf;
        end
    end
    else if (c_s == S2_IP_1) begin
        for (i = 0;i < 7;i = i + 1) begin
            if (out_div[counter_mult_ip_1] == 4'hf) begin
                mult_poly_sigma[i] <= 4'hf;
            end
            else if (sigma_0[i] == 4'd15) begin
                mult_poly_sigma[i] <= 4'hf;
            end
            else mult_poly_sigma[i] <= (sigma_0[i] + out_div[counter_mult_ip_1])%15; 
        end
    end
    else if (c_s == S3_IP_ADD) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            mult_poly_sigma[i] <= 4'hf;
        end        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            add_poly_sigma[i] <= 4'hf;
        end        
    end
    else if (c_s == S2_IP_1) begin
        if (counter_mult_ip_1 == 0) begin
            for (j = 0; j < 13 ; j = j + 1) begin
                add_poly_sigma[j] <= 4'd15;
            end            
        end
        else begin
            for (i = 0;i < 7;i = i + 1) begin
                if (add_poly_sigma[i + counter_add_ip] == mult_poly_sigma[i]) add_poly_sigma[i + counter_add_ip] <= 4'd15;
                else add_poly_sigma[i + counter_add_ip] <= log_table[exp_table[add_poly_sigma[i + counter_add_ip]]^exp_table[mult_poly_sigma[i]]];
            end            
        end
    end
    else if (c_s == S3_IP_ADD) begin
        for (i = 0; i < 13 ; i = i + 1) begin
            add_poly_sigma[i] <= 4'hf;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            add_poly_sigma_so[i] <= 4'd15;
        end
    end
    else if (c_s == S2_IP_1) begin
        for (k = 0; k < 7 ; k = k + 1) begin
            add_poly_sigma_so[k] <= add_poly_sigma[k];
        end
    end
    else begin
        for (i = 0; i < 7 ; i = i + 1) begin
            add_poly_sigma_so[i] <= add_poly_sigma_so[i];
        end        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            omega_1[i] <= 4'd15;
        end        
    end
    else if (c_s == S3_IP_ADD) begin
        for (i = 0;i < 7;i = i + 1) begin
            omega_1[i] <= log_table[exp_table[add_poly_omega[i]]^exp_table[omega_n1[i]]];
        end   
    end
    else if (c_s == S5_OUT) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            omega_1[i] <= 4'd15;
        end    
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            sigma_1[i] <= 4'd15;
        end        
    end
    else if (c_s == S3_IP_ADD) begin
        for (i = 0;i < 7;i = i + 1) begin
            sigma_1[i] <= log_table[exp_table[add_poly_sigma_so[i]]^exp_table[sigma_n1[i]]];
        end   
    end
    else if (c_s == S5_OUT) begin
        for (i = 0; i < 7 ; i = i + 1) begin
            sigma_1[i] <= 4'd15;
        end
    end
end

// 判斷 sigma_1 && omega_1 的最高次方樹用於終止跌帶 切state4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_s3 <= 0;
    end
    else if (c_s == S3_IP_ADD) begin
        counter_s3 <= counter_s3 + 1;
    end
    else counter_s3 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        power_count <= 6;
    end
    else if (c_s == S3_IP_ADD) begin
        if (counter_s3 == 0) power_count <= 6;
        else power_count <= power_count - 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        power_omega_1 <= 6;
    end
    else if (c_s == S3_IP_ADD) begin
        if (omega_1[power_count] == 15 && power_omega_1 == power_count) begin
            power_omega_1 <= power_omega_1 - 1;
        end
        else power_omega_1 <= power_omega_1;
    end
    else if (c_s == S2_IP_1) begin
        power_omega_1 <= 6;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        power_sigma_1 <= 6;
    end
    else if (c_s == S3_IP_ADD) begin
        if (sigma_1[power_count] == 15 && power_sigma_1 == power_count) begin
            power_sigma_1 <= power_sigma_1 - 1;
        end
        else power_sigma_1 <= power_sigma_1;
    end
    else if (c_s == S2_IP_1) begin
        power_sigma_1 <= 6;
    end
end
// 判斷 sigma_1 && omega_1 的最高次方樹用於終止跌帶 切state4

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_s4 <= 0;
    end
    else if (c_s == S4_SOL) begin
        counter_s4 <= counter_s4 + 1;
    end
    else counter_s4 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4; i = i + 1) begin
            locator[i] <= 4'd15;
        end
    end
    else if (c_s == S4_SOL) begin
        for (i = 0; i < 4; i = i + 1) begin
            locator[i] <= sigma_1[i];
        end
    end
    else begin
        for (i = 0; i < 4; i = i + 1) begin
            locator[i] <= 4'd15;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4; i = i + 1) begin
            evaluator[i] <= 4'd15;
        end
    end
    else if (c_s == S4_SOL) begin
        for (i = 0; i < 4 ; i = i + 1) begin
            if (locator[i] == 15) begin
                evaluator[i] <= 4'd15;
            end
            else evaluator[i] <= (i * (15 - counter_s4)) % 15;
        end
    end
    else begin
        for (i = 0; i < 4; i = i + 1) begin
            evaluator[i] <= 4'd15;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 4; i = i + 1) begin
            eelement[i] <= 4'd15;
        end
    end
    else if (c_s == S4_SOL) begin
        for (i = 0; i < 4; i = i + 1) begin
            // eelement[i] <= (evaluator[i] + locator[i]) % 15;
            if (locator[i] == 15) eelement[i] <= 15;
            else eelement[i] <= (evaluator[i] + locator[i]) % 15;
        end
    end
    else if (c_s == S1_LOAD) begin
        for (i = 0; i < 4; i = i + 1) begin
            eelement[i] <= 4'd15;
        end        
    end
end

assign sol = exp_table[eelement[3]] ^ exp_table[eelement[2]] ^ exp_table[eelement[1]] ^ exp_table[eelement[0]];
// assign sol = log_table[exp_table[eelement[3]] ^ exp_table[eelement[2]] ^ exp_table[eelement[1]] ^ exp_table[eelement[0]]];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_sol <= 0;
    end
    else if (c_s == S4_SOL) begin
        if (counter_s4 == 1) begin
            flag_sol <= 0;
        end
        else begin
            if (sol == 0) begin
                flag_sol <= 1;
            end
            else flag_sol <= 0; 
        end
    end
    else flag_sol <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_flag <= 0;
    end
    else if (c_s == S4_SOL) begin
        if (counter_s4 <= 1) begin
            counter_flag <= 3;
        end
        else begin
            if (sol == 0) begin
                counter_flag <= counter_flag + 1;
            end
            else counter_flag <= counter_flag;
        end
    end
    else counter_flag <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_id <= 0;
    end
    else if (c_s == S4_SOL) begin
        if (counter_s4 == 1) begin
            counter_id <= 0;
        end
        else counter_id <= counter_id + 1;
    end
    else if (c_s == S1_LOAD) begin
        counter_id <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 3; i = i + 1) begin
            sol_max[i] <= 4'd15;
        end
    end
    else if (c_s == S4_SOL) begin
        if (flag_sol) begin
            sol_max[counter_flag] <= counter_id_d;
        end
    end
    else if (c_s == S1_LOAD)begin
        for (i = 0; i < 3; i = i + 1) begin
            sol_max[i] <= 4'd15;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_id_d <= 0;
    end
    else counter_id_d <= counter_id;
end
// ------------ output signal ---------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_out <= 0;
    end
    else if (c_s == S5_OUT) begin
        counter_out <= counter_out + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (c_s == S5_OUT) begin
        if (counter_out == 3) out_valid <= 0;
        else out_valid <= 1;
    end
    else out_valid <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_location <= 0;
    end
    else if (c_s == S5_OUT) begin
        if (counter_out == 3) out_location <= 0;
        else out_location <= sol_max[counter_out];
    end
    else out_location <= 0;
end

assign log_table[0]  = 4'hF; // 未定义
assign log_table[1]  = 4'h0; // α^0
assign log_table[2]  = 4'h1; // α^1
assign log_table[3]  = 4'h4; // α^4
assign log_table[4]  = 4'h2; // α^2
assign log_table[5]  = 4'h8; // α^8
assign log_table[6]  = 4'h5; // α^5
assign log_table[7]  = 4'hA; // α^10
assign log_table[8]  = 4'h3; // α^3
assign log_table[9]  = 4'hE; // α^14
assign log_table[10] = 4'h9; // α^9
assign log_table[11] = 4'h7; // α^7
assign log_table[12] = 4'h6; // α^6
assign log_table[13] = 4'hD; // α^13
assign log_table[14] = 4'hB; // α^11
assign log_table[15] = 4'hC; // α^12

assign exp_table[0]  = 4'h1;  // α^0
assign exp_table[1]  = 4'h2;  // α^1
assign exp_table[2]  = 4'h4;  // α^2
assign exp_table[3]  = 4'h8;  // α^3
assign exp_table[4]  = 4'h3;  // α^4
assign exp_table[5]  = 4'h6;  // α^5
assign exp_table[6]  = 4'hC;  // α^6
assign exp_table[7]  = 4'hB;  // α^7
assign exp_table[8]  = 4'h5;  // α^8
assign exp_table[9]  = 4'hA;  // α^9
assign exp_table[10] = 4'h7; // α^10
assign exp_table[11] = 4'hE; // α^11
assign exp_table[12] = 4'hF; // α^12
assign exp_table[13] = 4'hD; // α^13
assign exp_table[14] = 4'h9; // α^14
assign exp_table[15] = 4'h0; // α^15

endmodule