"""Generate placeholder pixel sprites for player and pet."""
from PIL import Image, ImageDraw
import os

SPRITE_SIZE = 16
FRAMES = 4

def make_character_sheet(color, filename, size=16):
    """Create a simple sprite sheet: 4 directions x 4 frames each = 16 frames in a row."""
    sheet_w = size * FRAMES * 4
    sheet_h = size
    img = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    for direction in range(4):
        for frame in range(FRAMES):
            x = (direction * FRAMES + frame) * size
            y = 0

            # Body
            draw.rectangle([x + 4, y + 4, x + 11, y + 13], fill=color)
            # Head
            draw.rectangle([x + 5, y + 2, x + 10, y + 6], fill=color)

            # Eyes (direction-dependent)
            eye_color = (255, 255, 255)
            if direction == 0:  # down
                draw.point((x + 6, y + 4), fill=eye_color)
                draw.point((x + 9, y + 4), fill=eye_color)
            elif direction == 1:  # up
                pass  # no eyes visible from back
            elif direction == 2:  # side
                draw.point((x + 8, y + 4), fill=eye_color)

            # Walk animation: shift legs
            if frame % 2 == 0:
                draw.rectangle([x + 5, y + 12, x + 7, y + 15], fill=color)
                draw.rectangle([x + 8, y + 13, x + 10, y + 15], fill=color)
            else:
                draw.rectangle([x + 5, y + 13, x + 7, y + 15], fill=color)
                draw.rectangle([x + 8, y + 12, x + 10, y + 15], fill=color)

    os.makedirs(os.path.dirname(filename), exist_ok=True)
    img.save(filename)
    print(f"Saved {filename} ({sheet_w}x{sheet_h})")

def make_pet_sheet(color, filename, size=12):
    """Smaller sprite sheet for pet."""
    sheet_w = size * FRAMES * 4
    sheet_h = size
    img = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    for direction in range(4):
        for frame in range(FRAMES):
            x = (direction * FRAMES + frame) * size
            y = 0

            # Body (smaller, rounder)
            draw.rectangle([x + 3, y + 4, x + 8, y + 9], fill=color)
            # Head
            draw.rectangle([x + 4, y + 2, x + 7, y + 5], fill=color)
            # Ears
            draw.point((x + 4, y + 1), fill=color)
            draw.point((x + 7, y + 1), fill=color)

            # Eyes
            eye_color = (40, 40, 40)
            if direction == 0:  # down
                draw.point((x + 5, y + 3), fill=eye_color)
                draw.point((x + 6, y + 3), fill=eye_color)
            elif direction == 2:  # side
                draw.point((x + 6, y + 3), fill=eye_color)

            # Tail
            if direction == 1:  # up / back view
                tail_y = y + 5 + (frame % 2)
                draw.point((x + 8, tail_y), fill=color)
                draw.point((x + 9, tail_y - 1), fill=color)

            # Walk
            if frame % 2 == 0:
                draw.rectangle([x + 3, y + 9, x + 5, y + 11], fill=color)
                draw.rectangle([x + 6, y + 10, x + 8, y + 11], fill=color)
            else:
                draw.rectangle([x + 3, y + 10, x + 5, y + 11], fill=color)
                draw.rectangle([x + 6, y + 9, x + 8, y + 11], fill=color)

    os.makedirs(os.path.dirname(filename), exist_ok=True)
    img.save(filename)
    print(f"Saved {filename} ({sheet_w}x{sheet_h})")

base = "/root/projects/healing-travel/assets/sprites"
make_character_sheet((90, 140, 200), f"{base}/player/player.png")
make_pet_sheet((240, 180, 100), f"{base}/pet/cat.png")
print("Done!")
