# HW5 – Conway’s Game of Life (CGOL)

## 🧠 Overview

In this assignment, you will implement the **core logic module** for **Conway’s Game of Life** – a classic cellular automaton – in SystemVerilog. You’ll write the logic that simulates each generation of a grid of binary cells based on local neighborhood rules.

The grid is parameterized, and your module must support reading/writing individual cells, as well as advancing the simulation by one generation step.

You will also learn how to use a **SystemVerilog interface** to group control and data signals, and how to test your design using a provided testbench.

---

## 📏 Rules of the Game

Each cell on the grid is either **alive (1)** or **dead (0)**. The state of each cell in the next generation is determined by its **8 immediate neighbors** (horizontally, vertically, and diagonally adjacent). The rules are:

1. **Survival**: A live cell with **2 or 3** live neighbors stays alive.
2. **Death by loneliness**: A live cell with **fewer than 2** live neighbors dies.
3. **Death by overpopulation**: A live cell with **more than 3** live neighbors dies.
4. **Birth**: A dead cell with **exactly 3** live neighbors becomes alive.

All updates happen **simultaneously** at each generation step.

---

## 🧩 Your Task

You must implement the `cgol` module, which simulates the Game of Life.

The module can be found in `src/rtl/cgol.sv`.

Your module must use the provided interface `_if`. Full explanation of how to use interfaces can be found here: [SystemVerilog Interfaces](./docs/Quick%20Guide%20to%20SystemVerilog%20Interfaces.md)

- Explicit inputs:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset signal

- Interface port:
  - `_if.DUT cgol_port`: The interface instance that bundles all control/data signals.

Example module declaration:

```systemverilog
module cgol #(
  parameter N = 3,
  parameter M = 256
)(
  input logic clk,
  input logic rst_n,
  _if.DUT cgol_port
);
```

### Interface Signals (through `cgol_port`)

- **Inputs:**
  - `row_idx [7:0]`: Row address for reading or writing a cell
  - `col_idx [7:0]`: Column address for reading or writing a cell
  - `din`: Data input to write (0 or 1)
  - `din_wr`: Write enable signal – when high, write `din` to the specified cell
  - `din_rd`: Read enable signal – when high, prepare the output of the specified cell
  - `gstep`: Advance one generation – when high for one clock cycle, trigger a generation step

- **Outputs:**
  - `dout`: Data output
  - `done`: Indicates that a generation step (`gstep`) has completed

---

### Important Behavior Requirements

- The grid size is determined by parameters `N` (rows) and `M` (columns).
- Assume both `N` and `M` are no larger than 32.
- The grid is **not circular**. Neighbor accesses that fall outside the grid must be treated as dead cells (0).
- All control signals (`din_wr`, `din_rd`, `gstep`) are **one-cycle pulses**.
- **Read/Write operations take exactly one clock cycle**.
  - If `din_rd` is high at clock cycle *N*, then `dout` must be valid at *N+1*.
  - If `din_wr` is high at clock cycle *N*, the new value must be stored during *N+1*.
- **Generation steps (`gstep`) may take multiple cycles**. Assert `done` when the generation update is complete.

---

## 🧪 Testing

A complete SystemVerilog testbench is provided.

You can run the testbench from the **runspace** directory.

**First**, set up the environment.

```bash
tsmc65
```

**Then**, clone the repository:

```bash
git clone https://github.com/EyalYe/DDP25-HW6.git
```

Change to the cloned project directory:

```bash
cd DDP25-HW6
code .
```
The file `src/rtl/cgol.sv` contains the `cgol` module. You will implement your design in this file.

Enter the **runspace** directory and run the simulation:

```bash
cd runspace
xrun -f ../src/cgol.f
```

To run with a GUI (waveform viewer):

```bash
xrun -f ../src/cgol.f -gui -debug
```

The testbench will automatically load a pattern, simulate 50 generations, and check correctness using a Python script.

---

## 💡 Tips

- Handle **out-of-bounds** neighbor accesses by treating them as 0.
- Use **two grids** internally — one for the current generation and a temporary one for computing the next.
- Prioritize operations correctly if multiple control signals are active.
- Remember: `dout` must only be valid after a **din_rd** command.
- The **generation step (`gstep`)** can take many cycles — don't forget to properly control the `done` signal.
- After a successful simulation, to see the pattern animation:

```bash
python3 ../src/scripts/animate_life.py --dir=./generations --delay=0.1
```

---

## ✅ Submission

Submit the following:

- A lab report (PDF) that includes:
  - A brief description of your design and choices.
  - Your full `cgol` module code.
  - Your synthesis report.
- Include the `.tgz` file generated during synthesis.

---

# 🚀 GOOD LUCK!  
Enjoy creating a living, breathing digital universe!

---
