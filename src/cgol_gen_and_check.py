import argparse
import os
os.makedirs('generations', exist_ok=True)

generators = {
    1: [  # Glider (padded to 4x5)
        [0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [1, 1, 1, 0, 0],
        [0, 0, 0, 0, 0]
    ],
    2: [  # Blinker (vertical, padded to 4x5)
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 0, 0, 0, 0]
    ],
    3: [  # Lightweight Spaceship (LWSS)
        [0, 1, 1, 1, 1],
        [1, 0, 0, 0, 1],
        [0, 0, 0, 0, 1],
        [1, 0, 0, 1, 0]
    ],
    4: [  # R-pentomino
        [0, 1, 1, 0, 0],
        [1, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 0, 0, 0, 0]
    ],
    5: [  # Toad
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [1, 1, 1, 0, 0],
        [0, 0, 0, 0, 0]
    ],
    6: [  # Beacon
        [1, 1, 0, 0, 0],
        [1, 1, 0, 0, 0],
        [0, 0, 1, 1, 0],
        [0, 0, 1, 1, 0]
    ]
}

def generate_pattern(N, M, ID):
    """
    Generate a Conway's Game of Life pattern based on the given ID.
    N = number of rows, M = number of columns
    """
    board = [[0 for _ in range(M)] for _ in range(N)]
    chosen_pattern = generators.get((ID % len(generators)) + 1, generators[1])

    start_row = (N - len(chosen_pattern)) // 2
    start_col = (M - len(chosen_pattern[0])) // 2
    for i in range(len(chosen_pattern)):
        for j in range(len(chosen_pattern[i])):
            board[start_row + i][start_col + j] = chosen_pattern[i][j]

    with open('pattern.txt', 'w') as f:
        for row in board:
            f.write(''.join(str(cell) for cell in row) + '\n')
    with open('generations/generation_0.txt', 'w') as f:
        for row in board:
            f.write(''.join(str(cell) for cell in row) + '\n')
    return board

def check_pattern(N, M, ID, gen):
    """
    Check if the given pattern is valid according to Conway's Game of Life rules.
    """
    try:
        with open('exported_pattern.txt', 'r') as f:
            lines = f.readlines()
            board = [[int(cell) for cell in line.split()] for line in lines]
    except FileNotFoundError:
        print("Error: exported_pattern.txt not found.")
        return
    except ValueError:
        print("Error: exported_pattern.txt contains invalid data.")
        return
    except IndexError:
        print("Error: exported_pattern.txt does not match the expected format.")
        return
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return

    expected_pattern = generate_pattern(N, M, ID)
    for i in range(gen):
        expected_pattern = next_generation(expected_pattern)

    if board == expected_pattern:
        with open('check_result.txt', 'w') as f:
            f.write("1")
        with open(f'generations/generation_{gen}.txt', 'w') as f:
            for row in expected_pattern:
                f.write(''.join(str(cell) for cell in row) + '\n')
    else:
        print("\n\n\n----------------------------------------")
        print("Error: Pattern does not match the expected pattern.")
        print("Expected pattern:")
        for row in expected_pattern:
            print(''.join(str(cell) for cell in row))
        print("Exported pattern:")
        for row in board:
            print(''.join(str(cell) for cell in row))
        print("----------------------------------------\n\n\n")
        with open('check_result.txt', 'w') as f:
            f.write("0")

def next_generation(board):
    """
    Compute the next generation of the board according to Conway's Game of Life rules.
    """
    N = len(board)
    M = len(board[0])
    new_board = [[0 for _ in range(M)] for _ in range(N)]
    
    for i in range(N):
        for j in range(M):
            alive_neighbors = sum(
                board[x][y]
                for x in range(max(0, i-1), min(N, i+2))
                for y in range(max(0, j-1), min(M, j+2))
                if (x != i or y != j)
            )
            if board[i][j] == 1 and alive_neighbors in (2, 3):
                new_board[i][j] = 1
            elif board[i][j] == 0 and alive_neighbors == 3:
                new_board[i][j] = 1
    return new_board

def main():
    parser = argparse.ArgumentParser(description="Generate and check Conway's Game of Life patterns.")
    parser.add_argument('--check', action='store_true', help='Check the pattern instead of generating it')
    parser.add_argument('N', type=int, help='Number of rows in the pattern')
    parser.add_argument('M', type=int, help='Number of columns in the pattern')
    parser.add_argument('ID', type=int, help='ID of the pattern to generate or check')
    parser.add_argument('gen', type=int, help='generation number (0 for initial state, 1 for next generation)')
    args = parser.parse_args()

    if args.check:
        check_pattern(args.N, args.M, args.ID, args.gen)
    else:
        print(f"Generating pattern with ID {args.ID} for a grid of size {args.N}x{args.M}")
        generate_pattern(args.N, args.M, args.ID)
        print("Pattern generated and saved to pattern.txt")

if __name__ == "__main__":
    main()
