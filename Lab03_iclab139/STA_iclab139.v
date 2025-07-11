module STA(
	//INPUT
	rst_n,
	clk,
	in_valid,
	delay,
	source,
	destination,
	//OUTPUT
	out_valid,
	worst_delay,
	path
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[3:0]	delay;
input		[3:0]	source;
input		[3:0]	destination;

output reg			out_valid;
output reg	[7:0]	worst_delay;
output reg	[3:0]	path;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
// ------LOAD------
reg [4:0] count;
reg [3:0] delay_d;
reg [3:0] source_d;
reg [3:0] destination_d;
reg [3:0] source_[31:0];
reg [3:0] drain[31:0];
reg [3:0] self_delay[15:0];
integer i, n, m, ll;
// ------LOAD------
reg [3:0] totalpath[15:0];
reg [9:0] totaldelay[15:0];
reg [3:0] path_maxtrix[15:0];

reg [7:0] count_state;
reg [3:0] count_out;
reg [3:0] count_out_data;

reg [0:0] on[31:0];
reg [0:0] next_on[31:0];
reg [9:0] out_data;
wire on_tozero;
assign on_tozero = on[0] 
				|| on[1]
				|| on[2]
				|| on[3]
				|| on[4]
				|| on[5]
				|| on[6]
				|| on[7]
				|| on[8]
				|| on[9]
				|| on[10]
				|| on[11]
				|| on[12]
				|| on[13]
				|| on[14]
				|| on[15]
				|| on[16]
				|| on[17]
				|| on[18]
				|| on[19]				
				|| on[20]
				|| on[21]
				|| on[22]
				|| on[23]
				|| on[24]
				|| on[25]
				|| on[26]
				|| on[27]
				|| on[28]
				|| on[29]	
				|| on[30]
				|| on[31];							


reg [3:0] counter_on20;

// ---------FSM----------
reg [2:0] c_s, n_s;
parameter S_IDLE   = 3'd0;
parameter S_LOAD   = 3'd1;
parameter S_PARI   = 3'd2;
parameter S_OUT_1  = 3'd3;
parameter S_OUT    = 3'd4;
// ---------FSM----------
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
// ------------FSM----------
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
                if (!in_valid)
                    n_s = S_PARI;
                else
                    n_s = S_LOAD;
            end    
          S_PARI:
            begin
                if(on_tozero == 0 && count == 15)
                    n_s = S_OUT_1;
                else
                    n_s = S_PARI;
            end                                   
          S_OUT_1:
            begin
                if(path_maxtrix[count_out] == 0)
                    n_s = S_OUT;
                else
                    n_s = S_OUT_1;
            end                                   
          S_OUT:
            begin
                if(path == 1)
                    n_s = S_IDLE;
                else
                    n_s = S_OUT;
            end                                   
          default:
              n_s = S_IDLE;
      endcase
end
// ------------FSM----------
// --------LOAD-----------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		delay_d <= 0;
		source_d <= 0;
		destination_d <= 0;		
	end
	else begin
		delay_d       <= delay;
		source_d      <= source;
		destination_d <= destination;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else if (c_s == S_LOAD) begin
		count <= count + 1;
	end
	else if (c_s == S_PARI) begin
		if (on_tozero == 1) begin
			count <= 0;
		end		
		else count <= count + 1;
	end
	else if (c_s == S_OUT) begin
		count <= 0;
	end
	else count <= count;
end
// ----------source_---------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0 ; i < 32 ; i = i + 1 ) begin
			source_[i] <= 0;
		end
	end
	else if (c_s == S_LOAD) begin
		source_[count] <= source_d;
	end
	else if (c_s == S_OUT) begin
		for (i = 0 ; i < 32 ; i = i + 1 ) begin
			source_[i] <= 0;
		end		
	end
	else begin
		for (i = 0; i < 32 ; i = i + 1 ) begin
			source_[i] <= source_[i];	
		end
	end
end
// ----------source_---------
// ----------drain-----------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0 ; i < 32 ; i = i + 1 ) begin
			drain[i] <= 0;
		end
	end
	else if (c_s == S_LOAD) begin
		drain[count] <= destination_d;
	end
	else begin
		for (i = 0; i < 32 ; i = i + 1 ) begin
			drain[i] <= drain[i];	
		end
	end
end
// ----------drain-----------

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 16 ; i = i + 1 ) begin
			self_delay[i] <= 0;
		end
	end
	else if (c_s == S_LOAD) begin
		self_delay[count] <= delay_d;
	end
	else begin
		for (i = 0; i < 16 ; i = i + 1 ) begin
			self_delay[i] <= self_delay[i];
		end
	end
end
// --------LOAD-----------
// -------count_state----------
// always @(posedge clk or negedge rst_n) begin
// 	if (!rst_n) begin
// 		count_state <= 0;
// 	end
// 	else if (c_s == S_LOAD && n_s == S_PARI) begin
// 		count_state <= 0;
// 	end
// 	else if (c_s == S_PARI) begin
// 		count_state <= count_state + 1;
// 	end
// 	else if (c_s == S_OUT_1) begin
// 		count_state <= 0;
// 	end
// 	else count_state <= count_state;
// end
// -------count_state----------
// --------counter_on20--------
// always @(posedge clk or negedge rst_n) begin
// 	if (!rst_n) begin
// 		counter_on20 <= 0;
// 	end

// 	else if (c_s == S_PARI) begin
// 		if (on_tozero == 1) begin
// 			counter_on20 <= 0;
// 		end		
// 		else counter_on20 <= counter_on20 + 1;
// 	end
// end
// --------counter_on20--------
// ----------------on----------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 32 ; i = i + 1 ) begin
			on[i] <= 0;
		end
	end
	else if (c_s == S_LOAD) begin
		for (i = 0; i < 16 ; i = i + 1 ) begin
			totaldelay[i] <= 0;
			totalpath[i] <= 0;
		end		
	end
	else if (c_s == S_PARI) begin
		if (on_tozero == 0) begin
			for (i = 0; i < 32 ; i = i + 1 ) begin 
				on[i] <= next_on[i];
			end	
		end
		else if (on[0] == 1) begin
			on[0] <= 0;			
			if (self_delay[drain[0]] + totaldelay [source_[0]] > totaldelay[drain[0]]) begin
				totaldelay[drain[0]] <= self_delay[drain[0]] + totaldelay[source_[0]];
				totalpath[drain[0]] <= source_[0]; 	
			end
			else begin
				totaldelay[drain[0]] <= totaldelay[drain[0]];
				totalpath[drain[0]] <= totalpath[drain[0]]; 
			end
		end	
		else if (on[1] == 1) begin
			on[1] <= 0;			
			if (self_delay[drain[1]] + totaldelay [source_[1]] > totaldelay[drain[1]]) begin
				totaldelay[drain[1]] <= self_delay[drain[1]] + totaldelay[source_[1]];
				totalpath[drain[1]] <= source_[1]; 
			end
			else begin
				totaldelay[drain[1]] <= totaldelay[drain[1]];
				totalpath[drain[1]] <= totalpath[drain[1]]; 
			end
		end	
		else if (on[2] == 1) begin
			on[2] <= 0;			
			if (self_delay[drain[2]] + totaldelay [source_[2]] > totaldelay[drain[2]]) begin
				totaldelay[drain[2]] <= self_delay[drain[2]] + totaldelay[source_[2]];
				totalpath[drain[2]] <= source_[2]; 
			end
			else begin
				totaldelay[drain[2]] <= totaldelay[drain[2]];
				totalpath[drain[2]] <= totalpath[drain[2]]; 
			end
		end		
		else if (on[3] == 1) begin
			on[3] <= 0;			
			if (self_delay[drain[3]] + totaldelay [source_[3]] > totaldelay[drain[3]]) begin
				totaldelay[drain[3]] <= self_delay[drain[3]] + totaldelay[source_[3]];
				totalpath[drain[3]] <= source_[3]; 
			end
			else begin
				totaldelay[drain[3]] <= totaldelay[drain[3]];
				totalpath[drain[3]] <= totalpath[drain[3]]; 
			end
		end	
		else if (on[4] == 1) begin
			on[4] <= 0;			
			if (self_delay[drain[4]] + totaldelay [source_[4]] > totaldelay[drain[4]]) begin
				totaldelay[drain[4]] <= self_delay[drain[4]] + totaldelay[source_[4]];
				totalpath[drain[4]] <= source_[4]; 
			end
			else begin
				totaldelay[drain[4]] <= totaldelay[drain[4]];
				totalpath[drain[4]] <= totalpath[drain[4]]; 
			end
		end		
		else if (on[5] == 1) begin
			on[5] <= 0;			
			if (self_delay[drain[5]] + totaldelay [source_[5]] > totaldelay[drain[5]]) begin
				totaldelay[drain[5]] <= self_delay[drain[5]] + totaldelay[source_[5]];
				totalpath[drain[5]] <= source_[5]; 
			end
			else begin
				totaldelay[drain[5]] <= totaldelay[drain[5]];
				totalpath[drain[5]] <= totalpath[drain[5]]; 
			end
		end			
		else if (on[6] == 1) begin
			on[6] <= 0;			
			if (self_delay[drain[6]] + totaldelay [source_[6]] > totaldelay[drain[6]]) begin
				totaldelay[drain[6]] <= self_delay[drain[6]] + totaldelay[source_[6]];
				totalpath[drain[6]] <= source_[6]; 
			end
			else begin
				totaldelay[drain[6]] <= totaldelay[drain[6]];
				totalpath[drain[6]] <= totalpath[drain[6]]; 
			end
		end	
		else if (on[7] == 1) begin
			on[7] <= 0;			
			if (self_delay[drain[7]] + totaldelay [source_[7]] > totaldelay[drain[7]]) begin
				totaldelay[drain[7]] <= self_delay[drain[7]] + totaldelay[source_[7]];
				totalpath[drain[7]] <= source_[7]; 
			end
			else begin
				totaldelay[drain[7]] <= totaldelay[drain[7]];
				totalpath[drain[7]] <= totalpath[drain[7]]; 
			end
		end	
		else if (on[8] == 1) begin
			on[8] <= 0;			
			if (self_delay[drain[8]] + totaldelay [source_[8]] > totaldelay[drain[8]]) begin
				totaldelay[drain[8]] <= self_delay[drain[8]] + totaldelay[source_[8]];
				totalpath[drain[8]] <= source_[8]; 
			end
			else begin
				totaldelay[drain[8]] <= totaldelay[drain[8]];
				totalpath[drain[8]] <= totalpath[drain[8]]; 
			end
		end		
		else if (on[9] == 1) begin
			on[9] <= 0;			
			if (self_delay[drain[9]] + totaldelay [source_[9]] > totaldelay[drain[9]]) begin
				totaldelay[drain[9]] <= self_delay[drain[9]] + totaldelay[source_[9]];
				totalpath[drain[9]] <= source_[9]; 
			end
			else begin
				totaldelay[drain[9]] <= totaldelay[drain[9]];
				totalpath[drain[9]] <= totalpath[drain[9]]; 
			end
		end
		else if (on[10] == 1) begin
			on[10] <= 0;			
			if (self_delay[drain[10]] + totaldelay [source_[10]] > totaldelay[drain[10]]) begin
				totaldelay[drain[10]] <= self_delay[drain[10]] + totaldelay[source_[10]];
				totalpath[drain[10]] <= source_[10]; 
				// on[10] <= 0;
			end
			else begin
				totaldelay[drain[10]] <= totaldelay[drain[10]];
				totalpath[drain[10]] <= totalpath[drain[10]]; 
			end
		end
		else if (on[11] == 1) begin
			on[11] <= 0;			
			if (self_delay[drain[11]] + totaldelay [source_[11]] > totaldelay[drain[11]]) begin
				totaldelay[drain[11]] <= self_delay[drain[11]] + totaldelay[source_[11]];
				totalpath[drain[11]] <= source_[11]; 
			end
			else begin
				totaldelay[drain[11]] <= totaldelay[drain[11]];
				totalpath[drain[11]] <= totalpath[drain[11]]; 
			end
		end		
		else if (on[12] == 1) begin
			on[12] <= 0;			
			if (self_delay[drain[12]] + totaldelay [source_[12]] > totaldelay[drain[12]]) begin
				totaldelay[drain[12]] <= self_delay[drain[12]] + totaldelay[source_[12]];
				totalpath[drain[12]] <= source_[12]; 
			end
			else begin
				totaldelay[drain[12]] <= totaldelay[drain[12]];
				totalpath[drain[12]] <= totalpath[drain[12]]; 
			end
		end		
		else if (on[13] == 1) begin
			on[13] <= 0;			
			if (self_delay[drain[13]] + totaldelay [source_[13]] > totaldelay[drain[13]]) begin
				totaldelay[drain[13]] <= self_delay[drain[13]] + totaldelay[source_[13]];
				totalpath[drain[13]] <= source_[13]; 
			end
			else begin
				totaldelay[drain[13]] <= totaldelay[drain[13]];
				totalpath[drain[13]] <= totalpath[drain[13]]; 
			end
		end	
		else if (on[14] == 1) begin
			on[14] <= 0;			
			if (self_delay[drain[14]] + totaldelay [source_[14]] > totaldelay[drain[14]]) begin
				totaldelay[drain[14]] <= self_delay[drain[14]] + totaldelay[source_[14]];
				totalpath[drain[14]] <= source_[14]; 
			end
			else begin
				totaldelay[drain[14]] <= totaldelay[drain[14]];
				totalpath[drain[14]] <= totalpath[drain[14]]; 
			end
		end
		else if (on[15] == 1) begin
			on[15] <= 0;			
			if (self_delay[drain[15]] + totaldelay [source_[15]] > totaldelay[drain[15]]) begin
				totaldelay[drain[15]] <= self_delay[drain[15]] + totaldelay[source_[15]];
				totalpath[drain[15]] <= source_[15]; 
			end
			else begin
				totaldelay[drain[15]] <= totaldelay[drain[15]];
				totalpath[drain[15]] <= totalpath[drain[15]]; 
			end
		end
		else if (on[16] == 1) begin
			on[16] <= 0;			
			if (self_delay[drain[16]] + totaldelay [source_[16]] > totaldelay[drain[16]]) begin
				totaldelay[drain[16]] <= self_delay[drain[16]] + totaldelay[source_[16]];
				totalpath[drain[16]] <= source_[16]; 
			end
			else begin
				totaldelay[drain[16]] <= totaldelay[drain[16]];
				totalpath[drain[16]] <= totalpath[drain[16]]; 
			end
		end
		else if (on[17] == 1) begin
			on[17] <= 0;			
			if (self_delay[drain[17]] + totaldelay [source_[17]] > totaldelay[drain[17]]) begin
				totaldelay[drain[17]] <= self_delay[drain[17]] + totaldelay[source_[17]];
				totalpath[drain[17]] <= source_[17]; 
			end
			else begin
				totaldelay[drain[17]] <= totaldelay[drain[17]];
				totalpath[drain[17]] <= totalpath[drain[17]]; 
			end
		end	
		else if (on[18] == 1) begin
			on[18] <= 0;			
			if (self_delay[drain[18]] + totaldelay [source_[18]] > totaldelay[drain[18]]) begin
				totaldelay[drain[18]] <= self_delay[drain[18]] + totaldelay[source_[18]];
				totalpath[drain[18]] <= source_[18]; 
			end
			else begin
				totaldelay[drain[18]] <= totaldelay[drain[18]];
				totalpath[drain[18]] <= totalpath[drain[18]]; 
			end
		end
		else if (on[19] == 1) begin
			on[19] <= 0;			
			if (self_delay[drain[19]] + totaldelay [source_[19]] > totaldelay[drain[19]]) begin
				totaldelay[drain[19]] <= self_delay[drain[19]] + totaldelay[source_[19]];
				totalpath[drain[19]] <= source_[19]; 
			end
			else begin
				totaldelay[drain[19]] <= totaldelay[drain[19]];
				totalpath[drain[19]] <= totalpath[drain[19]]; 
			end
		end
		else if (on[20] == 1) begin
			on[20] <= 0;			
			if (self_delay[drain[20]] + totaldelay [source_[20]] > totaldelay[drain[20]]) begin
				totaldelay[drain[20]] <= self_delay[drain[20]] + totaldelay[source_[20]];
				totalpath[drain[20]] <= source_[20]; 
			end
			else begin
				totaldelay[drain[20]] <= totaldelay[drain[20]];
				totalpath[drain[20]] <= totalpath[drain[20]]; 
			end
		end
		else if (on[21] == 1) begin
			on[21] <= 0;			
			if (self_delay[drain[21]] + totaldelay [source_[21]] > totaldelay[drain[21]]) begin
				totaldelay[drain[21]] <= self_delay[drain[21]] + totaldelay[source_[21]];
				totalpath[drain[21]] <= source_[21]; 
			end
			else begin
				totaldelay[drain[21]] <= totaldelay[drain[21]];
				totalpath[drain[21]] <= totalpath[drain[21]]; 
			end
		end			
		else if (on[22] == 1) begin
			on[22] <= 0;			
			if (self_delay[drain[22]] + totaldelay [source_[22]] > totaldelay[drain[22]]) begin
				totaldelay[drain[22]] <= self_delay[drain[22]] + totaldelay[source_[22]];
				totalpath[drain[22]] <= source_[22]; 
			end
			else begin
				totaldelay[drain[22]] <= totaldelay[drain[22]];
				totalpath[drain[22]] <= totalpath[drain[22]]; 
			end
		end	
		else if (on[23] == 1) begin
			on[23] <= 0;			
			if (self_delay[drain[23]] + totaldelay [source_[23]] > totaldelay[drain[23]]) begin
				totaldelay[drain[23]] <= self_delay[drain[23]] + totaldelay[source_[23]];
				totalpath[drain[23]] <= source_[23]; 
			end
			else begin
				totaldelay[drain[23]] <= totaldelay[drain[23]];
				totalpath[drain[23]] <= totalpath[drain[23]]; 
			end
		end	
		else if (on[24] == 1) begin
			on[24] <= 0;			
			if (self_delay[drain[24]] + totaldelay [source_[24]] > totaldelay[drain[24]]) begin
				totaldelay[drain[24]] <= self_delay[drain[24]] + totaldelay[source_[24]];
				totalpath[drain[24]] <= source_[24]; 
			end
			else begin
				totaldelay[drain[24]] <= totaldelay[drain[24]];
				totalpath[drain[24]] <= totalpath[drain[24]]; 
			end
		end	
		else if (on[25] == 1) begin
			on[25] <= 0;			
			if (self_delay[drain[25]] + totaldelay [source_[25]] > totaldelay[drain[25]]) begin
				totaldelay[drain[25]] <= self_delay[drain[25]] + totaldelay[source_[25]];
				totalpath[drain[25]] <= source_[25]; 
			end
			else begin
				totaldelay[drain[25]] <= totaldelay[drain[25]];
				totalpath[drain[25]] <= totalpath[drain[25]]; 
			end
		end		
		else if (on[26] == 1) begin
			on[26] <= 0;			
			if (self_delay[drain[26]] + totaldelay [source_[26]] > totaldelay[drain[26]]) begin
				totaldelay[drain[26]] <= self_delay[drain[26]] + totaldelay[source_[26]];
				totalpath[drain[26]] <= source_[26]; 
			end
			else begin
				totaldelay[drain[26]] <= totaldelay[drain[26]];
				totalpath[drain[26]] <= totalpath[drain[26]]; 
			end
		end
		else if (on[27] == 1) begin
			on[27] <= 0;			
			if (self_delay[drain[27]] + totaldelay [source_[27]] > totaldelay[drain[27]]) begin
				totaldelay[drain[27]] <= self_delay[drain[27]] + totaldelay[source_[27]];
				totalpath[drain[27]] <= source_[27]; 
			end
			else begin
				totaldelay[drain[27]] <= totaldelay[drain[27]];
				totalpath[drain[27]] <= totalpath[drain[27]]; 
			end
		end		
		else if (on[28] == 1) begin
			on[28] <= 0;			
			if (self_delay[drain[28]] + totaldelay [source_[28]] > totaldelay[drain[28]]) begin
				totaldelay[drain[28]] <= self_delay[drain[28]] + totaldelay[source_[28]];
				totalpath[drain[28]] <= source_[28]; 
			end
			else begin
				totaldelay[drain[28]] <= totaldelay[drain[28]];
				totalpath[drain[28]] <= totalpath[drain[28]]; 
			end
		end
		else if (on[29] == 1) begin
			on[29] <= 0;			
			if (self_delay[drain[29]] + totaldelay [source_[29]] > totaldelay[drain[29]]) begin
				totaldelay[drain[29]] <= self_delay[drain[29]] + totaldelay[source_[29]];
				totalpath[drain[29]] <= source_[29]; 
			end
			else begin
				totaldelay[drain[29]] <= totaldelay[drain[29]];
				totalpath[drain[29]] <= totalpath[drain[29]]; 
			end
		end
		else if (on[30] == 1) begin
			on[30] <= 0;			
			if (self_delay[drain[30]] + totaldelay [source_[30]] > totaldelay[drain[30]]) begin
				totaldelay[drain[30]] <= self_delay[drain[30]] + totaldelay[source_[30]];
				totalpath[drain[30]] <= source_[30]; 
			end
			else begin
				totaldelay[drain[30]] <= totaldelay[drain[30]];
				totalpath[drain[30]] <= totalpath[drain[30]]; 
			end
		end	
		else if (on[31] == 1) begin
			on[31] <= 0;			
			if (self_delay[drain[31]] + totaldelay [source_[31]] > totaldelay[drain[31]]) begin
				totaldelay[drain[31]] <= self_delay[drain[31]] + totaldelay[source_[31]];
				totalpath[drain[31]] <= source_[31]; 
			end
			else begin
				totaldelay[drain[31]] <= totaldelay[drain[31]];
				totalpath[drain[31]] <= totalpath[drain[31]]; 
			end
		end																																										
	end
	else begin
		for (i = 0; i < 32 ; i = i + 1 ) begin
			on[i] <= on[i];
		end
	end
end
// ----------------on----------
// ----------next_on----------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 32 ; i = i + 1 ) begin
			next_on[i] <= 0;
		end
	end
	else if (c_s == S_LOAD) begin
		if (source_d == 0) begin
			next_on[count] <= 1;
		end
		else next_on[count] <= next_on[count];
	end
	else if (c_s == S_PARI) begin
		for (n = 0; n < 32 ; n = n + 1 ) begin		
			for (m = 0; m < 32 ; m = m + 1 ) begin
				if (on[n] == 1) begin
					next_on[n] <= 0;
					if (drain[n] == source_[m]) begin
						next_on[m] <= 1;
					end
				end	
			end
		end
	end
end
// ----------next_on----------

// ---------out_data-------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_data <= 0;
	end
	else if (c_s == S_PARI) begin
		out_data <= totaldelay[1] + self_delay[0];
	end
	else out_data <= out_data;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 16 ; i = i + 1 ) begin
			path_maxtrix[i] <= 0;
		end
	end
	else if (c_s == S_LOAD) begin
		for (i = 0; i < 16 ; i = i + 1 ) begin
			path_maxtrix[i] <= 0;
		end
	end
	else if (c_s == S_PARI) begin
		for (ll = 0; ll < 16 ; ll = ll + 1) begin
			path_maxtrix[0] <= 1;
			if (ll < 16) begin
				path_maxtrix[ll + 1] <= totalpath[path_maxtrix[ll]];
			end
		end		
	end
	else begin
		for (i = 0; i < 16 ; i = i + 1 ) begin
			path_maxtrix[i] <= path_maxtrix[i];
		end		
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count_out <= 0;
	end
	else if (c_s == S_LOAD) begin
		count_out <= 0;
	end
	else if (c_s == S_OUT_1 && n_s ==S_OUT_1) begin
		count_out <= count_out + 1;
	end
	else if (c_s == S_OUT_1 && n_s == S_OUT) begin
		count_out <= count_out;
	end
	else if (c_s == S_OUT) begin
		count_out <= count_out - 1;
	end
end

// ---------out_data-------------

// -----------out data-----------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count_out_data <= 0;
	end
	else if (c_s == S_OUT) begin
		count_out_data <= count_out_data + 1;
	end
	else count_out_data <= 0;
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
	end
	else if (c_s == S_OUT) begin
		if (path == 1) begin
			out_valid <= 0;
		end
		else out_valid <= 1;
	end
	else out_valid <= out_valid;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		worst_delay <= 0;
	end
	else if (c_s == S_OUT) begin
		if (path == 1) begin
			worst_delay <= 0;
		end		
		
		else if (count_out_data == 0) begin
			worst_delay <= out_data;
		end

		else worst_delay <= 0;
	end
	else worst_delay <= 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		path <= 0;
	end
	else if (c_s == S_OUT) begin
		path <= path_maxtrix[count_out];
	end
	else path <= path;
end
// -----------out data-----------
endmodule
