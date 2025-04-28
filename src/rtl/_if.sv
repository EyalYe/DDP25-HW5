`timescale 1ns/10ps

interface _if #(parameter N = 3, parameter M = 256) ();
  // system signals
  logic clk;
  logic rst_n;

  // functional Game-of-Life bus
  logic [7:0] row_idx, col_idx;
  logic       din, din_wr, din_rd, gstep;
  logic       dout, done;

  // modports
  modport DUT (
    input  clk, rst_n,
    input  row_idx, col_idx, din, din_wr, din_rd, gstep,
    output dout, done
  );
  modport TB (
    output clk, rst_n,
    output row_idx, col_idx, din, din_wr, din_rd, gstep,
    input  dout, done
  );
endinterface
