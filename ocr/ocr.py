import pytesseract
from pytesseract import Output
from itertools import product
import cv2
import numpy as np
import argparse
import json

# TODO: need to generate a standard table for non standard tables (test2.png)


parser = argparse.ArgumentParser()
parser.add_argument("input_file", help="Input file path")
parser.add_argument("-a", "--absolute-path", dest="absolute_path",
                    help="Absolute path to tesseract.exe if it isn't in PATH")
parser.add_argument("-hm", "--handwritten-mode", action="store_true",
                    dest="handwritten_mode", help="Enablehandwritten mode")
parser.add_argument("-o", "--output-path", required=True, dest="output_path",
                    type=str, help="absolute file path of output")
parser.add_argument("-c", "--columns", required=True, dest="columns",
                    type=int, help="Number of columns")
parser.add_argument("-i", "--inputs", required=True, dest="inputs",
                    type=int, help="Number of input variables")
args = parser.parse_args()


if args.absolute_path is not None:
    # 'C:/Program Files/Tesseract-OCR/tesseract.exe'
    pytesseract.pytesseract.tesseract_cmd = args.absolute_path

custom_config = r'--psm 10 --oem 3'
custom_config_handwritten = r'--psm 6 --oem 3'
output_path = args.output_path
handwritten_mode = args.handwritten_mode
image_path = args.input_file
input_count = args.inputs
column_count = args.columns


def format(text: str) -> str:
    output = text.replace("\n", "")
    possible_ones = ["l", "L", "|", "i", "7"]
    possible_zeroes = ["o", "O"]

    if output in possible_ones:
        output = "1"

    if output in possible_zeroes:
        output = "0"

    return output


def crop_image(image, binary):
    horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
    horizontal_lines = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, horizontal_kernel, iterations=2)

    vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 25))
    vertical_lines = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, vertical_kernel, iterations=2)

    table_structure = cv2.add(horizontal_lines, vertical_lines)

    contours, _ = cv2.findContours(
        table_structure, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        largest_contour = max(contours, key=cv2.contourArea)

        x, y, w, h = cv2.boundingRect(largest_contour)
        cropped_image = image[y:y + h, x:x + w]
        cropped_binary = binary[y:y + h, x:x + w]

        return cropped_image, cropped_binary


def remove_table_lines(binary):
    horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
    vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 25))

    horizontal_lines = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, horizontal_kernel, iterations=2)
    vertical_lines = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, vertical_kernel, iterations=2)

    table_mask = cv2.add(horizontal_lines, vertical_lines)
    cleaned_binary = cv2.subtract(binary, table_mask)

    # invert for black text and white background
    cleaned_image = cv2.bitwise_not(cleaned_binary)

    return cleaned_image, cleaned_binary


def read_table(table_image, row_count):
    height, width = table_image.shape
    cell_height, cell_width = height // row_count, width // column_count

    table = []
    for i in range(row_count):  # row
        row = []
        for j in range(column_count):  # colum
            cell = table_image[i * cell_height:(i + 1) * cell_height,
                               j * cell_width:(j + 1) * cell_width]

            text = pytesseract.image_to_string(cell, config=custom_config)
            cleaned_text = format(text)
            row.append(cleaned_text)

        table.append("".join(row))

    return table


def normalize(table):
    header = ""
    if table[0].isdecimal() is False:
        header = table.pop(0)

    temp_table = list(product([0, 1], repeat=input_count))
    ideal_table = ["".join(map(str, row)) for row in temp_table]

    output_table = []
    end_count = len(table[0])-input_count

    for i in range(len(ideal_table)):
        found_flag = False
        for row in table:
            if row[:input_count] == ideal_table[i]:
                output_table.append(row)
                found_flag = True
                break

        if found_flag is False:
            output_table.append(ideal_table[i] + "0"*end_count)

    output_table.insert(0, header)  # reattach header
    return output_table


def detect_row_count(binary):
    horizontal_projection = np.sum(binary, axis=1)

    row_count = 0
    in_gap = False
    for value in horizontal_projection:
        if value > 0:
            if in_gap:
                row_count += 1
                in_gap = False
        else:
            in_gap = True

    if horizontal_projection[-1] > 0:
        row_count += 1

    return row_count


def process_text(text):
    array_output = []
    text_block = text.splitlines()

    for row in text_block:
        output_row = []
        for char in row:
            output_row.append(format(char))
        array_output.append(output_row)

    output = []
    for row in array_output:
        output.append("".join(row))

    return output


def main():
    if handwritten_mode:
        contrast = 1.5
        brightness = 0
        new_height = 720

        image = cv2.imread(image_path)
        image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        # resize if too big
        (h, w) = image.shape[:2]
        aspect_ratio = w / h
        if h >= 720:
            new_width = int(new_height * aspect_ratio)
            image = cv2.resize(image, (new_width, new_height))

        # Crop the selected region
        roi = cv2.selectROI("Select Region", image,
                            showCrosshair=True, fromCenter=False)
        x, y, w, h = roi
        image = image[int(y):int(y + h), int(x):int(x + w)]

        image = cv2.convertScaleAbs(image, alpha=contrast, beta=brightness)
        _, binary = cv2.threshold(image, 180, 255, cv2.THRESH_BINARY)

        d = pytesseract.image_to_data(binary, output_type=Output.DICT)
        n_boxes = len(d['level'])
        for i in range(n_boxes):
            (x, y, w, h) = (d['left'][i], d['top']
                            [i], d['width'][i], d['height'][i])
            cv2.rectangle(binary, (x, y), (x + w, y + h), (0, 255, 0), 2)

        text = pytesseract.image_to_string(
            binary, config=custom_config_handwritten)
        data = {
            "truth_table": process_text(text),
        }
        with open(output_path, "w") as json_file:
            json.dump(data, json_file, indent=4)

    else:
        image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        _, binary = cv2.threshold(image, 200, 255, cv2.THRESH_BINARY_INV)

        cropped_image, cropped_binary = crop_image(image, binary)
        cleaned_img, cleaned_binary = remove_table_lines(cropped_binary)
        row_count = detect_row_count(cleaned_binary)

        table = read_table(cleaned_img, row_count)
        normalized_table = normalize(table)

        data = {
            "truth_table": normalized_table,
        }
        with open(output_path, "w") as json_file:
            json.dump(data, json_file, indent=4)


if __name__ == "__main__":
    main()
