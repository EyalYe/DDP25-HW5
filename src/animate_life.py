import os
import sys
import time
import argparse
import subprocess

def try_import_colorama():
    try:
        from colorama import init, deinit, Fore, Cursor
        init()
        return True, init, deinit, Fore, Cursor
    except ImportError:
        print("colorama is not installed. Attempting to install...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "colorama"])
            from colorama import init, deinit, Fore, Cursor
            init()
            return True, init, deinit, Fore, Cursor
        except Exception as e:
            print("Failed to install colorama. Continuing without color/animations.")
            return False, None, None, None, None

# Try to import or install colorama
colorama_available, init_func, deinit_func, Fore, Cursor = try_import_colorama()

def read_generation_file(filename):
    try:
        with open(filename, 'r') as f:
            return [list(line.strip()) for line in f]
    except FileNotFoundError:
        return None

def display_board(board, prev_board=None):
    if not colorama_available:
        for row in board:
            line = ''.join('█' if cell == '1' else ' ' for cell in row)
            print(line)
        return

    rows, cols = len(board), len(board[0])
    for r in range(rows):
        for c in range(cols):
            cell = board[r][c]
            if prev_board is None or prev_board[r][c] != cell:
                char = Fore.GREEN + '█' if cell == '1' else Fore.LIGHTBLACK_EX + '.'
                sys.stdout.write(Cursor.POS(c * 2 + 1, r + 1))
                sys.stdout.write(char)
    sys.stdout.flush()

def animate_generations(directory, delay=0.3):
    generation = 0
    prev_board = None

    if colorama_available:
        print('\033[?25l', end='')  # Hide cursor
        sys.stdout.write(Cursor.POS(1, 1))

    while True:
        filename = os.path.join(directory, f'generation_{generation}.txt')
        board = read_generation_file(filename)
        if board is None:
            break
        display_board(board, prev_board)
        prev_board = board
        time.sleep(delay)
        generation += 1

    if colorama_available:
        print('\033[?25h', end='')  # Show cursor
        sys.stdout.write(Cursor.POS(1, len(prev_board) + 2))
        deinit_func()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Animate Game of Life generations in the terminal.")
    parser.add_argument('--dir', type=str, default='.', help='Directory containing generation_*.txt files')
    parser.add_argument('--delay', type=float, default=0.3, help='Delay between frames (in seconds)')
    args = parser.parse_args()
    os.system('cls' if os.name == 'nt' else 'clear')

    animate_generations(args.dir, args.delay)
