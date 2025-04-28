`timescale 1ns/10ps

interface _if #(
  parameter N = 3,
  parameter M = 256
)();

  // Functional signals only — NO clock or reset inside
  logic [7:0] row_idx;
  logic [7:0] col_idx;
  logic din;
  logic din_wr;
  logic din_rd;
  logic gstep;
  logic dout;
  logic done;

  // Modports
  modport DUT (
    input  row_idx, col_idx, din, din_wr, din_rd, gstep,
    output dout, done
  );

  modport TB (
    output row_idx, col_idx, din, din_wr, din_rd, gstep,
    input  dout, done
  );

endinterface
