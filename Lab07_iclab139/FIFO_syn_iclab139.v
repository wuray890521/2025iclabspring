module FIFO_syn #(parameter WIDTH=32, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;


wire web_write;
assign web_write = !(winc & !wfull);
reg  [$clog2(WORDS):0]waddr;
reg  [$clog2(WORDS):0]raddr;

// rdata
//  Add one more register stage to rdata
always @(posedge rclk, negedge rst_n) begin
    if (!rst_n) begin
        rdata <= 0;
    end
    else begin
		rdata <= rdata_q;
	end
    end

DUAL_64X32X1BM1 u_dual_sram (
    .CKA  (wclk),
    .CKB  (rclk),
    .WEAN (web_write),
    .WEBN (1'b1),
    .CSA  (1'b1),
    .CSB  (1'b1),
    .OEA  (1'b1),
    .OEB  (1'b1),

    .A0(waddr[0]),
    .A1(waddr[1]),
    .A2(waddr[2]),
    .A3(waddr[3]),
    .A4(waddr[4]),
    .A5(waddr[5]),

    .B0(raddr[0]),
    .B1(raddr[1]),
    .B2(raddr[2]),
    .B3(raddr[3]),
    .B4(raddr[4]),
    .B5(raddr[5]),

    .DIA0 (wdata[0]),
    .DIA1 (wdata[1]),
    .DIA2 (wdata[2]),
    .DIA3 (wdata[3]),
    .DIA4 (wdata[4]),
    .DIA5 (wdata[5]),
    .DIA6 (wdata[6]),
    .DIA7 (wdata[7]),
    .DIA8 (wdata[8]),
    .DIA9 (wdata[9]),
    .DIA10(wdata[10]),
    .DIA11(wdata[11]),
    .DIA12(wdata[12]),
    .DIA13(wdata[13]),
    .DIA14(wdata[14]),
    .DIA15(wdata[15]),
    .DIA16(wdata[16]),
    .DIA17(wdata[17]),
    .DIA18(wdata[18]),
    .DIA19(wdata[19]),
    .DIA20(wdata[20]),
    .DIA21(wdata[21]),
    .DIA22(wdata[22]),
    .DIA23(wdata[23]),
    .DIA24(wdata[24]),
    .DIA25(wdata[25]),
    .DIA26(wdata[26]),
    .DIA27(wdata[27]),
    .DIA28(wdata[28]),
    .DIA29(wdata[29]),
    .DIA30(wdata[30]),
    .DIA31(wdata[31]),

    .DIB0 (1'b0),
    .DIB1 (1'b0),
    .DIB2 (1'b0),
    .DIB3 (1'b0),
    .DIB4 (1'b0),
    .DIB5 (1'b0),
    .DIB6 (1'b0),
    .DIB7 (1'b0),
    .DIB8 (1'b0),
    .DIB9 (1'b0),
    .DIB10(1'b0),
    .DIB11(1'b0),
    .DIB12(1'b0),
    .DIB13(1'b0),
    .DIB14(1'b0),
    .DIB15(1'b0),
    .DIB16(1'b0),
    .DIB17(1'b0),
    .DIB18(1'b0),
    .DIB19(1'b0),
    .DIB20(1'b0),
    .DIB21(1'b0),
    .DIB22(1'b0),
    .DIB23(1'b0),
    .DIB24(1'b0),
    .DIB25(1'b0),
    .DIB26(1'b0),
    .DIB27(1'b0),
    .DIB28(1'b0),
    .DIB29(1'b0),
    .DIB30(1'b0),
    .DIB31(1'b0),


    .DOB0 (rdata_q[0]),
    .DOB1 (rdata_q[1]),
    .DOB2 (rdata_q[2]),
    .DOB3 (rdata_q[3]),
    .DOB4 (rdata_q[4]),
    .DOB5 (rdata_q[5]),
    .DOB6 (rdata_q[6]),
    .DOB7 (rdata_q[7]),
    .DOB8 (rdata_q[8]),
    .DOB9 (rdata_q[9]),
    .DOB10(rdata_q[10]),
    .DOB11(rdata_q[11]),
    .DOB12(rdata_q[12]),
    .DOB13(rdata_q[13]),
    .DOB14(rdata_q[14]),
    .DOB15(rdata_q[15]),
    .DOB16(rdata_q[16]),
    .DOB17(rdata_q[17]),
    .DOB18(rdata_q[18]),
    .DOB19(rdata_q[19]),
    .DOB20(rdata_q[20]),
    .DOB21(rdata_q[21]),
    .DOB22(rdata_q[22]),
    .DOB23(rdata_q[23]),
    .DOB24(rdata_q[24]),
    .DOB25(rdata_q[25]),
    .DOB26(rdata_q[26]),
    .DOB27(rdata_q[27]),
    .DOB28(rdata_q[28]),
    .DOB29(rdata_q[29]),
    .DOB30(rdata_q[30]),
    .DOB31(rdata_q[31])
);


reg  [$clog2(WORDS):0] wq2_rptr;
reg  [$clog2(WORDS):0] rq2_wptr;

NDFF_BUS_syn #(.WIDTH($clog2(WORDS) + 1)) rsy (.D(wptr), .Q(rq2_wptr), .clk(rclk), .rst_n(rst_n));
NDFF_BUS_syn #(.WIDTH($clog2(WORDS) + 1)) wsy (.D(rptr), .Q(wq2_rptr), .clk(wclk), .rst_n(rst_n));

// FIFO WRITE ======================== FIFO WRITE //
wire wfull_q;
wire [$clog2(WORDS):0] wptr_q;
wire [$clog2(WORDS):0]waddr_q;

assign waddr_q = waddr + (winc & !wfull);

assign wptr_q  = (waddr_q >> 1) ^ waddr_q;

assign wfull_q = (wptr_q == {~wq2_rptr[$clog2(WORDS):$clog2(WORDS)-1],wq2_rptr[$clog2(WORDS)-2:0]});

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wfull <= 0;
    end
    else begin
        wfull <= wfull_q;
    end
end

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        wptr  <= 0;
    end
    else begin
        wptr  <= wptr_q;
    end
end

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        waddr <= 0;
    end
    else begin
        waddr <= waddr_q;
    end
end
// FIFO READ ================================== FIFO READ //
wire rempty_q;
wire [$clog2(WORDS):0] raddr_q;
wire [$clog2(WORDS):0] rptr_q;

assign raddr_q  = raddr + (rinc & ~rempty);

assign rptr_q   = (raddr_q >> 1) ^ raddr_q;

assign rempty_q = (rptr_q == rq2_wptr) ? 1 : 0;

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rptr  <= 0;
    end
    else begin
        rptr  <= rptr_q;
    end
end
always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        raddr <= 0;
    end
    else begin
        raddr <= raddr_q;
    end
end

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) begin
        rempty <= 1;
    end
    else begin
        rempty <= rempty_q;
    end
end
// FIFO READ ================================== FIFO READ //

reg [6:0] raddr_d;
reg [6:0] raddr_d_d;
always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) begin
        raddr_d <= 0;
        raddr_d_d <= 0;
    end
    else begin
        raddr_d   <= raddr;
        raddr_d_d <= raddr_d;
    end
end

assign fifo_clk3_flag3 = (raddr_d != raddr_d_d) ? 1 : 0;


endmodule
