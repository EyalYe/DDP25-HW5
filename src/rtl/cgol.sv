`timescale 1ns / 10ps

module cgol #(
    parameter N = 3,
    parameter M = 256
  )(
    input  logic clk,
    input  logic rst_n,
    _if.DUT cgol_port
  );

    // Your code here
    // Maximum M is 32
    // Maximum N is 32
    // Note that data needs to be ready on the next clock cycle
    
endmodule
