# logic-gate-tesseract
A logic gate game

dependencies
- godot 4.3-stable
- python 3.12
- tesseract 5.4.0

## For the OCR module to work
```
cd ocr
python -m venv .venv
.venv/Scripts/activate
pip install -r requirements.txt
pyinstaller --onefile ocr.py
```
