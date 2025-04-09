
# HW5 – Conway’s Game of Life (CGOL)

## 🧠 Overview

In this assignment, you will implement the **core logic module** for **Conway’s Game of Life** – a classic cellular automaton – in SystemVerilog. You’ll write the logic that simulates each generation of a grid of binary cells based on local neighborhood rules.

The grid is parameterized, and your module must support reading/writing individual cells, as well as advancing the simulation by one generation step.

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

You must implement the `des` module which simulates the Game of Life. Your module should support the following interface signals:

- **Inputs:**
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `row_idx [7:0]`: Row address for reading or writing a cell
  - `col_idx [7:0]`: Column address for reading or writing a cell
  - `din`: Data input to write (0 or 1)
  - `din_wr`: Write enable signal – when high, write `din` to the specified cell
  - `din_rd`: Read enable signal – when high, prepare the output of the specified cell
  - `gstep`: Advance one generation – when high for one cycle, the grid updates to the next state

- **Output:**
  - `dout`: Data output

The grid size is determined by the parameters:
- `parameter N`: Number of rows
- `parameter M`: Number of columns

You may assume both `N` and `M` are no larger than 32.

**Note**: The grid is **not** circular. Cells on the edges have fewer than 8 neighbors, and out-of-bounds accesses should be treated as dead cells (0). 

**Important**: All operations must be done in a single clock cycle. i.e., raising din_wr or gstep must not take multiple cycles to complete.
---

## 🧪 Testing

A complete SystemVerilog testbench is provided.

You can run the testbench using the following command from **runspace** directory:

```bash
xrun -f ../src/cgol.f
```

if you wish to use the gui, you can run:

```bash
xrun -f ../src/cgol.f -gui -debug
```

---

## 💡 Tips

- Handle out-of-bound neighbor accesses gracefully (e.g., treat them as dead).
- Use a 2D array to represent the grid.
- Use a temporary grid to compute the next generation before updating the main grid.
- Think about which signal has priority when multiple signals are asserted at the same time (e.g., `din_wr` vs. `gstep`).
- Does `dout` output is valid only when `din_rd` is asserted?
- Make your life easier and run the testbench in **runspace** directory.

---

## ✅ Submission

- Submit a lab report in PDF format containing:
  - A brief description of your design.
  - Your implementation of the `des` module.
  - The synthesis report.

---

## GOOD LUCK!
