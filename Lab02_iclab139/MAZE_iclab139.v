module MAZE(
    // input
    input clk,
    input rst_n,
	input in_valid,
	input [1:0] in,

    // output
    output reg out_valid,
    output reg [1:0] out
);
// --------------------------------------------------------------
// Reg & Wire
// --------------------------------------------------------------
reg [1:0] in_d;
// reg in_valid_d;

reg [4:0] cur_X,cur_Y;
reg [4:0] last_X,last_Y;
reg flag_sword;
reg [1:0] last_move; //means direction of last movement

reg [1:0] c_s, n_s;
// reg [1:0] c_s_d;
 
// reg [1:0] Map [0:18] [0:18];
reg [1:0] Map [1:17] [1:17];

integer i,j,k;

// state
parameter S_IDLE    = 3'd0;
parameter S_LOAD  = 3'd1; //get the MAP
parameter S_WALK    = 3'd2; //start walk

// -----------FSM---------
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
                    n_s = S_WALK;
                else
                    n_s = S_LOAD;
            end    
          S_WALK:
            begin
                if(cur_X==17 && cur_Y==17)
                    n_s = S_IDLE;
                else
                    n_s = S_WALK;
            end    
                                               
          default:
              n_s = S_IDLE;
      endcase
end
// -----------FSM---------
// --------input delay----------
// to avoid 03 failed
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      in_d <= 0;
      // in_valid_d <= 0;
      // c_s_d <= 0;     
    end
    else begin
      in_d <= in;
      // in_valid_d <= in_valid;
      // c_s_d <= c_s;
    end
end

// --------------------------------------------------------------
// Design
// --------------------------------------------------------------
// player location
always@(posedge clk or negedge rst_n)begin
  if(!rst_n) begin
    cur_X <= 1;
    cur_Y <= 1;
    last_move <= 0;
    flag_sword <= 0;
  end
  else if(c_s==S_LOAD && in_valid==0 && Map[1][2]==2) flag_sword <= 1;
  else if(cur_X==17 && cur_Y==17)begin
    cur_X <= 1;
    cur_Y <= 1;
    flag_sword <= 0;
    last_move <= 0;
  end
  else if(c_s==S_WALK)begin
    case(last_move)
      0:begin //right
       // down-------------------------------------------
        if(Map[cur_Y+1][cur_X]==0 && (cur_Y<17))begin
          cur_Y <= cur_Y+1;
          cur_X <= cur_X;
          last_move <= 1;
        end
        else if(Map[cur_Y+1][cur_X]==2 && (cur_Y<17))begin
          flag_sword <= 1;
          cur_Y <= cur_Y+1;
          cur_X <= cur_X; 
          last_move <= 1;         
        end
        else if(Map[cur_Y+1][cur_X]==3 && flag_sword && (cur_Y<17))begin
          cur_Y <= cur_Y+1;
          cur_X <= cur_X;          
          last_move <= 1; 
        end
       //right-------------------------------------------
        else if(Map[cur_Y][cur_X+1]==0 && (cur_X<17))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0; 
        end
        else if(Map[cur_Y][cur_X+1]==2 && (cur_X<17))begin
          flag_sword <= 1;            
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0;
        end    
        else if(Map[cur_Y][cur_X+1]==3 && flag_sword && (cur_X<17))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0;
        end    
       //up------------------------------------------------
        else if(Map[cur_Y-1][cur_X]==0 && (cur_Y>1))begin
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;
          last_move <= 3;
        end
        else if(Map[cur_Y-1][cur_X]==2 && (cur_Y>1))begin
          flag_sword <= 1;
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;  
          last_move <= 3;
        end   
        else if(Map[cur_Y-1][cur_X]==3 && flag_sword && (cur_Y>1))begin
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;
          last_move <= 3;
        end                 
       //left(back)------------------------------------------
        else begin
          cur_X <= cur_X-1;
          cur_Y <= cur_Y;
          last_move <= 2;
        end
      end
      1:begin
       // left--------------------------------------------
        if(Map[cur_Y][cur_X-1]==0 && (cur_X>1))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;
          last_move <= 2;
        end
        else if(Map[cur_Y][cur_X-1]==2 && (cur_X>1))begin
          flag_sword <= 1;
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;  
          last_move <= 2;
        end   
        else if(Map[cur_Y][cur_X-1]==3 && flag_sword && (cur_X>1))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;
          last_move <= 2;
        end         
       // down-------------------------------------------
        else if(Map[cur_Y+1][cur_X]==0 && (cur_Y<17))begin
          cur_Y <= cur_Y+1;
          cur_X <= cur_X;
          last_move <= 1;
        end
        else if(Map[cur_Y+1][cur_X]==2 && (cur_Y<17))begin
          flag_sword <= 1;
          cur_Y <= cur_Y+1;
          cur_X <= cur_X; 
          last_move <= 1;         
        end
        else if(Map[cur_Y+1][cur_X]==3 && flag_sword && (cur_Y<17))begin
          cur_Y <= cur_Y+1;
          cur_X <= cur_X;          
          last_move <= 1; 
        end
       //right-------------------------------------------
        else if(Map[cur_Y][cur_X+1]==0 && (cur_X<17))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0; 
        end
        else if(Map[cur_Y][cur_X+1]==2 && (cur_X<17))begin
          flag_sword <= 1;            
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0;
        end    
        else if(Map[cur_Y][cur_X+1]==3 && flag_sword && (cur_X<17))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0;
        end            
       //up(back)--------------------------------------------
        else begin
          cur_X <= cur_X;
          cur_Y <= cur_Y-1;
          last_move <= 3;
        end      
      end
      2:begin //last move is Left
       //up------------------------------------------------
        if(Map[cur_Y-1][cur_X]==0 && (cur_Y>1))begin
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;
          last_move <= 3;
        end
        else if(Map[cur_Y-1][cur_X]==2 && (cur_Y>1))begin
          flag_sword <= 1;
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;  
          last_move <= 3;
        end   
        else if(Map[cur_Y-1][cur_X]==3 && flag_sword && (cur_Y>1))begin
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;
          last_move <= 3;
        end
       // left-------------------------------------------
        else if(Map[cur_Y][cur_X-1]==0 && (cur_X>1))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;
          last_move <= 2; 
        end
        else if(Map[cur_Y][cur_X-1]==2 && (cur_X>1))begin
          flag_sword <= 1;            
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;
          last_move <= 2;
        end    
        else if(Map[cur_Y][cur_X-1]==3 && flag_sword && (cur_X>1))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;
          last_move <= 2;
        end    
       // down-------------------------------------------
        else if(Map[cur_Y+1][cur_X]==0 && (cur_Y<17))begin
          cur_Y <= cur_Y+1;
          cur_X <= cur_X;
          last_move <= 1;
        end
        else if(Map[cur_Y+1][cur_X]==2 && (cur_Y<17))begin
          flag_sword <= 1;
          cur_Y <= cur_Y+1;
          cur_X <= cur_X; 
          last_move <= 1;         
        end
        else if(Map[cur_Y+1][cur_X]==3 && flag_sword && (cur_Y<17))begin
          cur_Y <= cur_Y+1;
          cur_X <= cur_X;          
          last_move <= 1; 
        end
       // right(back)------------------------------------------
        else begin
          cur_X <= cur_X+1;
          cur_Y <= cur_Y;
          last_move <= 0;
        end      
      end
      3:begin // last move is up
       //right-------------------------------------------
        if(Map[cur_Y][cur_X+1]==0 && (cur_X<17))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0; 
        end
        else if(Map[cur_Y][cur_X+1]==2 && (cur_X<17))begin
          flag_sword <= 1;            
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0;
        end    
        else if(Map[cur_Y][cur_X+1]==3 && flag_sword && (cur_X<17))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X+1;
          last_move <= 0;
        end    
       //up------------------------------------------------
        else if(Map[cur_Y-1][cur_X]==0 && (cur_Y>1))begin
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;
          last_move <= 3;
        end
        else if(Map[cur_Y-1][cur_X]==2 && (cur_Y>1))begin
          flag_sword <= 1;
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;  
          last_move <= 3;
        end   
        else if(Map[cur_Y-1][cur_X]==3 && flag_sword && (cur_Y>1))begin
          cur_Y <= cur_Y-1;
          cur_X <= cur_X;
          last_move <= 3;
        end           
       // left-------------------------------------------
        else if(Map[cur_Y][cur_X-1]==0 && (cur_X>1))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;
          last_move <= 2;
        end
        else if(Map[cur_Y][cur_X-1]==2 && (cur_X>1))begin
          flag_sword <= 1;
          cur_Y <= cur_Y;
          cur_X <= cur_X-1; 
          last_move <= 2;         
        end
        else if(Map[cur_Y][cur_X-1]==3 && flag_sword && (cur_X>1))begin
          cur_Y <= cur_Y;
          cur_X <= cur_X-1;          
          last_move <= 2; 
        end              
       //down(back)------------------------------------------
        else begin
          cur_X <= cur_X;
          cur_Y <= cur_Y+1;
          last_move <= 1;
        end      
      end
    //   default:
    endcase
  end
  // else if(c_s==S_IDLE)begin
  //   cur_X <= 1;
  //   cur_Y <= 1;
  //   flag_sword <= 0;
  //   last_move <= 0;
  // end
  else begin
    cur_X <= cur_X;
    cur_Y <= cur_Y;
    flag_sword <= flag_sword;
    last_move <= last_move;
  end
end


//---------MAP---------------------------------
always@(posedge clk or negedge rst_n)begin
  if(~rst_n)begin
    for ( i=1 ; i<18; i=i+1 ) begin
      for ( j=1 ; j<18; j=j+1 ) begin
        Map[i][j] <= 0;
      end    
    end
  end  
  else if(c_s == S_LOAD)begin
    Map[17][17] <= in_d;
    for ( i=1 ; i<18; i=i+1 ) begin
      for ( j=1 ; j<17; j=j+1 ) begin
        Map[i][j] <= Map[i][j+1];
      end    
    end 
    for ( k=1 ; k<17; k=k+1 ) begin
      Map[k][17] <= Map[k+1][1];
    end  
  end
// option delet road
//---------------------------------------------------------------------------------------------------------------  
  else if(c_s==S_WALK)begin
    if     (Map[cur_Y-1][cur_X]==1 && Map[cur_Y][cur_X+1]==1 && Map[cur_Y+1][cur_X]==1) Map[cur_Y][cur_X] <= 1;
    else if(Map[cur_Y][cur_X+1]==1 && Map[cur_Y+1][cur_X]==1 && Map[cur_Y][cur_X-1]==1) Map[cur_Y][cur_X] <= 1;
    else if(Map[cur_Y-1][cur_X]==1 && Map[cur_Y][cur_X+1]==1 && Map[cur_Y][cur_X-1]==1) Map[cur_Y][cur_X] <= 1;
    else if(Map[cur_Y-1][cur_X]==1 && Map[cur_Y+1][cur_X]==1 && Map[cur_Y][cur_X-1]==1) Map[cur_Y][cur_X] <= 1;
    else Map[cur_Y][cur_X] <= Map[cur_Y][cur_X];
  end
//---------------------------------------------------------------------------------------------------------------  


  else begin
    for ( i=1 ; i<18; i=i+1 ) begin
      for ( j=1 ; j<18; j=j+1 ) begin
        Map[i][j] <= Map[i][j];
      end    
    end
  end
end


// --------output-------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)           out_valid <= 0;
    // else if(cur_X==17 && cur_Y==17) out_valid <= 0;
    else if(n_s==S_IDLE) out_valid <= 0;
    else if(c_s==S_WALK) out_valid <= 1;
    else                  out_valid <= 0;
end

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n)           out <= 0;
//     // else if(cur_X==17 && cur_Y==17) out <= 0;
//     else if(n_s==S_IDLE) out <= 0;
//     else if(c_s==S_WALK) out <= last_move;
//     else                  out <= 0;
// end
always @(*) begin
  out = last_move;
end


endmodule