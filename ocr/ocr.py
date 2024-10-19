import pytesseract
import cv2
import argparse
import json
import sys


# TODO: pyinstaller and tesseract bin, for packaging
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
    possible_ones = ["l", "L", "|", "i"]
    possible_zeroes = ["o", "O"]

    if output in possible_ones:
        output = "1"

    if output in possible_zeroes:
        output = "0"

    return output


def remove_lines(image):
    _, binary = cv2.threshold(image, 200, 255, cv2.THRESH_BINARY_INV)

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

    cv2.imshow("Cleaned Image", cleaned_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    return cleaned_image


def read_table(table_image):
    height, width = table_image.shape
    cell_height, cell_width = height // row_count, width // column_count

    # TODO: preprocess to remove lines

    table = []
    for i in range(row_count):  # row
        row = []
        for j in range(column_count):  # colum
            cell = table_image[i * cell_height:(i + 1) * cell_height,
                               j * cell_width:(j + 1) * cell_width]

            # cv2.imwrite(f"cell_{i}_{j}.png", cell)

            text = pytesseract.image_to_string(cell, config=custom_config)
            cleaned_text = format(text)
            row.append(cleaned_text)

        table.append("".join(row))

    return table


def main():
    # auto detect borders at some point
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    roi = cv2.selectROI("Select Region", img,
                        showCrosshair=True, fromCenter=False)
    x, y, w, h = roi

    cropped_img = img[int(y):int(y + h), int(x):int(x + w)]
    cv2.imshow("Cropped Image", cropped_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    cleaned_img = remove_lines(cropped_img)
    data = {
        "truth_table": read_table(cleaned_img),
    }
    json_string = json.dumps(data)
    sys.stdout.write(json_string)


if __name__ == "__main__":
    main()
