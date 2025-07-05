module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;

output reg out_valid;
// handshack din
output reg [31:0] seed_out;

// You can change the input / output of the custom flag_c2 ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

reg in_valid_d;
reg [31:0] seed_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_d <= 0;
    end
    else in_valid_d <= in_valid;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seed_reg <= 0;
    end
    else if (in_valid && !in_valid_d) begin
        seed_reg <= seed_in;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seed_out <= 0;
    end
    else if (in_valid && out_idle) begin
        seed_out <= seed_in;
    end
    else seed_out <= seed_out;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (in_valid) begin
        out_valid <= 1;
    end
    else out_valid <= 0;
end

endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output reg out_valid;
output reg [31:0] rand_num;
output reg busy;

// You can change the input / output of the custom flag_c2 ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

reg  [31:0] result_seed ;

reg flag_c2 ;

reg [8:0] counter_flag;

// reg in_valid_d;

reg[1:0] c_s, n_s;
parameter S0_IDLE = 2'd0;
parameter S1_IN   = 2'd1;
parameter S2_OUT  = 2'd2;

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
                    n_s = S1_IN;
                else
                    n_s = S0_IDLE;
            end
          S1_IN:
            begin
                if (flag_c2)
                    n_s = S2_OUT;
                else
                    n_s = S1_IN;
            end
          S2_OUT:
            begin
                if (counter_flag == 256)
                    n_s = S0_IDLE;
                else
                    n_s = S2_OUT;
            end
          default:
              n_s = S0_IDLE;
      endcase
end

always @(*) busy = flag_c2;

always @(*) rand_num = 
    (result_seed ^ (result_seed << 13) ^ ((result_seed ^ (result_seed << 13)) >> 17)) ^ 
    ((result_seed ^ (result_seed << 13) ^ ((result_seed ^ (result_seed << 13)) >> 17)) << 5);

always @(*)out_valid = (flag_c2 && !fifo_full) ? 1 : 0 ;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) counter_flag <= 0;
    else if (counter_flag == 256) counter_flag <= 0;
    else if (out_valid) counter_flag <= counter_flag + 1;
    else counter_flag <= counter_flag;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) flag_c2 <= 0 ; 
    else if (in_valid) flag_c2 <= 1 ;
    else if (counter_flag[8]) flag_c2 <= 0;
    else flag_c2 <= flag_c2;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) result_seed <= 0 ;
    else if (c_s == S0_IDLE && n_s == S1_IN && in_valid) result_seed <= seed ;
    else if (n_s == S2_OUT && !fifo_full) result_seed <= rand_num ;
    else result_seed <= result_seed ;
end

endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output reg fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag_c2 ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
input fifo_clk3_flag3;
output fifo_clk3_flag4;

reg [8:0] counter_c3 ;


reg c_s, n_s;
parameter S0_IDLE = 0;
parameter S1_OUT = 1;

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
                if (fifo_clk3_flag3)
                    n_s = S1_OUT;
                else
                    n_s = S0_IDLE;
            end
          S1_OUT:
            begin
                if (!fifo_clk3_flag3)
                    n_s = S0_IDLE;
                else
                    n_s = S1_OUT;
            end
          default:
              n_s = S0_IDLE;
      endcase
end

always @(*) begin
    fifo_rinc = !fifo_empty;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) counter_c3 <= 0 ; 
    else if (n_s == S1_OUT && !counter_c3[8]) counter_c3 <= counter_c3 + 1 ;
    else counter_c3 <= 0 ;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) out_valid <= 0 ; 
    else if (n_s == S1_OUT && !counter_c3[8]) out_valid <= 1 ;
    else out_valid <= 0 ;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) rand_num <= 0 ; 
    else if (n_s == S1_OUT && !counter_c3[8]) rand_num <= fifo_rdata ;
    else rand_num <= 0 ;
end

endmodule