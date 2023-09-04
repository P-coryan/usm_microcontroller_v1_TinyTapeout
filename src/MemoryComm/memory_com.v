`timescale 1ns / 1ps

module memory_com (
    input wire clk,reset,
    
    // UART Communication
    input wire rx,
    output wire tx,

    // CPU Control
    input  wire write_enable,
    input  wire read_enable,
    output reg  mem_done,

    // CPU Data
    input  wire [31:0] writeData,
    output reg  [31:0] readData,
    input  wire [31:0] address,
    input  wire [2:0]  SizeLoad,
    input  wire [1:0]  MemWrite
);

// FSM States
localparam  IDLE = 4'b0000,
            SEND_ADDRESS = 4'b0001,
            SEND_SIZELOAD = 4'b0010,
            WAIT_RECV_DATA = 4'b0011,
            RECV_DATA = 4'b0100,
            SEND_MEMWRITE = 4'b0101,
            SEND_DATA = 4'b0110,
            DONE = 4'b0111,
            WAIT_ADDRESS = 4'b1000,
            WAIT_SIZELOAD = 4'b1001,
            WAIT_MEMWRITE = 4'b1010,
            WAIT_DATA = 4'b1011;

reg [3:0] state , next_state ;  

always @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

// UART Instances
reg [31:0] recv_data;
reg        recv_ready;
reg        send_start;
reg [31:0] send_data;
reg        send_ready;

word_32_bit_uart_rx uart_rx (
    .clk      ( clk ),
    .reset    ( reset ),
    .rx       ( rx ),
    .instr    ( recv_data ),
    .word_end ( recv_ready )
);

word_32bit_uart_tx uart_tx(
    .clk        ( clk ),
    .reset      ( reset ),
    .addr_query ( send_start ),
    .addr       ( send_data),
    .tx         (tx),
    .word_send  (send_ready)
    );


reg [31:0] readData_prev;
always @(posedge clk) begin
    if(reset) begin
        readData_prev <= 'b0;
    end
    else begin
        readData_prev <= readData;
    end
end

always @(*) begin
    next_state = IDLE;
    
    send_start = 0;
    send_data = 0;

    mem_done = 0;

    readData = readData_prev;

    case(state)
        IDLE: begin
            readData = 0;
            if( write_enable || read_enable ) next_state = SEND_ADDRESS;
            else next_state = IDLE;
        end

        SEND_ADDRESS: begin
            send_start = 1;
            send_data = address;
            if( send_ready && write_enable ) next_state = SEND_MEMWRITE;
            else if ( send_ready && read_enable ) next_state = SEND_SIZELOAD;
            else next_state = SEND_ADDRESS;
        end
        SEND_SIZELOAD: begin
            send_start = 1;
            send_data = {29'b0, SizeLoad};
            if( send_ready ) next_state = WAIT_RECV_DATA;
            else next_state = SEND_SIZELOAD;
        end
        WAIT_RECV_DATA: begin
            if( recv_ready ) next_state = RECV_DATA;
            else next_state = WAIT_RECV_DATA;
        end
        RECV_DATA: begin
            readData = recv_data;
            next_state = DONE;
        end
        SEND_MEMWRITE: begin
            send_start = 1;
            send_data = {30'b0, MemWrite};
            if( send_ready ) next_state = SEND_DATA;
            else next_state = SEND_MEMWRITE;
        end
        SEND_DATA: begin
            send_start = 1;
            send_data = writeData;
            if( send_ready ) next_state = DONE;
            else next_state = SEND_DATA;
        end
        DONE: begin
            mem_done = 1;
            next_state = IDLE;
        end
    endcase
end

endmodule : memory_com

/*

Write: 
    
if(write_enable) enviar esto:
    address
    writeData
    MemWrite

Read:

if(read_enable) enviar:
    address
    SizeLoad
y recibir:
    readData

*/