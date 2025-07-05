//############################################################################
//   2025 ICLAB Spring Course
//   Sparse Matrix Multiplier (SMM)
//############################################################################

module SMM(
  // Input Port
  clk,
  rst_n,
  in_valid_size,
  in_size,
  in_valid_a,
  in_row_a,
  in_col_a,
  in_val_a,
  in_valid_b,
  in_row_b,
  in_col_b,
  in_val_b,
  // Output Port
  out_valid,
  out_row,
  out_col,
  out_val
);



//==============================================//
//                   PARAMETER                  //
//==============================================//



//==============================================//
//                   I/O PORTS                  //
//==============================================//
input             clk, rst_n, in_valid_size, in_valid_a, in_valid_b;
input             in_size;
input      [4:0]  in_row_a, in_col_a, in_row_b, in_col_b;
input      [3:0]  in_val_a, in_val_b;
output reg        out_valid;
output reg [4:0]  out_row, out_col;
output reg [8:0] out_val;


//==============================================//
//            reg & wire declaration            //
//==============================================//
reg in_valid_size_d;
reg in_size_d;
// -------- FSM -------
reg [2:0] c_s, n_s;
// reg [3:0] c_s, n_s;
parameter S0_IDLE = 4'd0;
parameter S1_SIZE16 = 4'd1;
parameter S2_SIZE32 = 4'd2;
parameter S3_LOAD = 4'd3;
parameter S4_CALU = 4'd4;
parameter S5_OUT_1 = 4'd5;
parameter S5_OUT = 4'd6;
// -------- FSM -------
// =====================================
reg [3:0] size_16_a[0:31][0:31];
reg [3:0] size_16_b[0:31][0:31];

integer i, j;

reg [4:0] in_col_a_d;
reg [4:0] in_row_a_d;
reg [3:0] in_val_a_d;
reg in_valid_a_d;

reg [4:0] in_col_b_d;
reg [4:0] in_row_b_d;
reg [3:0] in_val_b_d;
reg in_valid_b_d;
// ======================================
// ========================
reg [6:0] counter_x;
reg [6:0] counter_y;

reg [6:0] counter_x_d;
reg [6:0] counter_y_d;

reg [6:0] counter_x_d_d;
reg [6:0] counter_y_d_d;

// reg [8:0] mul_16[31:0] ;
reg [7:0] mul_16[31:0] ;

reg [8:0] sol_16;

reg [9:0] counter_sol_idx;

reg [8:0] sol_16_val[0:1023];
reg [5:0] sol_16_row[0:1023];
reg [5:0] sol_16_col[0:1023];

// =========================
reg [9:0] counter_out;

//==============================================//
//                   Design                     //
//==============================================//
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
                if (in_valid_a || in_valid_b)
                  n_s = S3_LOAD;
                else
                    n_s = S0_IDLE;
            end
          S3_LOAD:
            begin
                if ((in_valid_a || in_valid_b )== 0)
                  n_s = S4_CALU;
                else
                    n_s = S3_LOAD;
            end
          S4_CALU:
            begin                
                if (counter_x_d == 0 && counter_y_d == 16 && in_size_d == 0)
                  n_s = S5_OUT;
                else if (counter_x_d == 0 && counter_y_d == 32 && in_size_d)
                  n_s = S5_OUT;
                else
                    n_s = S4_CALU;
            end
          // S5_OUT_1:
          //   begin                
          //     n_s = S5_OUT;
          //   end
          S5_OUT:
            begin
                if (counter_out == counter_sol_idx + 1)
                  n_s = S0_IDLE;
                else
                  n_s = S5_OUT;
            end
          default:
              n_s = S0_IDLE;
      endcase
  end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    in_valid_size_d <= 0;
  end
  else in_valid_size_d <= in_valid_size;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    in_size_d <= 0;
  end
  else if (in_valid_size && !in_valid_size_d) begin
    in_size_d <= in_size;
  end
  else in_size_d <= in_size_d;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    in_col_a_d <= 0;
    in_row_a_d <= 0;
    in_val_a_d <= 0;
    in_valid_a_d <= 0;
  end
  else begin
    in_col_a_d <= in_col_a;
    in_row_a_d <= in_row_a;
    in_val_a_d <= in_val_a;
    in_valid_a_d <= in_valid_a;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    in_col_b_d <= 0;
    in_row_b_d <= 0;
    in_val_b_d <= 0;
    in_valid_b_d <= 0;
  end
  else begin
    in_col_b_d <= in_col_b;
    in_row_b_d <= in_row_b;
    in_val_b_d <= in_val_b;
    in_valid_b_d <= in_valid_b;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 32 ; i = i + 1) begin
      for (j = 0; j < 32 ; j = j + 1) begin
        size_16_a[i][j] <= 0;
      end
    end
  end
  else if (c_s == S3_LOAD) begin
    if (in_valid_a_d) begin
      size_16_a [in_row_a_d][in_col_a_d] <= in_val_a_d;
    end
    else begin
      for (i = 0; i < 32 ; i = i + 1) begin
        for (j = 0; j < 32 ; j = j + 1) begin
          size_16_a[i][j] <= size_16_a[i][j];
        end
      end
    end
  end
  else if (c_s == S5_OUT) begin
    for (i = 0; i < 32 ; i = i + 1) begin
      for (j = 0; j < 32 ; j = j + 1) begin
        size_16_a[i][j] <= 0;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 32 ; i = i + 1) begin
      for (j = 0; j < 32 ; j = j + 1) begin
        size_16_b[i][j] <= 0;
      end
    end
  end
  else if (c_s == S3_LOAD) begin
    if (in_valid_b_d) begin
      size_16_b [in_row_b_d][in_col_b_d] <= in_val_b_d;
    end
    else begin
      for (i = 0; i < 32 ; i = i + 1) begin
        for (j = 0; j < 32 ; j = j + 1) begin
          size_16_b[i][j] <= size_16_b[i][j];
        end
      end
    end
  end
  else if (c_s == S5_OUT) begin
    for (i = 0; i < 32 ; i = i + 1) begin
      for (j = 0; j < 32 ; j = j + 1) begin
        size_16_b[i][j] <= 0;
      end
    end
  end
end
// =====================================================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_x <= 0;
  end
  else if (c_s == S4_CALU) begin
    if (in_size_d == 0) begin
      if (counter_x == 15) counter_x <= 0;
      else counter_x <= counter_x + 1;      
    end
    else begin
      if (counter_x == 31) counter_x <= 0;
      else counter_x <= counter_x + 1;   
    end
  end
  else counter_x <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_y <= 0;
  end
  else if (c_s == S4_CALU) begin
    if (in_size_d == 0) begin
      if (counter_x == 15) counter_y <= counter_y + 1;
      else counter_y <= counter_y;
    end
    else begin
      if (counter_x == 31) counter_y <= counter_y + 1;
      else counter_y <= counter_y;
    end
  end
  else counter_y <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_x_d <= 0;
    counter_y_d <= 0;
  end
  else begin
    counter_x_d <= counter_x;
    counter_y_d <= counter_y;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_x_d_d <= 0;
    counter_y_d_d <= 0;
  end
  else begin
    counter_x_d_d <= counter_x_d;
    counter_y_d_d <= counter_y_d;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 32 ; i = i + 1) begin
      mul_16[i] <= 0;
    end
  end
  else if (c_s == S4_CALU) begin
    for (i = 0; i < 32 ; i = i + 1 ) begin
      mul_16[i] <= size_16_a[counter_y][i] * size_16_b[i][counter_x];
    end
  end
  else if (c_s == S3_LOAD) begin
    for (i = 0; i < 32 ; i = i + 1) begin
      mul_16[i] <= 0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sol_16 <= 0;
  end
  else if (c_s == S4_CALU) begin   
      sol_16 <= mul_16[0] +
                mul_16[1] +
                mul_16[2] +
                mul_16[3] +
                mul_16[4] +
                mul_16[5] +
                mul_16[6] +
                mul_16[7] +
                mul_16[8] +
                mul_16[9] +
                mul_16[10] +
                mul_16[11] +
                mul_16[12] +
                mul_16[13] +
                mul_16[14] +
                mul_16[15] +
                mul_16[16] +
                mul_16[17] +
                mul_16[18] +
                mul_16[19] +                 
                mul_16[20] +
                mul_16[21] +
                mul_16[22] +
                mul_16[23] +
                mul_16[24] +
                mul_16[25] +
                mul_16[26] +
                mul_16[27] +
                mul_16[28] +
                mul_16[29] +  
                mul_16[30] +             
                mul_16[31] ;   
  end
  else if (c_s == S3_LOAD) begin
    sol_16 <= 0;
  end
  else sol_16 <= sol_16;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_sol_idx <= 0;
  end
  else if (c_s == S4_CALU) begin
    if (sol_16 != 0) begin
      counter_sol_idx <= counter_sol_idx + 1;
    end
    else counter_sol_idx <= counter_sol_idx;
  end
  else if (c_s == S0_IDLE) begin
    counter_sol_idx <= 0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 1024 ; i = i + 1) begin
      sol_16_val[i] <= 0;
    end
  end
  else if (c_s == S4_CALU) begin
    if (sol_16 != 0) begin
      sol_16_val[counter_sol_idx] <= sol_16;
    end
  end
  else if (c_s == S3_LOAD) begin
    for (i = 0; i < 1024 ; i = i + 1) begin
      sol_16_val[i] <= 0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 1024 ; i = i + 1) begin
      sol_16_row[i] <= 0;
    end
  end
  else if (c_s == S4_CALU) begin
    if (sol_16 != 0) begin
      sol_16_row[counter_sol_idx] <= counter_x_d_d;
    end
  end
  else if (c_s == S3_LOAD) begin
    for (i = 0; i < 1024 ; i = i + 1) begin
      sol_16_row[i] <= 0;
    end    
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 1024 ; i = i + 1) begin
      sol_16_col[i] <= 0;
    end
  end
  else if (c_s == S4_CALU) begin
    if (sol_16 != 0) begin
      sol_16_col[counter_sol_idx] <= counter_y_d_d;
    end
  end
  else if (c_s == S3_LOAD) begin
    for (i = 0; i < 1024 ; i = i + 1) begin
      sol_16_col[i] <= 0;
    end
  end
end
// ===============================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter_out <= 0;
  end
  else if (c_s == S5_OUT) begin
    counter_out <= counter_out + 1;
  end
  else if (c_s == S4_CALU) begin
    counter_out <= 0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_valid <= 0;
  end
  else if (c_s == S5_OUT) begin
    if (counter_out == 0) out_valid <= 1;
    else if (counter_out == counter_sol_idx) begin
      out_valid <= 0;
    end
    else out_valid <= out_valid;
  end
  else out_valid <= 0;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_row <= 0;
  end
  else if (c_s == S5_OUT) begin
    if (counter_out <= counter_sol_idx) out_row <= sol_16_col[counter_out];
    else out_row <= 0;
  end
  else out_row <= out_row;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_col <= 0;
  end
  else if (c_s == S5_OUT) begin
    if (counter_out <= counter_sol_idx)out_col <= sol_16_row[counter_out];
    else out_col <= 0;
  end
  else out_col <= out_col;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_val <= 0;
  end
  else if (c_s == S5_OUT) begin
    if (counter_out <= counter_sol_idx)out_val <= sol_16_val[counter_out];
    else out_val <= 0;
  end
  else out_val <= out_val;
end


endmodule