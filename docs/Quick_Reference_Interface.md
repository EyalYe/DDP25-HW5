# 📋 Quick Guide: How to Use the `_if` Interface (CGOL Project)

In this project, we use a **SystemVerilog interface** (`_if`) to group related control and data signals for the Conway's Game of Life grid operations.

This guide explains how to properly instantiate, connect, and use the interface both in the testbench and inside the DUT.

---

## 1. Interface Definition (`src/_if.sv`)

```systemverilog
interface _if #(parameter N = 3, parameter M = 256) ();

  logic [7:0] row_idx;
  logic [7:0] col_idx;
  logic din;
  logic din_wr;
  logic din_rd;
  logic gstep;
  logic dout;
  logic done;

  modport DUT (
    input  row_idx, col_idx, din, din_wr, din_rd, gstep,
    output dout, done
  );

  modport TB (
    output row_idx, col_idx, din, din_wr, din_rd, gstep,
    input  dout, done
  );

endinterface
```

---

## 2. Instantiate the Interface in the Testbench (`runspace/cgol_tb.sv`)

```systemverilog
_if #(N, M) cgol_if();
```

You can now drive signals through the interface fields:

```systemverilog
initial begin
  cgol_if.row_idx = 5;
  cgol_if.col_idx = 10;
  cgol_if.din     = 1;
  cgol_if.din_wr  = 1;
  @(negedge clk);
  cgol_if.din_wr  = 0;
end
```

---

## 3. Pass the Interface to the DUT (`src/rtl/cgol.sv`)

Instantiate your `cgol` module like this:

```systemverilog
cgol #(
  .N(N),
  .M(M)
) dut (
  .clk(clk),
  .rst_n(rst_n),
  .cgol_port(cgol_if)
);
```

---

## 4. Access Interface Signals Inside the DUT (`cgol.sv`)

Inside your `cgol` module, you access all signals through the `cgol_port`:

```systemverilog
module cgol #(
  parameter N = 3,
  parameter M = 256
)(
  input logic clk,
  input logic rst_n,
  _if.DUT cgol_port
);

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    // Reset logic
  end else begin
    if (cgol_port.din_wr) begin
      // Handle write
    end
    if (cgol_port.din_rd) begin
      // Handle read
    end
    if (cgol_port.gstep) begin
      // Handle generation step
    end
  end
end

endmodule
```

---

## 🧠 Why Use an Interface?

- **Simplified connections**: Bundle multiple related signals into a single port.
- **Easier maintenance**: Add or modify signals in one place.
- **Cleaner module definitions**: Especially useful for designs with many control signals.
- **Clear separation**: Testbench drives outputs; DUT consumes inputs, thanks to `modport`.
- **Industry standard practice**: Common in complex ASIC/FPGA designs.

---

# ✅ Summary

- **Testbench** drives the interface using `TB` modport.
- **DUT** reads/writes using `DUT` modport.
- **Clock (`clk`) and Reset (`rst_n`) are passed separately**, not bundled inside the interface.

---

