from fastapi import FastAPI, File, UploadFile
import pytesseract
from PIL import Image
import io
import uvicorn
import os

app = FastAPI(
    title="OCR API",
    description="Extract text from images using Tesseract OCR",
    version="1.0.0"
)

# Set Tesseract executable path
pytesseract.pytesseract.tesseract_cmd = os.environ.get("TESSERACT_PATH", "tesseract")

@app.get("/")
def read_root():
    return {"message": "Welcome to the OCR API!"}

@app.post("/ocr/")
async def extract_text(file: UploadFile = File(...)):
    # Read the uploaded file into memory
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    # Use pytesseract to extract text
    text = pytesseract.image_to_string(image)

    return {"extracted_text": text}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0")
