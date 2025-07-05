module HF(
    // Input signals
    input [24:0] symbol_freq,
    // Output signals
    output reg [19:0] out_encoded
);

//================================================================
//    Wire & Registers 
//================================================================
reg [4:0] freq_a,freq_b,freq_c,freq_d,freq_e;


// initial 5 nodes
// reg [4:0] i_node_1_val,i_node_2_val,i_node_3_val,i_node_4_val,i_node_5_val;
// reg [3:0] i_node_1_sym,i_node_2_sym,i_node_3_sym,i_node_4_sym,i_node_5_sym;
// merge node (total 4 nodes)
wire [5:0] m_node_1_val; //num6
wire [6:0] m_node_2_val; //num7
wire [7:0] m_node_3_val; //num8
wire [8:0] m_node_4_val; //num9
// reg [5:0] m_node_1_val; //num6
// reg [6:0] m_node_2_val; //num7
// reg [7:0] m_node_3_val; //num8
// reg [8:0] m_node_4_val; //num9
// merge node subnode number (save what number under this nodes)
reg [7:0] m_node_1_num; //2 [3:0] number so {[7:4],[3:0]}
reg [7:0] m_node_2_num; 
reg [7:0] m_node_3_num; 
reg [7:0] m_node_4_num;


// 5 num comparator {symbol[2:0],value[4:0]}
reg [8:0] lev1_1,lev1_2,lev1_3,lev1_4;
reg [8:0] lev2_1,lev2_2,lev2_3,lev2_4;
reg [8:0] lev3_1,lev3_2;
reg [8:0] lev4_1,lev4_2,lev4_3,lev4_4,lev4_5;
// 4 num comparator {symbol[2:0],value[4:0]}
reg [9:0] s2_1,s2_2,s2_3,s2_4;
reg [10:0] s3_1,s3_2,s3_3;
reg [11:0] s4_1,s4_2;
reg [11:0] s5_1;

// huffman code
  reg[3:0] huf_code_1;
  reg[3:0] huf_code_2;
  reg[3:0] huf_code_3;
  reg[3:0] huf_code_4;
  reg[3:0] huf_code_5;

// can delete it just for debug
//=============================================
//   reg [4:0] intial_value[4:0];
//   always @(*) begin 
//       intial_value[4] = symbol_freq[4:0];
//       intial_value[3] = symbol_freq[9:5];
//       intial_value[2] = symbol_freq[14:10];
//       intial_value[1] = symbol_freq[19:15];
//       intial_value[0] = symbol_freq[24:20];  
//   end
//   reg [8:0] tmp_val_1[4:0];
//   always @(*) begin 
//       tmp_val_1[4] = s4_1[10:4];//s2_1[8:4];
//       tmp_val_1[3] = s4_2[10:4];//s2_2[8:4];
//       tmp_val_1[2] = 0;//s2_3[8:4];
//       tmp_val_1[1] = 0;//s2_4[8:4];
//       tmp_val_1[0] = 0;//0;  
//   end
//   reg [3:0] tmp_sym_1[4:0];
//   always @(*) begin 
//       tmp_sym_1[4] = s4_1[3:0]; //s1_1[3:0];
//       tmp_sym_1[3] = s4_2[3:0]; //s1_2[3:0];
//       tmp_sym_1[2] = 0; //s1_3[3:0];
//       tmp_sym_1[1] = 0; //s1_4[3:0];
//       tmp_sym_1[0] = 0; //s1_5[3:0];  
//   end
//   reg [3:0] tmp_mmode1_num[0:1];
//   reg [3:0] tmp_mmode2_num[0:1];
//   reg [3:0] tmp_mmode3_num[0:1];
//   reg [3:0] tmp_mmode4_num[0:1];
//   always @(*) begin 
//     tmp_mmode1_num[0] = m_node_1_num[8:4];
//     tmp_mmode1_num[1] = m_node_1_num[3:0];
  
//     tmp_mmode2_num[0] = m_node_2_num[8:4];
//     tmp_mmode2_num[1] = m_node_2_num[3:0];
    
//     tmp_mmode3_num[0] = m_node_3_num[8:4];
//     tmp_mmode3_num[1] = m_node_3_num[3:0];
    
//     tmp_mmode4_num[0] = m_node_4_num[8:4];
//     tmp_mmode4_num[1] = m_node_4_num[3:0];      
//   end
//==============================================

// initial nodes 1~5
// always @(*) begin
//     i_node_1_val = lev4_1[8:4];
//     i_node_2_val = lev4_2[8:4];
//     i_node_3_val = lev4_3[8:4];
//     i_node_4_val = lev4_4[8:4];
//     i_node_5_val = lev4_5[8:4];
//     i_node_1_sym = lev4_1[3:0];
//     i_node_2_sym = lev4_2[3:0];
//     i_node_3_sym = lev4_3[3:0];
//     i_node_4_sym = lev4_4[3:0];
//     i_node_5_sym = lev4_5[3:0];    
// end

// merged nodes 1~4

assign m_node_1_val = lev4_1[8:4] + lev4_2[8:4];
assign m_node_2_val = s2_1  [9:4] +  s2_2  [9:4];
assign m_node_3_val = s3_1  [10:4] + s3_2  [10:4];
assign m_node_4_val = s4_1  [11:4] + s4_2  [11:4];

// always @(*)begin
//   m_node_1_val = lev4_1[8:4] + lev4_2[8:4];
//   m_node_2_val = s2_1[9:4] + s2_2[9:4];
//   m_node_3_val = s3_1[10:4] + s3_2[10:4];
//   m_node_4_val = s4_1[11:4] + s4_2[11:4];
// end
//  m_node number
  always @(*)begin
    if(lev4_1[8:4]<=lev4_2[8:4]) m_node_1_num = {lev4_1[3:0],lev4_2[3:0]};
    else m_node_1_num = {lev4_2[3:0],lev4_1[3:0]};
  end
  always @(*)begin
    if(s2_1[9:4]<s2_2[9:4]) m_node_2_num = {s2_1[3:0],s2_2[3:0]};
    else if(s2_1[9:4]==s2_2[9:4]) m_node_2_num = {s2_1[3:0],s2_2[3:0]};
    else m_node_2_num = {s2_2[3:0],s2_1[3:0]};
  end
  always @(*)begin
    if(s3_1[10:4]<s3_2[10:4]) m_node_3_num = {s3_1[3:0],s3_2[3:0]};
    else if(s3_1[10:4]==s3_2[10:4])begin
      if(s3_1[3:0]>5)begin
        if(s3_2[3:0]>5) begin
          if(s3_1[3:0]<s3_2[3:0]) m_node_3_num = {s3_1[3:0],s3_2[3:0]};
          else m_node_3_num = {s3_2[3:0],s3_1[3:0]};
        end
        else  m_node_3_num = {s3_1[3:0],s3_2[3:0]};
      end
      else begin
        if(s3_2[3:0]>5) m_node_3_num = {s3_2[3:0],s3_1[3:0]};
        else begin
          if(s3_1[3:0]<s3_2[3:0]) m_node_3_num = {s3_1[3:0],s3_2[3:0]};
          else  m_node_3_num = {s3_2[3:0],s3_1[3:0]};
        end
      end
    end
    else m_node_3_num = {s3_2[3:0],s3_1[3:0]};
  end
  always @(*)begin
    if(s4_1[11:4]<s4_2[11:4]) m_node_4_num = {s4_1[3:0],s4_2[3:0]};
    else m_node_4_num = {s4_2[3:0],s4_1[3:0]};
  end    
//================================================================
//    DESIGN
//================================================================
//------------INPUT-----------------
always @(*) begin
    freq_e =symbol_freq[4:0];
    freq_d =symbol_freq[9:5];
    freq_c =symbol_freq[14:10];
    freq_b =symbol_freq[19:15];
    freq_a =symbol_freq[24:20];
end

// stage 1
  //------------5 comparator level 1-----------------
  always @(*) begin
    if(freq_a<=freq_b) begin 
      lev1_1 = {freq_a,4'b0001};
      lev1_2 = {freq_b,4'b0010};
    end
    else begin
      lev1_2 = {freq_a,4'b0001};
      lev1_1 = {freq_b,4'b0010};
    end
  end
  always @(*) begin
    if(freq_c<=freq_d) begin 
      lev1_3 = {freq_c,4'b0011};
      lev1_4 = {freq_d,4'b0100};
    end
    else begin
      lev1_4 = {freq_c,4'b0011};
      lev1_3 = {freq_d,4'b0100};
    end
  end
  //------------5 comparator level 2-----------------
  always @(*) begin
  if(lev1_1[8:4]<=lev1_3[8:4]) begin 
    lev2_1 = lev1_1;
    lev2_2 = lev1_3;
  end
  else begin
    lev2_2 = lev1_1;
    lev2_1 = lev1_3;
  end
  end
  always @(*) begin
    if(lev1_2[8:4]<=lev1_4[8:4]) begin 
      lev2_3 = lev1_2;
      lev2_4 = lev1_4;
    end
    else begin
      lev2_4 = lev1_2;
      lev2_3 = lev1_4;
    end
  end
  //------------5 comparator level 3-----------------
  always @(*) begin
    if(lev2_2[8:4]<lev2_3[8:4]) begin 
      lev3_1 = lev2_2;
      lev3_2 = lev2_3;
    end
    else if(lev2_2[8:4]==lev2_3[8:4]) begin 
      if(lev2_2[3:0]<lev2_3[3:0]) begin
        lev3_1 = lev2_2;
        lev3_2 = lev2_3;
      end
      else begin
        lev3_2 = lev2_2;
        lev3_1 = lev2_3;  
      end
    end
    else begin
      lev3_2 = lev2_2;
      lev3_1 = lev2_3;
    end
  end
  //------------5 comparator level 4-----------------
  always @(*) begin
    if(lev2_1[8:4] <= freq_e)begin
      if(lev3_1[8:4] <= freq_e)begin
        if(lev3_2[8:4] <= freq_e)begin
          if(lev2_4[8:4] <= freq_e)begin
            lev4_1 = lev2_1;
            lev4_2 = lev3_1;
            lev4_3 = lev3_2;
            lev4_4 = lev2_4;
            lev4_5 = {freq_e,4'b0101}; 
          end
          else begin
            lev4_1 = lev2_1;
            lev4_2 = lev3_1;
            lev4_3 = lev3_2;
            lev4_4 = {freq_e,4'b0101};
            lev4_5 = lev2_4;         
          end 
        end  
        else begin
          lev4_1 = lev2_1;
          lev4_2 = lev3_1;
          lev4_3 = {freq_e,4'b0101};
          lev4_4 = lev3_2;
          lev4_5 = lev2_4;       
        end        
      end 
      else begin
        lev4_1 = lev2_1;
        lev4_2 = {freq_e,4'b0101};
        lev4_3 = lev3_1;
        lev4_4 = lev3_2;
        lev4_5 = lev2_4;     
      end   
    end
    else begin
      lev4_1 = {freq_e,4'b0101};
      lev4_2 = lev2_1;
      lev4_3 = lev3_1;
      lev4_4 = lev3_2;
      lev4_5 = lev2_4; 
    end
  end


//------------4 comparator stage 2 ---------------
  always @(*) begin
    if(lev4_3[8:4] < m_node_1_val)begin
      if(lev4_4[8:4] < m_node_1_val)begin
        if(lev4_5[8:4] < m_node_1_val)begin
          s2_1 = lev4_3;
          s2_2 = lev4_4;
          s2_3 = lev4_5;
          s2_4 = {m_node_1_val,4'd6};
        end
        else begin
          s2_1 = lev4_3;
          s2_2 = lev4_4;
          s2_3 = {m_node_1_val,4'd6};
          s2_4 = lev4_5;
        end
      end
      else begin
        s2_1 = lev4_3;
        s2_2 = {m_node_1_val,4'd6};
        s2_3 = lev4_4;
        s2_4 = lev4_5;       
      end 
    end     
    else begin
        s2_1 = {m_node_1_val,4'd6};
        s2_2 = lev4_3;
        s2_3 = lev4_4;
        s2_4 = lev4_5;       
    end        
  end
//------------3 comparator stage 3 ---------------
  always @(*) begin
    if(s2_3[9:4] < m_node_2_val)begin
      if(s2_4[9:4] < m_node_2_val)begin
        s3_1 = s2_3;
        s3_2 = s2_4;
        s3_3 = {m_node_2_val,4'd7};  
      end
      else begin
        s3_1 = s2_3;
        s3_2 = {m_node_2_val,4'd7};
        s3_3 = s2_4;      
      end 
    end  
    // else if(s2_3[9:4] == m_node_2_val)begin
    //   if (s2_3[3:0] <)
    // end
    else begin
        s3_1 = {m_node_2_val,4'd7};
        s3_2 = s2_3;
        s3_3 = s2_4;    
    end        
  end
//------------2 comparator stage 4 ---------------
  always @(*) begin
    if(s3_3[10:4] <= m_node_3_val)begin
        s4_1 = s3_3;
        s4_2 = {m_node_3_val,4'd8};   
    end  
    else begin
        s4_1 = {m_node_3_val,4'd8};
        s4_2 = s3_3;   
    end        
  end
//------------1 comparator stage 5 ---------------
  always @(*) begin
   s5_1 = {(s4_1 + s4_2),4'd9};
  end

// huffman code
  always @(*) begin // number: 1 (a)
  //begin at node 6
    if(m_node_1_num[7:4]==1)begin //1-6
    if(m_node_2_num[7:4]==6)begin //1-6-7
      if(m_node_3_num[7:4]==7)begin //1-6-7-8
        if(m_node_4_num[7:4]==8)begin //1-6-7-8-9
          huf_code_1 = 'b0000;
        end
        else begin //1-6-7-8+9
          huf_code_1 = 'b1000;
        end
      end
      else if(m_node_3_num[3:0]==7)begin //1-6-7+8
        if(m_node_4_num[7:4]==8)begin //1-6-7+8-9
          huf_code_1 = 'b0100;
        end
        else begin //1-6-7+8+9
          huf_code_1 = 'b1100;
        end
      end 
      else if(m_node_4_num[7:4]==7)begin//1-6-7-9
        huf_code_1 = 'b000;
      end
      else begin //m_node_4_num[3:0]==7 //1-6-7+9
        huf_code_1 = 'b100;
      end
    end
    else if(m_node_2_num[3:0]==6)begin//1-6+7-
      if(m_node_3_num[7:4]==7)begin //1-6+7-8
        if(m_node_4_num[7:4]==8)begin //1-6+7-8-9
          huf_code_1 = 'b0010;
        end
        else begin //1-6+7-8+9
          huf_code_1 = 'b1010;
        end
      end
      else if(m_node_3_num[3:0]==7)begin //1-6+7+8
        if(m_node_4_num[7:4]==8)begin //1-6+7+8-9
          huf_code_1 = 'b0110;
        end
        else begin //1-6+7+8+9
          huf_code_1 = 'b1110;
        end
      end 
      else if(m_node_4_num[7:4]==7)begin//1-6+7-9
        huf_code_1 = 'b010;
      end
      else begin //m_node_4_num[3:0]==7 //1-6+7+9
        huf_code_1 = 'b110;
      end
    end
    else if(m_node_3_num[7:4]==6)begin//1-6-8
      if(m_node_4_num[7:4]==8)begin//1-6-8-9
        huf_code_1 = 'b000;
      end
      else begin //1-6-8+9
        huf_code_1 = 'b100;
      end
    end
    else if(m_node_3_num[3:0]==6)begin//1-6+8
      if(m_node_4_num[7:4]==8)begin//1-6+8-9
        huf_code_1 = 'b010;
      end
      else begin //1-6+8+9
        huf_code_1 = 'b110;
      end
    end
    else if(m_node_4_num[7:4]==6)begin//1-6-9
      huf_code_1 = 'b00;
    end
    else begin //1-6+9
      huf_code_1 = 'b10;
    end
    end 
    else if(m_node_1_num[3:0]==1)begin //1+6 
    if(m_node_2_num[7:4]==6)begin //1+6-7
      if(m_node_3_num[7:4]==7)begin //1+6-7-8
        if(m_node_4_num[7:4]==8)begin //1+6-7-8-9
          huf_code_1 = 'b0001;
        end
        else begin //1+6-7-8+9
          huf_code_1 = 'b1001;
        end
      end
      else if(m_node_3_num[3:0]==7)begin //1+6-7+8
        if(m_node_4_num[7:4]==8)begin //1+6-7+8-9
          huf_code_1 = 'b0101;
        end
        else begin //1+6-7+8+9
          huf_code_1 = 'b1101;
        end
      end 
      else if(m_node_4_num[7:4]==7)begin//1+6-7-9
        huf_code_1 = 'b001;
      end
      else begin //m_node_4_num[3:0]==7 //1+6-7+9
        huf_code_1 = 'b101;
      end
    end
    else if(m_node_2_num[3:0]==6) begin//1+6+7-
      if(m_node_3_num[7:4]==7)begin //1+6+7-8
        if(m_node_4_num[7:4]==8)begin //1+6+7-8-9
          huf_code_1 = 'b0011;
        end
        else begin //1+6+7-8+9
          huf_code_1 = 'b1011;
        end
      end
      else if(m_node_3_num[3:0]==7)begin //1+6+7+8
        if(m_node_4_num[7:4]==8)begin //1+6+7+8-9
          huf_code_1 = 'b0111;
        end
        else begin //1+6+7+8+9
          huf_code_1 = 'b1111;
        end
      end 
      else if(m_node_4_num[7:4]==7)begin//1+6+7-9
        huf_code_1 = 'b011;
      end
      else begin //m_node_4_num[3:0]==7 //1+6+7+9
        huf_code_1 = 'b111;
      end
    end
    else if(m_node_3_num[7:4]==6)begin//1+6-8
      if(m_node_4_num[7:4]==8)begin//1+6-8-9
        huf_code_1 = 'b001;
      end
      else begin //1+6-8+9
        huf_code_1 = 'b101;
      end
    end
    else if(m_node_3_num[3:0]==6)begin//1+6+8
      if(m_node_4_num[7:4]==8)begin//1+6+8-9
        huf_code_1 = 'b011;
      end
      else begin //1+6+8+9
        huf_code_1 = 'b111;
      end
    end
    else if(m_node_4_num[7:4]==6)begin//1+6-9
      huf_code_1 = 'b01;
    end
    else begin //1+6+9
      huf_code_1 = 'b11;
    end
    end   
  //begin at node 7  
    else if(m_node_2_num[7:4]==1)begin //1-7-
    if(m_node_3_num[7:4]==7)begin //1-7-8-9
      if (m_node_4_num[7:4]==8)  huf_code_1 = 'b000;
      else   huf_code_1 = 'b100;
    end
    else if (m_node_3_num[3:0]==7)begin //1-7-8-9
      if (m_node_4_num[7:4]==8)  huf_code_1 = 'b010;
      else   huf_code_1 = 'b110;
    end
    else begin // 1-7-9
      if(m_node_4_num[7:4]==7) begin
        huf_code_1 = 'b00;
      end
      else begin // m_node_4_num[3:0]==7
        huf_code_1 = 'b10;
      end
    end
    end
    else if(m_node_2_num[3:0]==1)begin //1+7-
    if(m_node_3_num[7:4]==7)begin //1+7-8-9
      if (m_node_4_num[7:4]==8)  huf_code_1 = 'b001;
      else   huf_code_1 = 3'b101;
    end
    else if (m_node_3_num[3:0]==7)begin //1+7-8-9
      if (m_node_4_num[7:4]==8)  huf_code_1 = 'b011;
      else   huf_code_1 = 'b111;
    end
    else begin // 1+7-9
      if(m_node_4_num[7:4]==7) begin
        huf_code_1 = 'b01;
      end
      else begin // m_node_4_num[3:0]==7
        huf_code_1 = 'b11;
      end
    end
    end
  //begin at node 8  
    else if(m_node_3_num[7:4]==1)begin //1-8
      if(m_node_4_num[7:4]==8)begin //1-8-9
        huf_code_1 = 0;//00
      end
      else begin //m_node_4_num[3:0]==8 //1-8+9
        huf_code_1 = 'b10;
      end
    end
    else if(m_node_3_num[3:0]==1)begin  //1+8
      if(m_node_4_num[7:4]==8)begin //1+8-9
        huf_code_1 = 'b01;
      end
      else begin //m_node_4_num[3:0]==8 //1+8+9
        huf_code_1 = 'b11;
      end
    end
  //begin at node 9  
    else if(m_node_4_num[7:4]==1) huf_code_1 = 0;
    else if(m_node_4_num[3:0]==1) huf_code_1 = 1'b1;   
    else     huf_code_1 = 0;
  end
// number 2
  always @(*) begin // number: 2 (a)
  //begin at node 6
    if(m_node_1_num[7:4]==2)begin //1-6
      if(m_node_2_num[7:4]==6)begin //1-6-7
        if(m_node_3_num[7:4]==7)begin //1-6-7-8
          if(m_node_4_num[7:4]==8)begin //1-6-7-8-9
            huf_code_2 = 'b0000;
          end
          else begin //1-6-7-8+9
            huf_code_2 = 'b1000;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6-7+8
          if(m_node_4_num[7:4]==8)begin //1-6-7+8-9
            huf_code_2 = 'b0100;
          end
          else begin //1-6-7+8+9
            huf_code_2 = 'b1100;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6-7-9
          huf_code_2 = 'b000;
        end
        else begin //m_node_4_num[3:0]==7 //1-6-7+9
          huf_code_2 = 'b100;
        end
      end
      else if(m_node_2_num[3:0]==6) begin//1-6+7-
        if(m_node_3_num[7:4]==7)begin //1-6+7-8
          if(m_node_4_num[7:4]==8)begin //1-6+7-8-9
            huf_code_2 = 'b0010;
          end
          else begin //1-6+7-8+9
            huf_code_2 = 'b1010;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6+7+8
          if(m_node_4_num[7:4]==8)begin //1-6+7+8-9
            huf_code_2 = 'b0110;
          end
          else begin //1-6+7+8+9
            huf_code_2 = 'b1110;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6+7-9
          huf_code_2 = 'b010;
        end
        else begin //m_node_4_num[3:0]==7 //1-6+7+9
          huf_code_2 = 'b110;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1-6-8
        if(m_node_4_num[7:4]==8)begin//1-6-8-9
          huf_code_2 = 'b000;
        end
        else begin //1-6-8+9
          huf_code_2 = 'b100;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1-6+8
        if(m_node_4_num[7:4]==8)begin//1-6+8-9
          huf_code_2 = 'b010;
        end
        else begin //1-6+8+9
          huf_code_2 = 'b110;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1-6-9
        huf_code_2 = 'b00;
      end
      else begin //1-6+9
        huf_code_2 = 'b10;
      end
    end 
    else if(m_node_1_num[3:0]==2)begin //1+6 
      if(m_node_2_num[7:4]==6)begin //1+6-7
        if(m_node_3_num[7:4]==7)begin //1+6-7-8
          if(m_node_4_num[7:4]==8)begin //1+6-7-8-9
            huf_code_2 = 'b0001;
          end
          else begin //1+6-7-8+9
            huf_code_2 = 'b1001;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6-7+8
          if(m_node_4_num[7:4]==8)begin //1+6-7+8-9
            huf_code_2 = 'b0101;
          end
          else begin //1+6-7+8+9
            huf_code_2 = 'b1101;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6-7-9
          huf_code_2 = 'b001;
        end
        else begin //m_node_4_num[3:0]==7 //1+6-7+9
          huf_code_2 = 'b101;
        end
      end
      else if(m_node_2_num[3:0]==6) begin//1+6+7-
        if(m_node_3_num[7:4]==7)begin //1+6+7-8
          if(m_node_4_num[7:4]==8)begin //1+6+7-8-9
            huf_code_2 = 'b0011;
          end
          else begin //1+6+7-8+9
            huf_code_2 = 'b1011;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6+7+8
          if(m_node_4_num[7:4]==8)begin //1+6+7+8-9
            huf_code_2 = 'b0111;
          end
          else begin //1+6+7+8+9
            huf_code_2 = 'b1111;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6+7-9
          huf_code_2 = 'b011;
        end
        else begin //m_node_4_num[3:0]==7 //1+6+7+9
          huf_code_2 = 'b111;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1+6-8
        if(m_node_4_num[7:4]==8)begin//1+6-8-9
          huf_code_2 = 'b001;
        end
        else begin //1+6-8+9
          huf_code_2 = 'b101;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1+6+8
        if(m_node_4_num[7:4]==8)begin//1+6+8-9
          huf_code_2 = 'b011;
        end
        else begin //1+6+8+9
          huf_code_2 = 'b111;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1+6-9
        huf_code_2 = 'b01;
      end
      else begin //1+6+9
        huf_code_2 = 'b11;
      end
    end   
  //begin at node 7  
    else if(m_node_2_num[7:4]==2)begin //1-7-
      if(m_node_3_num[7:4]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_2 = 'b000;
        else   huf_code_2 = 'b100;
      end
      else if (m_node_3_num[3:0]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_2 = 'b010;
        else   huf_code_2 = 'b110;
      end
      else begin // 1-7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_2 = 'b00;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_2 = 'b10;
        end
      end
    end
    else if(m_node_2_num[3:0]==2)begin //1+7-
      if(m_node_3_num[7:4]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_2 = 'b001;
        else   huf_code_2 = 3'b101;
      end
      else if (m_node_3_num[3:0]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_2 = 'b011;
        else   huf_code_2 = 'b111;
      end
      else begin // 1+7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_2 = 'b01;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_2 = 'b11;
        end
      end
    end
  //begin at node 8  
    else if(m_node_3_num[7:4]==2)begin //1-8
      if(m_node_4_num[7:4]==8)begin //1-8-9
        huf_code_2 = 0;//00
      end
      else begin //m_node_4_num[3:0]==8 //1-8+9
        huf_code_2 = 'b10;
      end
    end
    else if(m_node_3_num[3:0]==2)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_2 = 'b01;
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_2 = 'b11;
      end
    end
  //begin at node 9  
    else if(m_node_4_num[7:4]==2) huf_code_2 = 0;
    else if(m_node_4_num[3:0]==2) huf_code_2 = 1'b1;   
    else     huf_code_2 = 0;
  end
// number 3
  always @(*) begin
  //begin at node 6
    if(m_node_1_num[7:4]==3)begin //1-6
      if(m_node_2_num[7:4]==6)begin //1-6-7
        if(m_node_3_num[7:4]==7)begin //1-6-7-8
          if(m_node_4_num[7:4]==8)begin //1-6-7-8-9
            huf_code_3 = 'b0000;
          end
          else begin //1-6-7-8+9
            huf_code_3 = 'b1000;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6-7+8
          if(m_node_4_num[7:4]==8)begin //1-6-7+8-9
            huf_code_3 = 'b0100;
          end
          else begin //1-6-7+8+9
            huf_code_3 = 'b1100;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6-7-9
          huf_code_3 = 'b000;
        end
        else begin //m_node_4_num[3:0]==7 //1-6-7+9
          huf_code_3 = 'b100;
        end
      end
      else if(m_node_2_num[3:0]==6) begin//1-6+7-
        if(m_node_3_num[7:4]==7)begin //1-6+7-8
          if(m_node_4_num[7:4]==8)begin //1-6+7-8-9
            huf_code_3 = 'b0010;
          end
          else begin //1-6+7-8+9
            huf_code_3 = 'b1010;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6+7+8
          if(m_node_4_num[7:4]==8)begin //1-6+7+8-9
            huf_code_3 = 'b0110;
          end
          else begin //1-6+7+8+9
            huf_code_3 = 'b1110;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6+7-9
          huf_code_3 = 'b010;
        end
        else begin //m_node_4_num[3:0]==7 //1-6+7+9
          huf_code_3 = 'b110;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1-6-8
        if(m_node_4_num[7:4]==8)begin//1-6-8-9
          huf_code_3 = 'b000;
        end
        else begin //1-6-8+9
          huf_code_3 = 'b100;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1-6+8
        if(m_node_4_num[7:4]==8)begin//1-6+8-9
          huf_code_3 = 'b010;
        end
        else begin //1-6+8+9
          huf_code_3 = 'b110;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1-6-9
        huf_code_3 = 'b00;
      end
      else begin //1-6+9
        huf_code_3 = 'b10;
      end
    end 
    else if(m_node_1_num[3:0]==3)begin //1+6 
      if(m_node_2_num[7:4]==6)begin //1+6-7
        if(m_node_3_num[7:4]==7)begin //1+6-7-8
          if(m_node_4_num[7:4]==8)begin //1+6-7-8-9
            huf_code_3 = 'b0001;
          end
          else begin //1+6-7-8+9
            huf_code_3 = 'b1001;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6-7+8
          if(m_node_4_num[7:4]==8)begin //1+6-7+8-9
            huf_code_3 = 'b0101;
          end
          else begin //1+6-7+8+9
            huf_code_3 = 'b1101;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6-7-9
          huf_code_3 = 'b001;
        end
        else begin //m_node_4_num[3:0]==7 //1+6-7+9
          huf_code_3 = 'b101;
        end
      end
      else if(m_node_2_num[3:0]==6) begin//1+6+7-
        if(m_node_3_num[7:4]==7)begin //1+6+7-8
          if(m_node_4_num[7:4]==8)begin //1+6+7-8-9
            huf_code_3 = 'b0011;
          end
          else begin //1+6+7-8+9
            huf_code_3 = 'b1011;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6+7+8
          if(m_node_4_num[7:4]==8)begin //1+6+7+8-9
            huf_code_3 = 'b0111;
          end
          else begin //1+6+7+8+9
            huf_code_3 = 'b1111;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6+7-9
          huf_code_3 = 'b011;
        end
        else begin //m_node_4_num[3:0]==7 //1+6+7+9
          huf_code_3 = 'b111;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1+6-8
        if(m_node_4_num[7:4]==8)begin//1+6-8-9
          huf_code_3 = 'b001;
        end
        else begin //1+6-8+9
          huf_code_3 = 'b101;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1+6+8
        if(m_node_4_num[7:4]==8)begin//1+6+8-9
          huf_code_3 = 'b011;
        end
        else begin //1+6+8+9
          huf_code_3 = 'b111;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1+6-9
        huf_code_3 = 'b01;
      end
      else begin //1+6+9
        huf_code_3 = 'b11;
      end
    end   
  //begin at node 7  
    else if(m_node_2_num[7:4]==3)begin //1-7-
      if(m_node_3_num[7:4]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_3 = 'b000;
        else   huf_code_3 = 'b100;
      end
      else if (m_node_3_num[3:0]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_3 = 'b010;
        else   huf_code_3 = 'b110;
      end
      else begin // 1-7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_3 = 'b00;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_3 = 'b10;
        end
      end
    end
    else if(m_node_2_num[3:0]==3)begin //1+7-
      if(m_node_3_num[7:4]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_3 = 'b001;
        else   huf_code_3 = 3'b101;
      end
      else if (m_node_3_num[3:0]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_3 = 'b011;
        else   huf_code_3 = 'b111;
      end
      else begin // 1+7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_3 = 'b01;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_3 = 'b11;
        end
      end
    end
  //begin at node 8  
    else if(m_node_3_num[7:4]==3)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_3 = 0;//00
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_3 = 'b10;
      end
    end
    else if(m_node_3_num[3:0]==3)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_3 = 'b01;
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_3 = 'b11;
      end
    end
  //begin at node 9  
    else if(m_node_4_num[7:4]==3) huf_code_3 = 0;
    else if(m_node_4_num[3:0]==3) huf_code_3 = 1'b1;   
    else     huf_code_3 = 0;
  end
// number 4
  always @(*) begin
  //begin at node 6
    if(m_node_1_num[7:4]==4)begin //1-6
      if(m_node_2_num[7:4]==6)begin //1-6-7
        if(m_node_3_num[7:4]==7)begin //1-6-7-8
          if(m_node_4_num[7:4]==8)begin //1-6-7-8-9
            huf_code_4 = 'b0000;
          end
          else begin //1-6-7-8+9
            huf_code_4 = 'b1000;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6-7+8
          if(m_node_4_num[7:4]==8)begin //1-6-7+8-9
            huf_code_4 = 'b0100;
          end
          else begin //1-6-7+8+9
            huf_code_4 = 'b1100;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6-7-9
          huf_code_4 = 'b000;
        end
        else begin //m_node_4_num[3:0]==7 //1-6-7+9
          huf_code_4 = 'b100;
        end
      end
      else if(m_node_2_num[3:0]==6)begin//1-6+7-
        if(m_node_3_num[7:4]==7)begin //1-6+7-8
          if(m_node_4_num[7:4]==8)begin //1-6+7-8-9
            huf_code_4 = 'b0010;
          end
          else begin //1-6+7-8+9
            huf_code_4 = 'b1010;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6+7+8
          if(m_node_4_num[7:4]==8)begin //1-6+7+8-9
            huf_code_4 = 'b0110;
          end
          else begin //1-6+7+8+9
            huf_code_4 = 'b1110;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6+7-9
          huf_code_4 = 'b010;
        end
        else begin //m_node_4_num[3:0]==7 //1-6+7+9
          huf_code_4 = 'b110;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1-6-8
        if(m_node_4_num[7:4]==8)begin//1-6-8-9
          huf_code_4 = 'b000;
        end
        else begin //1-6-8+9
          huf_code_4 = 'b100;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1-6+8
        if(m_node_4_num[7:4]==8)begin//1-6+8-9
          huf_code_4 = 'b010;
        end
        else begin //1-6+8+9
          huf_code_4 = 'b110;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1-6-9
        huf_code_4 = 'b00;
      end
      else begin //1-6+9
        huf_code_4 = 'b10;
      end
    end 
    else if(m_node_1_num[3:0]==4)begin //1+6 
      if(m_node_2_num[7:4]==6)begin //1+6-7
        if(m_node_3_num[7:4]==7)begin //1+6-7-8
          if(m_node_4_num[7:4]==8)begin //1+6-7-8-9
            huf_code_4 = 'b0001;
          end
          else begin //1+6-7-8+9
            huf_code_4 = 'b1001;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6-7+8
          if(m_node_4_num[7:4]==8)begin //1+6-7+8-9
            huf_code_4 = 'b0101;
          end
          else begin //1+6-7+8+9
            huf_code_4 = 'b1101;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6-7-9
          huf_code_4 = 'b001;
        end
        else begin //m_node_4_num[3:0]==7 //1+6-7+9
          huf_code_4 = 'b101;
        end
      end
      else if(m_node_2_num[3:0]==6)begin//1+6+7-
        if(m_node_3_num[7:4]==7)begin //1+6+7-8
          if(m_node_4_num[7:4]==8)begin //1+6+7-8-9
            huf_code_4 = 'b0011;
          end
          else begin //1+6+7-8+9
            huf_code_4 = 'b1011;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6+7+8
          if(m_node_4_num[7:4]==8)begin //1+6+7+8-9
            huf_code_4 = 'b0111;
          end
          else begin //1+6+7+8+9
            huf_code_4 = 'b1111;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6+7-9
          huf_code_4 = 'b011;
        end
        else begin //m_node_4_num[3:0]==7 //1+6+7+9
          huf_code_4 = 'b111;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1+6-8
        if(m_node_4_num[7:4]==8)begin//1+6-8-9
          huf_code_4 = 'b001;
        end
        else begin //1+6-8+9
          huf_code_4 = 'b101;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1+6+8
        if(m_node_4_num[7:4]==8)begin//1+6+8-9
          huf_code_4 = 'b011;
        end
        else begin //1+6+8+9
          huf_code_4 = 'b111;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1+6-9
        huf_code_4 = 'b01;
      end
      else begin //1+6+9
        huf_code_4 = 'b11;
      end
    end   
  //begin at node 7  
    else if(m_node_2_num[7:4]==4)begin //1-7-
      if(m_node_3_num[7:4]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_4 = 'b000;
        else   huf_code_4 = 'b100;
      end
      else if (m_node_3_num[3:0]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_4 = 'b010;
        else   huf_code_4 = 'b110;
      end
      else begin // 1-7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_4 = 'b00;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_4 = 'b10;
        end
      end
    end
    else if(m_node_2_num[3:0]==4)begin //1+7-
      if(m_node_3_num[7:4]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_4 = 'b001;
        else   huf_code_4 = 3'b101;
      end
      else if (m_node_3_num[3:0]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_4 = 'b011;
        else   huf_code_4 = 'b111;
      end
      else begin // 1+7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_4 = 'b01;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_4 = 'b11;
        end
      end
    end
  //begin at node 8  
    else if(m_node_3_num[7:4]==4)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_4 = 0;//00
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_4 = 'b10;
      end
    end
    else if(m_node_3_num[3:0]==4)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_4 = 'b01;
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_4 = 'b11;
      end
    end
  //begin at node 9  
    else if(m_node_4_num[7:4]==4) huf_code_4 = 0;
    else if(m_node_4_num[3:0]==4) huf_code_4 = 1'b1;   
    else     huf_code_4 = 0;
  end
// number 5
  always @(*) begin
  //begin at node 6
    if(m_node_1_num[7:4]==5)begin //1-6
      if(m_node_2_num[7:4]==6)begin //1-6-7
        if(m_node_3_num[7:4]==7)begin //1-6-7-8
          if(m_node_4_num[7:4]==8)begin //1-6-7-8-9
            huf_code_5 = 'b0000;
          end
          else begin //1-6-7-8+9
            huf_code_5 = 'b1000;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6-7+8
          if(m_node_4_num[7:4]==8)begin //1-6-7+8-9
            huf_code_5 = 'b0100;
          end
          else begin //1-6-7+8+9
            huf_code_5 = 'b1100;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6-7-9
          huf_code_5 = 'b000;
        end
        else begin //m_node_4_num[3:0]==7 //1-6-7+9
          huf_code_5 = 'b100;
        end
      end
      else if(m_node_2_num[3:0]==6)begin//1-6+7-
        if(m_node_3_num[7:4]==7)begin //1-6+7-8
          if(m_node_4_num[7:4]==8)begin //1-6+7-8-9
            huf_code_5 = 'b0010;
          end
          else begin //1-6+7-8+9
            huf_code_5 = 'b1010;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1-6+7+8
          if(m_node_4_num[7:4]==8)begin //1-6+7+8-9
            huf_code_5 = 'b0110;
          end
          else begin //1-6+7+8+9
            huf_code_5 = 'b1110;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1-6+7-9
          huf_code_5 = 'b010;
        end
        else begin //m_node_4_num[3:0]==7 //1-6+7+9
          huf_code_5 = 'b110;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1-6-8
        if(m_node_4_num[7:4]==8)begin//1-6-8-9
          huf_code_5 = 'b000;
        end
        else begin //1-6-8+9
          huf_code_5 = 'b100;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1-6+8
        if(m_node_4_num[7:4]==8)begin//1-6+8-9
          huf_code_5 = 'b010;
        end
        else begin //1-6+8+9
          huf_code_5 = 'b110;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1-6-9
        huf_code_5 = 'b00;
      end
      else begin //1-6+9
        huf_code_5 = 'b10;
      end
    end 
    else if(m_node_1_num[3:0]==5)begin //1+6 
      if(m_node_2_num[7:4]==6)begin //1+6-7
        if(m_node_3_num[7:4]==7)begin //1+6-7-8
          if(m_node_4_num[7:4]==8)begin //1+6-7-8-9
            huf_code_5 = 'b0001;
          end
          else begin //1+6-7-8+9
            huf_code_5 = 'b1001;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6-7+8
          if(m_node_4_num[7:4]==8)begin //1+6-7+8-9
            huf_code_5 = 'b0101;
          end
          else begin //1+6-7+8+9
            huf_code_5 = 'b1101;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6-7-9
          huf_code_5 = 'b001;
        end
        else begin //m_node_4_num[3:0]==7 //1+6-7+9
          huf_code_5 = 'b101;
        end
      end
      else if(m_node_2_num[3:0]==6)begin //1+6+7-
        if(m_node_3_num[7:4]==7)begin //1+6+7-8
          if(m_node_4_num[7:4]==8)begin //1+6+7-8-9
            huf_code_5 = 'b0011;
          end
          else begin //1+6+7-8+9
            huf_code_5 = 'b1011;
          end
        end
        else if(m_node_3_num[3:0]==7)begin //1+6+7+8
          if(m_node_4_num[7:4]==8)begin //1+6+7+8-9
            huf_code_5 = 'b0111;
          end
          else begin //1+6+7+8+9
            huf_code_5 = 'b1111;
          end
        end 
        else if(m_node_4_num[7:4]==7)begin//1+6+7-9
          huf_code_5 = 'b011;
        end
        else begin //m_node_4_num[3:0]==7 //1+6+7+9
          huf_code_5 = 'b111;
        end
      end
      else if(m_node_3_num[7:4]==6)begin//1+6-8
        if(m_node_4_num[7:4]==8)begin//1+6-8-9
          huf_code_5 = 'b001;
        end
        else begin //1+6-8+9
          huf_code_5 = 'b101;
        end
      end
      else if(m_node_3_num[3:0]==6)begin//1+6+8
        if(m_node_4_num[7:4]==8)begin//1+6+8-9
          huf_code_5 = 'b011;
        end
        else begin //1+6+8+9
          huf_code_5 = 'b111;
        end
      end
      else if(m_node_4_num[7:4]==6)begin//1+6-9
        huf_code_5 = 'b01;
      end
      else begin //1+6+9
        huf_code_5 = 'b11;
      end
    end   
  //begin at node 7  
    else if(m_node_2_num[7:4]==5)begin //1-7-
      if(m_node_3_num[7:4]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_5 = 'b000;
        else   huf_code_5 = 'b100;
      end
      else if (m_node_3_num[3:0]==7)begin //1-7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_5 = 'b010;
        else   huf_code_5 = 'b110;
      end
      else begin // 1-7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_5 = 'b00;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_5 = 'b10;
        end
      end
    end
    else if(m_node_2_num[3:0]==5)begin //1+7-
      if(m_node_3_num[7:4]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_5 = 'b001;
        else   huf_code_5 = 3'b101;
      end
      else if (m_node_3_num[3:0]==7)begin //1+7-8-9
        if (m_node_4_num[7:4]==8)  huf_code_5 = 'b011;
        else   huf_code_5 = 'b111;
      end
      else begin // 1+7-9
        if(m_node_4_num[7:4]==7) begin
          huf_code_5 = 'b01;
        end
        else begin // m_node_4_num[3:0]==7
          huf_code_5 = 'b11;
        end
      end
    end
  //begin at node 8  
    else if(m_node_3_num[7:4]==5)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_5 = 0;//00
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_5 = 'b10;
      end
    end
    else if(m_node_3_num[3:0]==5)begin
      if(m_node_4_num[7:4]==8)begin
        huf_code_5 = 'b01;
      end
      else begin //m_node_4_num[3:0]==8
        huf_code_5 = 'b11;
      end
    end
  //begin at node 9  
    else if(m_node_4_num[7:4]==5) huf_code_5 = 0;
    else if(m_node_4_num[3:0]==5) huf_code_5 = 1'b1;   
    else     huf_code_5 = 0;
  end
//------------OUTPUT-----------------
always @(*) begin
    out_encoded = {huf_code_1,huf_code_2,huf_code_3,huf_code_4,huf_code_5};
end
endmodule