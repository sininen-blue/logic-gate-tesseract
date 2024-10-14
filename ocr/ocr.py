import numpy as np
import pytesseract
import cv2
from PIL import Image

# Plan
# get the image
# set the bounds of the table
# figure out how many columns and rows there are in
#    the table (might need manual input)
# separate each cell
# read each cell
# return a json with a ["001", "011", ...] output

custom_config = r'--psm 10 --oem 3'

image_path = "test.png"
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

height, width = img.shape
cell_height, cell_width = height // 9, width // 4

table = []

for i in range(9):  # row
    row = []
    for j in range(4):  # colum
        cell = img[i * cell_height:(i + 1) * cell_height,
                   j * cell_width:(j + 1) * cell_width]

        # cv2.imwrite(f"cell_{i}_{j}.png", cell)

        text = pytesseract.image_to_string(cell, config=custom_config)
        row.append(text)
    table.append(row)


for row in table:
    print(row)
