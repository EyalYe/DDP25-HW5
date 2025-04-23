import os
import sys
import argparse
import subprocess

CELL_SIZE = 20
PADDING = 2
LIVE_COLOR = (0, 255, 0)
DEAD_COLOR = (30, 30, 30)
BG_COLOR = (10, 10, 10)
BUTTON_COLOR = (50, 50, 50)
BUTTON_HOVER = (80, 80, 80)
TEXT_COLOR = (200, 200, 200)

def try_import_pygame():
    try:
        import pygame
        return True, pygame
    except ImportError:
        print("pygame not found. Attempting to install...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "pygame"])
            import pygame
            return True, pygame
        except Exception as e:
            print("Failed to install pygame:", e)
            return False, None

# Try to import pygame
pygame_available, pygame = try_import_pygame()

def read_generation_file(filename):
    try:
        with open(filename, 'r') as f:
            return [list(line.strip()) for line in f]
    except FileNotFoundError:
        return None

def draw_board(screen, board, pygame):
    screen.fill(BG_COLOR)
    for y, row in enumerate(board):
        for x, cell in enumerate(row):
            color = LIVE_COLOR if cell == '1' else DEAD_COLOR
            rect = pygame.Rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE - PADDING, CELL_SIZE - PADDING)
            pygame.draw.rect(screen, color, rect)
    pygame.display.flip()

def draw_replay_button(screen, font, pygame, cols, rows):
    width, height = 200, 60
    x = (cols * CELL_SIZE - width) // 2
    y = (rows * CELL_SIZE - height) // 2
    mouse = pygame.mouse.get_pos()
    click = pygame.mouse.get_pressed()

    hovered = x < mouse[0] < x + width and y < mouse[1] < y + height
    color = BUTTON_HOVER if hovered else BUTTON_COLOR
    pygame.draw.rect(screen, color, (x, y, width, height), border_radius=10)

    text = font.render("Replay", True, TEXT_COLOR)
    text_rect = text.get_rect(center=(x + width // 2, y + height // 2))
    screen.blit(text, text_rect)
    pygame.display.flip()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            return False
        if hovered and click[0]:
            return True
    return None

def animate_generations(directory, delay):
    if not pygame_available:
        print("pygame not available.")
        return

    pygame.init()
    font = pygame.font.SysFont(None, 36)

    # Get initial board to determine size
    board = read_generation_file(os.path.join(directory, "generation_0.txt"))
    if not board:
        print("No generation_0.txt found.")
        return
    rows, cols = len(board), len(board[0])
    screen = pygame.display.set_mode((cols * CELL_SIZE, rows * CELL_SIZE))
    pygame.display.set_caption("Conway's Game of Life Animation")

    clock = pygame.time.Clock()
    running = True

    while running:
        generation = 0
        prev_board = None
        while True:
            path = os.path.join(directory, f"generation_{generation}.txt")
            board = read_generation_file(path)
            if not board:
                break
            draw_board(screen, board, pygame)
            generation += 1
            clock.tick(1 / delay)

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                    break
            if not running:
                break

        if not running:
            break

        # Show replay button
        waiting = True
        while waiting:
            screen.fill(BG_COLOR)
            draw_replay_button(screen, font, pygame, cols, rows)
            result = draw_replay_button(screen, font, pygame, cols, rows)
            if result is False:
                running = False
                waiting = False
            elif result is True:
                waiting = False

    pygame.quit()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Animate Game of Life generations with replay support.")
    parser.add_argument('--dir', type=str, default='.', help='Directory containing generation_*.txt files')
    parser.add_argument('--delay', type=float, default=0.3, help='Delay between frames in seconds')
    args = parser.parse_args()

    animate_generations(args.dir, args.delay)
