`timescale 1ns / 10ps

// --------------------------------------------------------------------------
// Conway's Game of Life Testbench
// --------------------------------------------------------------------------

parameter ID = 123456789 + 123456789; // Your ID here

// --------------------------------------------------------------------------
// Testbench Utility Interface and Driver
// --------------------------------------------------------------------------

interface _if #(
  parameter N = 3,
  parameter M = 256
  )();

  logic clk;
  logic rst_n;

  logic [7:0] row_idx;
  logic [7:0] col_idx;
  logic din;
  logic din_wr;
  logic din_rd;
  logic gstep;
  logic dout;

  modport DUT (
    input clk, rst_n, row_idx, col_idx, din, din_wr, din_rd, gstep,
    output dout
  );

  modport TB (
    output clk, rst_n, row_idx, col_idx, din, din_wr, din_rd, gstep,
    input dout
  );
endinterface


class driver #(
  parameter N = 3,
  parameter M = 256
  );
  virtual _if #(N, M).TB vif;

  function new(virtual _if #(N, M).TB _vif);
    this.vif = _vif;
  endfunction

  task reset();
    vif.rst_n <= 0;
    repeat (2) @(posedge vif.clk);
    vif.rst_n <= 1;
    @(posedge vif.clk);
  endtask

  task write_cell(input [7:0] row, input [7:0] col, input bit val);
    vif.row_idx <= row;
    vif.col_idx <= col;
    vif.din <= val;
    vif.din_wr <= 1;
    vif.gstep <= 0;
    @(negedge vif.clk);
    vif.din_wr <= 0;
  endtask

  task read_cell(input [7:0] row, input [7:0] col, output bit val);
    vif.row_idx <= row;
    vif.col_idx <= col;
    vif.din_rd <= 1;
    @(negedge vif.clk);
    vif.din_rd <= 0;
    val = vif.dout;
  endtask

  task generation_step();
    vif.gstep <= 1;
    @(posedge vif.clk);
    vif.gstep <= 0;
  endtask

  task load_pattern;
    int file;
    string line;
    byte c;
    int row = 0;
    int col;
    string cmd;

    $display("Generating pattern using Python...");
    cmd = $sformatf("python3 ../src/cgol_gen_and_check.py %0d %0d %0d %0d", N, M, ID, 0); // Corrected: N before M
    void'($system(cmd));

    $display("Loading pattern from pattern.txt...");
    file = $fopen("pattern.txt", "r");
    if (file == 0) begin
      $fatal("ERROR: Could not open pattern.txt");
    end

    while (!$feof(file) && row < N) begin
      line = "";
      void'($fgets(line, file));
      if (line.len() < M) begin
        $fatal("ERROR: Line %0d too short (len=%0d, expected %0d)", row, line.len(), M);
      end

      for (col = 0; col < M; col++) begin
        c = line[col];
        if (c == "0" || c == "1") begin
          write_cell(row, col, c == "1");
        end
      end
      row++;
    end

    $fclose(file);
    $display("Pattern loaded.");
  endtask

  task export_and_check(input integer generation_count);
    int file;
    reg cell_val;
    string cmd;
    int result;
    string line;

    file = $fopen("exported_pattern.txt", "w");
    if (file == 0) begin
      $fatal("ERROR: Could not open exported_pattern.txt for writing");
    end

    for (int row = 0; row < N; row++) begin
      for (int col = 0; col < M; col++) begin
        read_cell(row, col, cell_val);
        $fwrite(file, "%0d ", cell_val);
      end
      $fwrite(file, "\n");
    end

    $fclose(file);

    // Call Python to check correctness
    cmd = $sformatf("python3 ../src/cgol_gen_and_check.py --check %0d %0d %0d %0d", N, M, ID, generation_count);
    result = $system(cmd);
    if (result != 0) begin
      $display("Python check script reported an error.");
    end

    file = $fopen("check_result.txt", "r");
    if (file == 0) begin
      $fatal("ERROR: Could not open check_result.txt");
    end

    line = "";
    void'($fgets(line, file));
    if (line == "1") begin
      $display("Generation %0d: Pattern is correct.", generation_count);
    end else if (line == "0") begin
      $fatal("Generation %0d: Pattern is incorrect.", generation_count);
    end 

    $fclose(file);

  endtask
endclass


// --------------------------------------------------------------------------
// Testbench Top Module
// --------------------------------------------------------------------------
module cgol_tb;

  // Parameters that define the size of the grid
  parameter N = (ID % 9) + 24; // 24 to 32
  parameter M = ((ID / 4) % 9) + 24; // 24 to 32

  logic val;
  logic clk;
  logic rst_n;

  integer generation_count = 0;

  driver #(N, M) d0;

  _if #(N, M) cgol_if();

  assign cgol_if.clk = clk;
  assign cgol_if.rst_n = rst_n;

  initial begin
    clk = 0;
    rst_n = 1;
    #10 rst_n = 0;
    #10 rst_n = 1;

    $display("Conway's Game of Life Testbench");

    d0 = new(cgol_if);

    // Load the initial pattern
    d0.load_pattern();

    for (int i = 0; i < 50; i++) begin
      d0.generation_step();
      generation_count++;
      d0.export_and_check(generation_count);
    end

    // Finishing the simulation
    $display("\n\n\n--------------------------------");
    $display("Simulation finished successfully.");
    $display("All tests passed.");
    $display("Don't forget to synthesize your design.");
    $display("Want to see the result? run:");
    $display("python3 ../src/animate_life.py --dir=./generations --delay=0.1");
    $display("--------------------------------\n\n\n");

    $finish;
  end

  always #5 clk = !clk; // Clock period of 10 time units

  des #(
    .N(N),
    .M(M)
  ) dut (
    .clk(cgol_if.clk),
    .rst_n(cgol_if.rst_n),
    .row_idx(cgol_if.row_idx),
    .col_idx(cgol_if.col_idx),
    .din(cgol_if.din),
    .din_wr(cgol_if.din_wr),
    .din_rd(cgol_if.din_rd),
    .gstep(cgol_if.gstep),
    .dout(cgol_if.dout)
  );

endmodule
