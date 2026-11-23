"""Private, bounded text extraction. Originals never leave the knowledge bucket."""
import io
import os
import boto3
from botocore.config import Config
from pypdf import PdfReader

s3 = boto3.client("s3", config=Config(retries={"mode": "standard", "total_max_attempts": 3}, connect_timeout=5, read_timeout=30))
BUCKET = os.environ.get("KNOWLEDGE_BUCKET")

def extract(data):
    if len(data) > 20 * 1024 * 1024 or not data.startswith(b"%PDF-"):
        raise ValueError("Choose a PDF smaller than 20 MB.")
    reader = PdfReader(io.BytesIO(data), strict=False)
    if reader.is_encrypted:
        raise ValueError("Password-protected PDFs are unsupported. Export an unlocked copy first.")
    if len(reader.pages) > 1000:
        raise ValueError("Split this PDF into documents of at most 1,000 pages.")
    pages, total = [], 0
    for number, page in enumerate(reader.pages, 1):
        # Bound text output as well as input; complex malformed PDFs remain bounded
        # by the isolated Lambda's memory and execution timeout.
        text = (page.extract_text() or "").strip()
        total += len(text)
        if total > 4_000_000:
            raise ValueError("The extracted book is too large. Split it into smaller PDFs.")
        if text:
            pages.append({"page": number, "text": text})
    if total < 200:
        raise ValueError("No usable PDF text found. Run OCR locally, then submit the searchable PDF.")
    return pages

def handler(event, context):
    source_id = event.get("sourceId", "")
    if len(source_id) != 64 or any(c not in "0123456789abcdef" for c in source_id):
        raise ValueError("Invalid source identifier")
    response = s3.get_object(Bucket=BUCKET, Key=f"raw/{source_id}/input")
    with response["Body"] as body:
        data = body.read(20 * 1024 * 1024 + 1)
    try:
        pages = extract(data)
    except ValueError as error:
        return {"error": str(error)}
    import json
    key = f"extracted/{source_id}.json"
    s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps(pages).encode(), ContentType="application/json")
    return {"key": key, "pages": len(pages)}
