//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : Division_IP.v
//   	Module Name : Division_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module Division_IP #(parameter IP_WIDTH = 7) (
    // Input signals
    IN_Dividend, IN_Divisor,
    // Output signals
    OUT_Quotient
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_Dividend;
input [IP_WIDTH*4-1:0]  IN_Divisor;
// IN_Dividend
// -----------
// IN_Divisor

output logic [IP_WIDTH*4-1:0] OUT_Quotient;

wire [0:3] input_dividend[IP_WIDTH-1:0];
wire [0:3] input_divisor[IP_WIDTH-1:0];

integer i, j, n;

reg [0:3] divisor[IP_WIDTH-1:0][IP_WIDTH-1:0];

reg [0:3] found_index[IP_WIDTH-1:0][IP_WIDTH-1:0];
reg [0:3] found_flag[IP_WIDTH-1:0];

reg [0:3] found_index_sor[IP_WIDTH-1:0][IP_WIDTH-1:0];
reg [0:3] found_sor_flag[IP_WIDTH-1:0];

reg [0:3] temp_quotient[IP_WIDTH-1:0][IP_WIDTH-1:0];
reg [0:3] remainder[IP_WIDTH-1:0][IP_WIDTH-1:0];

reg [0:3] out_data[IP_WIDTH-1:0];

reg [0:3] solution_deg;

reg [0:3] gf_mult_max[IP_WIDTH-1:0][IP_WIDTH-1:0];

wire [0:3] log_table[15:0];
wire [0:3] exp_table[15:0];

// reg [0:3] add_before_log[6:0][6:0];
// ===============================================================
// Design
// ===============================================================

genvar ii;
generate 
    for (ii = 0; ii < IP_WIDTH; ii = ii + 1) begin 
        if (ii < IP_WIDTH) begin
            assign input_dividend[ii] = IN_Dividend[ii * 4 +: 4];
            assign input_divisor[ii]  = IN_Divisor[ii * 4 +: 4];
        end
        else begin 
            assign input_dividend[ii] = 4'b1111; // 15 in binary
            assign input_divisor[ii]  = 4'b1111; // 15 in binary
        end
    end
endgenerate

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

always @(*) begin
    for (j = 0 ; j < IP_WIDTH; j = j + 1) begin
        for (i = IP_WIDTH-1; i >= 0; i = i - 1) begin
            remainder[0][i] = input_dividend[i];
            found_index[j][IP_WIDTH-1] = IP_WIDTH-1;              
            if (remainder[j][i] != 15) begin
                found_index[j][i-1] = found_index[j][i];
            end
            else if (remainder[j][i] == 15 && found_index[j][i] == i)begin
                found_index[j][i-1] = found_index[j][i]-1;
            end
            else found_index[j][i-1] = found_index[j][i];
        end
    end



    for (j = 0 ; j < IP_WIDTH; j = j + 1) begin
        for (i = IP_WIDTH-1; i >= 0; i = i - 1) begin
            found_index_sor[j][IP_WIDTH-1] = IP_WIDTH-1;
            divisor[j][i] = input_divisor[i];
            if (divisor[j][i] != 15) begin
                found_index_sor[j][i-1] = found_index_sor[j][i];
            end
            else if (divisor[j][i] == 15 && found_index_sor[j][i] == i) begin
                found_index_sor[j][i-1] = found_index_sor[j][i]-1;
            end
            else found_index_sor[j][i-1] = found_index_sor[j][i];
        end
    end

    for (j = 0 ; j < IP_WIDTH; j = j + 1) begin
        for (i = 0; i < IP_WIDTH; i = i + 1) begin
            if (i == (found_index[0][0] - found_index_sor[0][0] - j)) begin
                if (remainder[j][found_index[0][0]-j] == 15) begin
                    temp_quotient[j][i] = 4'd15;
                end
                else if (remainder[j][found_index[0][0]-j] - divisor[j][found_index_sor[0][0]] == 0) begin
                    temp_quotient[j][i] = 4'd0;
                end
                else temp_quotient[j][i] = (remainder[j][found_index[0][0]-j] - divisor[j][found_index_sor[0][0]] + 15) % 15;
            end
            else temp_quotient[j][i] = 4'd15;
        end
    end

    for (j = 0 ; j < IP_WIDTH; j = j + 1) begin
        for (i = IP_WIDTH-1; i >= 0; i = i - 1) begin
            if (remainder[j][found_index[0][0]-j] == 15) begin
                gf_mult_max[j][i] = 4'd15;
            end            
            else if (divisor[j][i] == 4'd15) begin
                gf_mult_max[j][i] = 4'd15;
            end            
            else if (temp_quotient[j][(found_index[0][0] - found_index_sor[0][0]-j)] + divisor[j][i] == 4'd15) begin
                gf_mult_max[j][i] = 4'd0; // 定義為常數0
            end

            else gf_mult_max[j][i] = (temp_quotient[j][(found_index[0][0] - found_index_sor[0][0]-j)] + divisor[j][i]) % 15;
        end
    end

    for (j = 1 ; j < IP_WIDTH; j = j + 1) begin
        for (i = IP_WIDTH-1; i >= 0; i = i - 1) begin
            // remainder[j][i] = log_table[exp_table[remainder[j-1][i]]^exp_table[gf_mult_max[j-1][i - (found_index[0][0] - found_index_sor[0][0])]]];
            // if (i < (found_index[0][0] - found_index_sor[0][0])) begin
            //     // remainder[j][i] = 4'd15;
            //     remainder[j][i] = log_table[exp_table[remainder[j-1][i]]]^exp_table[4'd15];
            // end
            // else remainder[j][i] = log_table[exp_table[remainder[j-1][i]]^exp_table[gf_mult_max[j-1][i - (found_index[0][0] - found_index_sor[0][0])]]];
            if (i >= found_index[0][0] - j + 1) begin
                remainder[j][i] = 4'd15;
            end
            else if (i <= found_index[0][0] - j - found_index_sor[0][0]) begin
            // else if (i <= found_index[0][0] - j + 1 - found_index_sor[0][0] + 1) begin
                remainder[j][i] = remainder[j-1][i];
            end
            else begin
                remainder[j][i] = log_table[exp_table[remainder[j-1][i]]^exp_table[gf_mult_max[j-1][i - (found_index[j - 1][0] - found_index_sor[0][0])]]];
            end
        end
    end
    
    solution_deg = found_index[0][0] - found_index_sor[0][0];

    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        if (found_index[0][0] < found_index_sor[0][0]) begin
            OUT_Quotient[i * 4 +: 4] = 4'd15;
        end
        else begin
            if (i <= solution_deg) begin
                OUT_Quotient[i * 4 +: 4] = temp_quotient[solution_deg - i][i];
            end
            else begin
                OUT_Quotient[i * 4 +: 4] = 4'd15;
            end
        end
    end

end



endmodule