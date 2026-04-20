from fastapi import FastAPI, File, UploadFile, HTTPException
import tempfile
import os

from app.predict import predict

app = FastAPI(title="Smart Dental - AI Inference")


@app.post("/predict")
def predict_upload(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    contents = file.file.read()
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename or "")[-1] or ".jpg") as f:
            f.write(contents)
            f.flush()
            result = predict(f.name)
    finally:
        try:
            os.unlink(f.name)
        except Exception:
            pass
    return result


@app.get("/health")
def health():
    return {"status": "ok"