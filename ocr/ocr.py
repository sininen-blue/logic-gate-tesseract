import pytesseract
import cv2
import argparse
import json

# TODO: need to generate a standard table for non standard tables (test2.png)

parser = argparse.ArgumentParser()
parser.add_argument("input_file", help="Input file path")
parser.add_argument("-c", "--columns", required=True, dest="columns",
                    type=int, help="Number of columns")
parser.add_argument("-r", "--rows", required=True, dest="rows",
                    type=int, help="Number of rows")
args = parser.parse_args()


custom_config = r'--psm 10 --oem 3'
image_path = args.input_file
row_count = args.rows
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


def detect_border(image, binary):
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


def remove_lines(image, binary):
    horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
    vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 25))

    horizontal_lines = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, horizontal_kernel, iterations=2)
    vertical_lines = cv2.morphologyEx(
        binary, cv2.MORPH_OPEN, vertical_kernel, iterations=2)

    table_mask = cv2.add(horizontal_lines, vertical_lines)
    cleaned_image = cv2.subtract(binary, table_mask)

    # invert for black text and white background
    cleaned_image = cv2.bitwise_not(cleaned_image)

    return cleaned_image


def read_table(table_image):
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


def main():
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    _, binary = cv2.threshold(image, 200, 255, cv2.THRESH_BINARY_INV)

    cropped_image, cropped_binary = detect_border(image, binary)
    cleaned_img = remove_lines(cropped_image, cropped_binary)
    data = {
        "truth_table": read_table(cleaned_img),
    }
    json_string = json.dumps(data)
    print(json_string)


if __name__ == "__main__":
    main()
