`timescale 1ns/10ps

// --------------------------------------------------------------------------
// Conway's Game of Life Testbench
// --------------------------------------------------------------------------

parameter ID = 123456789 + 123456789; // Your ID here

// --------------------------------------------------------------------------
// _tb_if Interface (clock + reset)
// --------------------------------------------------------------------------

interface _tb_if #(parameter N = 3, parameter M = 256) ();
  logic clk;
  logic rst_n;

  modport TB     ( output clk, rst_n );
  modport DRIVER ( input  clk, rst_n );
  modport DUT    ( input  clk, rst_n );
endinterface

// --------------------------------------------------------------------------
// Driver Class
// --------------------------------------------------------------------------

class driver #(
  parameter N = 3,
  parameter M = 256
);
  // Virtual interface handles
  virtual _if     #(N, M).TB     vif;  // functional bus
  virtual _tb_if  #(N, M).DRIVER dut;  // clock/reset

  function new(virtual _if     #(N, M).TB     _vif,
               virtual _tb_if  #(N, M).DRIVER _dut);
    this.vif = _vif;
    this.dut = _dut;
  endfunction

  task reset();
    // Assert reset for 10 cycles
    dut.rst_n = 0;
    repeat (10) @(negedge dut.clk);
    dut.rst_n = 1;
    $display("Reset done.");
    // Clear all functional inputs
    vif.row_idx = 0;
    vif.col_idx = 0;
    vif.din     = 0;
    vif.din_wr  = 0;
    vif.din_rd  = 0;
    vif.gstep   = 0;
  endtask

  task wait_done();
    @(negedge dut.clk);
    repeat (1000) begin
      if (vif.done) return;
      @(negedge dut.clk);
    end
    $fatal("ERROR: Timeout waiting for done.");
  endtask

  task write_cell(input [7:0] row, input [7:0] col, input bit val);
    vif.row_idx = row;
    vif.col_idx = col;
    vif.din     = val;
    vif.din_wr  = 1;
    vif.gstep   = 0;
    @(negedge dut.clk);
    vif.din_wr  = 0;
  endtask

  task read_cell(input [7:0] row, input [7:0] col, output bit val);
    vif.row_idx = row;
    vif.col_idx = col;
    vif.din_rd  = 1;
    @(negedge dut.clk);
    val = vif.dout;
    vif.din_rd  = 0;
  endtask

  task generation_step();
    vif.gstep = 1;
    wait_done();
    vif.gstep = 0;
  endtask

  task load_pattern();
    int file;
    string line;
    byte c;
    int row = 0, col;
    string cmd;
    $display("Generating pattern using Python...");
    cmd = $sformatf("python3 ../src/scripts/cgol_gen_and_check.py %0d %0d %0d 0", N, M, ID);
    void'($system(cmd));

    $display("Loading pattern from pattern.txt...");
    file = $fopen("pattern.txt", "r");
    if (!file) $fatal("Cannot open pattern.txt");

    while (!$feof(file) && row < N) begin
      void'($fgets(line, file));
      for (col = 0; col < M; col++) begin
        c = line[col];
        if (c == "0" || c == "1")
          write_cell(row, col, c == "1");
      end
      row++;
    end
    $fclose(file);
    $display("Pattern loaded.");
  endtask

  task export_and_check(input integer gen);
    int   file;
    bit   cell_val;
    string cmd, line;
    int   result;
    file = $fopen("exported_pattern.txt", "w");
    if (!file) $fatal("Cannot open exported_pattern.txt");

    for (int r = 0; r < N; r++) begin
      for (int c = 0; c < M; c++) begin
        read_cell(r, c, cell_val);
        $fwrite(file, "%0d ", cell_val);
      end
      $fwrite(file, "\n");
    end
    $fclose(file);

    cmd    = $sformatf("python3 ../src/scripts/cgol_gen_and_check.py --check %0d %0d %0d %0d",
                       N, M, ID, gen);
    result = $system(cmd);
    if (result != 0) $display("Python check reported error.");

    file = $fopen("check_result.txt", "r");
    if (!file) $fatal("Cannot open check_result.txt");
    void'($fgets(line, file));
    if (line == "0")
      $fatal("Generation %0d incorrect!", gen);
    else
      $display("Generation %0d correct.", gen);
    $fclose(file);
  endtask

endclass

// --------------------------------------------------------------------------
// Top-Level Testbench
// --------------------------------------------------------------------------

module cgol_tb;
  parameter N = (ID % 9) + 24;
  parameter M = ((ID / 4) % 9) + 24;

  // Interface instances
  _if     #(N, M) cgol_if();
  _tb_if  #(N, M) cgol_if_sys();

  // Driver
  driver #(N, M) d0 = new(cgol_if, cgol_if_sys);

  integer generation_count = 0;

  initial begin
    // Drive sys interface signals
    cgol_if_sys.clk   = 1;
    cgol_if_sys.rst_n = 0;
    repeat (10) @(negedge cgol_if_sys.clk);
    cgol_if_sys.rst_n = 1;
    @(negedge cgol_if_sys.clk);

    $display("Conway's Game of Life Testbench");

    d0.reset();
    d0.load_pattern();

    for (int i = 0; i < 50; i++) begin
      d0.generation_step();
      generation_count++;
      d0.export_and_check(generation_count);
    end

    $display("\n\n\n--------------------------------");
    $display("Simulation finished successfully.");
    $display("All tests passed.");
    $display("Want to see the result? run:");
    $display("python3 ../src/scripts/animate_life.py --dir=./generations --delay=0.1");
    $display("--------------------------------\n\n\n");

    $finish

  end

  // Clock generator
  always #5 cgol_if_sys.clk = ~cgol_if_sys.clk;

  // DUT instantiation
  cgol #(.N(N), .M(M)) dut (
    .clk(cgol_if_sys.clk),
    .rst_n(cgol_if_sys.rst_n),
    .cgol_port(cgol_if)
  );
endmodule
