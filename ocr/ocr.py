import pytesseract
import cv2


# Plan
# *get the image
# *set the bounds of the table
# *figure out how many columns and rows there are in
# *   the table (might need manual input)
# preprocess to remove straight lines

# separate each cell
# read each cell
# return a json with a ["001", "011", ...] output

custom_config = r'--psm 10 --oem 3'
image_path = "test.png"


def format(text: str) -> str:

    return


def remove_lines():
    horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 1))
    vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 25))


def read_table(row_count, column_count, cropped_img):
    height, width = cropped_img.shape
    cell_height, cell_width = height // row_count, width // column_count

    # TODO: preprocess to remove lines

    table = []
    for i in range(row_count):  # row
        row = []
        for j in range(column_count):  # colum
            cell = cropped_img[i * cell_height:(i + 1) * cell_height,
                               j * cell_width:(j + 1) * cell_width]

            # cv2.imwrite(f"cell_{i}_{j}.png", cell)

            text = pytesseract.image_to_string(cell, config=custom_config)
            row.append(text)
        table.append(row)

    return table


def main():
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    roi = cv2.selectROI("Select Region", img,
                        showCrosshair=True, fromCenter=False)
    x, y, w, h = roi
    cropped_img = img[int(y):int(y + h), int(x):int(x + w)]
    cv2.imshow("Cropped Image", cropped_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    rows = int(input("Enter number of rows (including headers): "))
    columns = int(input("enter number of columns: "))

    for row in read_table(rows, columns, cropped_img):
        print(row)


if __name__ == "__main__":
    main()
