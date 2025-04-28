`timescale 1ns/10ps

// --------------------------------------------------------------------------
// Conway's Game of Life Testbench
// --------------------------------------------------------------------------

parameter ID = 123456789 + 123456789; // Your ID here

// --------------------------------------------------------------------------
// Driver Class
// --------------------------------------------------------------------------

class driver #(
  parameter N = 3,
  parameter M = 256
);
  virtual _if #(N, M).TB vif;
  logic clk;

  function new(virtual _if #(N, M).TB _vif);
    this.vif = _vif;
  endfunction

  task reset(logic clk_ref);
    this.clk = clk_ref;
    $display("Resetting the design...");
    vif.row_idx = 0;
    vif.col_idx = 0;
    vif.din     = 0;
    vif.din_wr  = 0;
    vif.din_rd  = 0;
    vif.gstep   = 0;
  endtask

  task wait_done();
    begin
      @(negedge clk);
      repeat (1000) begin
        if (vif.done)
          return;
        @(negedge clk);
      end
      $fatal("ERROR: Timeout waiting for done signal."); // cleaner than $finish
    end
  endtask

  task write_cell(input [7:0] row, input [7:0] col, input bit val);
    vif.row_idx = row;
    vif.col_idx = col;
    vif.din     = val;
    vif.din_wr  = 1;
    vif.gstep   = 0;
    @(negedge clk);
    vif.din_wr  = 0;
  endtask

  task read_cell(input [7:0] row, input [7:0] col, output bit val);
    vif.row_idx = row;
    vif.col_idx = col;
    vif.din_rd  = 1;
    @(negedge clk);
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
    int row = 0;
    int col;
    string cmd;

    $display("Generating pattern using Python...");
    cmd = $sformatf("python3 ../src/scripts/cgol_gen_and_check.py %0d %0d %0d %0d", N, M, ID, 0);
    void'($system(cmd));

    $display("Loading pattern from pattern.txt...");
    file = $fopen("pattern.txt", "r");
    if (file == 0) $fatal("ERROR: Could not open pattern.txt");

    while (!$feof(file) && row < N) begin
      line = "";
      void'($fgets(line, file));
      if (line.len() < M) $fatal("ERROR: Line %0d too short (len=%0d, expected %0d)", row, line.len(), M);

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
    $display("Starting simulation...");
  endtask

  task export_and_check(input integer generation_count);
    int file;
    reg cell_val;
    string cmd;
    int result;
    string line;

    file = $fopen("exported_pattern.txt", "w");
    if (file == 0) $fatal("ERROR: Could not open exported_pattern.txt for writing");

    for (int row = 0; row < N; row++) begin
      for (int col = 0; col < M; col++) begin
        read_cell(row, col, cell_val);
        $fwrite(file, "%0d ", cell_val);
      end
      $fwrite(file, "\n");
    end

    $fclose(file);

    cmd = $sformatf("python3 ../src/scripts/cgol_gen_and_check.py --check %0d %0d %0d %0d", N, M, ID, generation_count);
    result = $system(cmd);
    if (result != 0) $display("Python check script reported an error.");

    file = $fopen("check_result.txt", "r");
    if (file == 0) $fatal("ERROR: Could not open check_result.txt");

    line = "";
    void'($fgets(line, file));
    if (line == "1") $display("Generation %0d: Pattern is correct.", generation_count);
    else if (line == "0") $fatal("Generation %0d: Pattern is incorrect.", generation_count);

    $fclose(file);
  endtask
endclass

// --------------------------------------------------------------------------
// Top-Level Testbench
// --------------------------------------------------------------------------

module cgol_tb;

  parameter N = (ID % 9) + 24;
  parameter M = ((ID / 4) % 9) + 24;

  logic clk;
  logic rst_n;
  logic done;
  integer generation_count = 0;

  _if #(N, M) cgol_if();
  driver #(N, M) d0;

  assign cgol_if.done = done;

  initial begin
    clk = 1;
    rst_n = 0;
    repeat (10) @(negedge clk); // Hold reset low for 10 clock cycles
    rst_n = 1;
    @(negedge clk); // Stabilize after reset release

    $display("Conway's Game of Life Testbench");

    d0 = new(cgol_if);
    d0.reset(clk);

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

    $finish;
  end

  always #5 clk = ~clk;

  // DUT instantiation
  cgol #(
    .N(N),
    .M(M)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .cgol_port(cgol_if)
  );

endmodule
