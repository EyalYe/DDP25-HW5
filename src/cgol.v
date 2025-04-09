`timescale 1ns / 10ps

module des #(
    // Grid size (N x M)
    parameter N = 32,             // Num rows
    parameter M = 32            // Num Columns
    )(
    input  clk,                   // Clock signal
    input  rst_n,                 // Reset signal
    input  [7:0] row_idx,         // row index of data in/out 
    input  [7:0] col_idx,         // column index of data in/out     
    input  din,                   // initial 'pixel' on/off value
    input  din_wr,                // write grid pixel on/off data
    input  din_rd,                // read grid pixel on/off data 
    input  gstep,                 // perform a 'generation' step (override din_wr in case simultaneous)
    output reg dout             // current grid read 'pixel' on/of value 9should be provide a cycle after fin_rd.
    );

    // Your code here
    // Maximum M is 32
    // Maximum N is 32
    // Note that data needs to be ready on the next clock cycle
    
endmodule
