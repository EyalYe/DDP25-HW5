import os
import time
import argparse

def read_generation_file(filename):
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
            return [list(line.strip()) for line in lines]
    except FileNotFoundError:
        return None

def display_board(board):
    os.system('cls' if os.name == 'nt' else 'clear')  # Clear screen
    for row in board:
        line = ''.join('█' if cell == '1' else ' ' for cell in row)
        print(line)

def animate_generations(directory, delay=0.3):
    generation = 0
    while True:
        filename = os.path.join(directory, f'generation_{generation}.txt')
        board = read_generation_file(filename)
        if board is None:
            break
        print(f"Generation {generation}")
        display_board(board)
        time.sleep(delay)
        generation += 1

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Animate Game of Life generations in the terminal.")
    parser.add_argument('--dir', type=str, default='.', help='Directory containing generation_*.txt files')
    parser.add_argument('--delay', type=float, default=0.3, help='Delay between frames (in seconds)')
    args = parser.parse_args()

    animate_generations(args.dir, args.delay)
