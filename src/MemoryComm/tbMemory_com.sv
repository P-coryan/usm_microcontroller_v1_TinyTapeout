`timescale 1ns / 1ps

module tbMemory_com ();

logic clk,reset;
    
// UART Communication
logic rx;
logic tx;

// CPU Control
logic write_enable;
logic read_enable;
logic mem_done;

// CPU Data
logic [31:0] writeData;
logic [31:0] readData;
logic [31:0] address;
logic [2:0]  SizeLoad;
logic [1:0]  MemWrite;

memory_com memcom (
    .clk (clk),
    .reset (reset),
    .rx (rx),
    .tx (tx),
    .write_enable (write_enable),
    .read_enable (read_enable),
    .mem_done (mem_done),
    .writeData (writeData),
    .readData (readData),
    .address (address),
    .SizeLoad (SizeLoad),
    .MemWrite (MemWrite)
);

assign writeData = 32'b01;
assign address = 32'b11;
assign SizeLoad = 3'b100;
assign MemWrite = 2'b10;

// Clock.
always begin
    clk = 1'b1; 
    #10;
    clk = 1'b0;
    #10;
end

initial begin
    // Initial Values.
    rx = 1'b1;
    write_enable = 1'b0;
    read_enable = 1'b0;

    // Reset.
    reset = 1'b1;
    #20;
    reset = 1'b0;
    #20;

    // Write.
    write_enable = 1'b1;

    #30000;
    write_enable = 1'b0;
    #60000;

    // Read.
    read_enable = 1'b1;
    #30000;

    read_enable = 1'b0;
    #60000;

    rx = 1'b0;
    #300;
    rx = 1'b1;
    #3000;

    rx = 1'b0;
    #300;
    rx = 1'b1;
    #3000;

    rx = 1'b0;
    #300;
    rx = 1'b1;
    #3000;

    rx = 1'b0;
    #300;
    rx = 1'b1;
    #3000;

    // Back to Initial Values.
    rx = 1'b1;
    write_enable = 1'b0;
    read_enable = 1'b0;
    $finish;
end

endmodule