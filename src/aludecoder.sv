`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2022 14:35:21
// Design Name: 
// Module Name: aludecoder
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


module aludecoder(
    //Inputs
    input logic Branch,
    input logic ALUAdd, ALUOp,
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    //Outputs
    output logic [3:0] ALUControl
    );
    
    always_comb begin
         
        if(ALUAdd) begin                                    //if a sum is required
            ALUControl = 4'b0000;
        end
        
        else begin
        
            if(Branch) begin                                //substraction for branch flags
                ALUControl = 4'b0001;
            end
            
            else begin
                if(funct7 == 7'b0000000 || ALUOp) begin           //in the case of arithmetic or Imm arithmetic operation
                    case(funct3)
                        3'b000: ALUControl = 4'b0000;
                        3'b001: ALUControl = 4'b1000;
                        3'b010: ALUControl = 4'b0101;
                        3'b011: ALUControl = 4'b0111;
                        3'b100: ALUControl = 4'b0100;
                        3'b101: ALUControl = 4'b1001;
                        3'b110: ALUControl = 4'b0011;
                        3'b111: ALUControl = 4'b0010; 
                    endcase
                end
                else begin
                    case(funct3)
                        3'b000: ALUControl = 4'b0001;
                        3'b101: ALUControl = 4'b1011;
                        default: ALUControl = 4'b0000;
                    endcase
                end
            end
        end
    end
    
endmodule
