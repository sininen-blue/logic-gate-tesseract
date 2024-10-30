# logic-gate-tesseract
A logic gate game

dependencies
- godot 4.3-stable
- python 3.12
- [tesseract 5.4.0](https://github.com/UB-Mannheim/tesseract/wiki)
  ![image](https://github.com/user-attachments/assets/9b31bddb-7f03-4453-8e98-85d5f5a8bec7)


## For the OCR module to work
```
cd ocr
python -m venv .venv
.venv/Scripts/activate
pip install -r requirements.txt
pyinstaller --onefile ocr.py
```
