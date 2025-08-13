from fastapi import FastAPI, File, UploadFile
import pytesseract
from PIL import Image
import io
import uvicorn
import os
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

app = FastAPI(
    title="OCR API",
    description="Extract text from images using Tesseract OCR",
    version="1.0.0"
)

# Set Tesseract executable path
pytesseract.pytesseract.tesseract_cmd = os.environ.get("TESSERACT_PATH", "tesseract")

# Prometheus metrics
ocr_requests_total = Counter('ocr_requests_total', 'Total number of OCR requests')
ocr_processing_duration = Histogram('ocr_processing_duration_seconds', 'Time spent processing OCR requests')

@app.get("/")
def read_root():
    return {"message": "Welcome to the OCR API!"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/ocr/")
async def extract_text(file: UploadFile = File(...)):
    # Increment request counter
    ocr_requests_total.inc()
    
    # Start timing
    with ocr_processing_duration.time():
        # Read the uploaded file into memory
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))

        # Use pytesseract to extract text
        text = pytesseract.image_to_string(image)

    return {"extracted_text": text}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0")
