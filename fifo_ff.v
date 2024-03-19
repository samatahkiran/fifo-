`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2024 10:51:54
// Design Name: 
// Module Name: fifo_ff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_ff( 
               input wire clk,
               input wire reset_n,
               input wire wr_en,
               
               input wire [DATA_WIDTH-1:0] s_axis_data,
               input wire s_axis_valid,
               output reg s_axis_ready,
               input wire s_axis_last,
               
               input wire rd_en,
               
               output full,
                
               output reg [DATA_WIDTH-1:0] m_axis_data,
               output reg m_axis_valid,
               input wire m_axis_ready,
               output reg m_axis_last,
               
               output empty             
 
            );
            
          parameter DEPTH = 2048;
          parameter DATA_WIDTH = 32;
          
          reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
          
          reg [11:0] wr_ptr;
          reg [11:0] rd_ptr;
          reg [11:0] count;
          reg data_last;
        //  reg last_in_frame;
          
          integer i;
         
          assign full = (count == DEPTH);
          assign empty = (count == 0);
          
          // handle with the write processor 
           
          always@(posedge clk or negedge reset_n) begin
              
               if(!reset_n) begin                          
               
                  wr_ptr <= 0;
               //     last_in_frame <= 0;
                   
                end else begin
                  
                  if(s_axis_valid && m_axis_ready && wr_en && !full) begin
                  
                  fifo_mem[wr_ptr] <= s_axis_data;
                  
                  wr_ptr <= wr_ptr + 1;
                  data_last <= s_axis_last;
                                
                  end
                end
          end
          
          //  handle with the read pointer 
          
           always@(posedge clk or negedge reset_n) begin
              
               if(!reset_n) begin
               
                  rd_ptr <= 0;
                 
                  s_axis_ready <= 1'b0;
                  m_axis_valid <= 1'b0;
                  m_axis_data <=  32'b0;
                  m_axis_last <= 1'b0;  
                //  data_last <= 1'b0;               
                  
                   
                end else begin
                  
                  if(rd_en && (s_axis_valid && m_axis_ready) && ~empty) begin
                  
                  m_axis_data <= fifo_mem[rd_ptr];                  
                                                                 
                  s_axis_ready <= m_axis_ready;
                  m_axis_valid <= s_axis_valid;
                  m_axis_last <= data_last;                  
//                  data_last <= s_axis_last;                  
                  rd_ptr = rd_ptr + 1;
                  
                  
                  end
                end
          end
         // assign m_axis_last = data_last;
          // handle with the count ----
          //assign s_axis_last = (count == count -1)?1:0;
          
          always@(posedge clk or negedge reset_n) begin
             
              if(!reset_n) begin
                 
              count <= 0;
                  
              end else begin            
                             
              if(wr_en && s_axis_valid && m_axis_ready && !full)begin
                count <= count + 1;
              
                end else if(m_axis_ready && rd_en && !empty) begin
                count <= count - 1;
                end
           end
         end             
                                          
                   
endmodule
