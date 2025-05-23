from PIL import Image
import os

# Directory containing your letter images
image_dir = 'images/'
output_path = 'assets/amharic_letters_collage.png'

# Mapping of letter keys to Amharic image filenames
letter_image_map = {
    'ha': 'ሀ.jpg', 'la': 'ለ.jpg', 'ha2': 'ሐ.jpg', 'ma': 'መ.jpg', 'sa': 'ሠ.jpg', 'ra': 'ረ.jpg',
    'sa2': 'ሰ.jpg', 'sha': 'ሸ.jpg', 'qa': 'ቀ.jpg', 'ba': 'በ.jpg', 'ta': 'ተ.jpg', 'cha': 'ቸ.jpg',
    'kha': 'ኀ.jpg', 'na': 'ነ.jpg', 'nya': 'ኘ.jpg', 'a': 'አ.jpg', 'ka': 'ከ.jpg', 'kha2': 'ኸ.jpg',
    'wa': 'ወ.jpg', 'aa': 'ዐ.jpg', 'za': 'ዘ.jpg', 'zha': 'ዠ.jpg', 'ya': 'የ.jpg', 'da': 'ደ.jpg',
    'ja': 'ጀ.jpg', 'ga': 'ገ.jpg', 'ta2': 'ጠ.jpg', 'cha2': 'ጨ.jpg', 'pa': 'ጰ.jpg', 'tsa': 'ጸ.jpg',
    'tsa2': 'ፀ.jpg', 'fa': 'ፈ.jpg', 'pa2': 'ፐ.jpg'
}

# List of letter keys in order
letters = [
    'ha', 'la', 'ha2', 'ma', 'sa', 'ra', 'sa2', 'sha', 'qa', 'ba', 'ta', 'cha',
    'kha', 'na', 'nya', 'a', 'ka', 'kha2', 'wa', 'aa', 'za', 'zha', 'ya', 'da',
    'ja', 'ga', 'ta2', 'cha2', 'pa', 'tsa', 'tsa2', 'fa', 'pa2'
]

# Grid settings
cell_size = 150  # 150x150 cells
grid_size = (5, 7)  # 5x7 grid
collage_width = cell_size * grid_size[0]  # 750px
collage_height = cell_size * grid_size[1]  # 1050px
target_size = (150, 150)  # Target image size

# Function to standardize image size
def standardize_image(img, target_size):
    # Resize while maintaining aspect ratio
    img.thumbnail(target_size, Image.Resampling.LANCZOS)
    img_width, img_height = img.size
    # Create a new white background
    new_img = Image.new('RGB', target_size, (255, 255, 255))
    # Paste the image in the center
    paste_x = (target_size[0] - img_width) // 2
    paste_y = (target_size[1] - img_height) // 2
    new_img.paste(img, (paste_x, paste_y))
    return new_img

# Create a new blank collage
collage = Image.new('RGB', (collage_width, collage_height), (255, 255, 255))

# Place each image
for idx, letter in enumerate(letters):
    if idx >= len(letters):
        break
    row = idx // grid_size[0]
    col = idx % grid_size[0]
    
    # Load and standardize the image
    img_filename = letter_image_map.get(letter, '')
    img_path = os.path.join(image_dir, img_filename)
    try:
        img = Image.open(img_path)
        img = standardize_image(img, target_size)
        collage.paste(img, (col * cell_size, row * cell_size))
    except FileNotFoundError:
        print(f"Image not found for {letter}: {img_path}")
        # Draw a gray placeholder
        collage.paste(Image.new('RGB', target_size, (200, 200, 200)), (col * cell_size, row * cell_size))

# Save the collage
collage.save(output_path, quality=85)
print(f"Collage saved to {output_path}")