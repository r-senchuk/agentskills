---
name: mistral-document-ai
description: "Use when you need to extract text, tables, and structure from PDF documents or images using Mistral OCR, pipe extracted content into an LLM for analysis, or run batch document processing at scale. Do not use for plain-text inputs, web scraping, or tasks that do not require document parsing."
argument-hint: "Document source (file path, URL, or base64), extraction options (tables, headers, footers), and downstream task (summarize, extract fields, Q&A)"
user-invocable: false
---

# Mistral Document AI

End-to-end workflow for extracting structured content from PDFs and images using the Mistral OCR API (`mistral-ocr-latest`), and piping the extracted markdown into downstream LLM tasks.

## When To Use
- You need to extract text from a PDF, PowerPoint, Word document, or image.
- You need tables, headers, and footers preserved as structured output.
- You want to feed document content into an LLM for summarization, Q&A, or data extraction.
- You are processing large document batches and need cost-effective async processing.

Do NOT use for:
- Plain-text or HTML inputs that don't require OCR (use the LLM directly).
- Web scraping or URL content extraction (use a web-fetch tool instead).
- Real-time streaming transcription of audio or video.

## Inputs To Collect First
1. Document source: public URL, local file path (will be base64-encoded), or cloud-uploaded file ID.
2. Document type: PDF (`document_url`) or image (`image_url`).
3. Extraction options: include tables (`markdown`/`html`/`null`), extract headers/footers.
4. Downstream task: what to do with the extracted content (summarize, extract fields, answer questions).
5. Scale: single document (sync) or bulk (batch API).

## Procedure

### Step 1 — Prepare the Document Input

**Public URL (simplest):**
```python
doc_input = {
    "type": "document_url",
    "document_url": "https://example.com/report.pdf",
}
```

**Local file (base64):**
```python
import base64

def load_pdf_as_base64(path: str) -> str:
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

doc_input = {
    "type": "document_url",
    "document_url": f"data:application/pdf;base64,{load_pdf_as_base64('report.pdf')}",
}
```

**Image:**
```python
doc_input = {
    "type": "image_url",
    "image_url": "https://example.com/invoice.png",
    # or: "image_url": f"data:image/jpeg;base64,{base64_str}"
}
```

**Upload to Mistral Files API (for large files or reuse):**
```python
with open("large_report.pdf", "rb") as f:
    uploaded = client.files.upload(file=("large_report.pdf", f, "application/pdf"))
file_id = uploaded.id
doc_input = {"type": "document_url", "document_url": f"file://{file_id}"}
```

### Step 2 — Run OCR Extraction

```python
import os
from mistralai import Mistral

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])

ocr_response = client.ocr.process(
    model="mistral-ocr-latest",
    document=doc_input,
    include_image_base64=False,   # set True to get embedded images
)
```

**With table and header/footer extraction:**
```python
ocr_response = client.ocr.process(
    model="mistral-ocr-latest",
    document=doc_input,
    table_format="markdown",      # null | markdown | html
    extract_header=True,
    extract_footer=True,
    include_image_base64=False,
)
```

`table_format` options:
- `null` — tables returned inline as markdown within page content.
- `markdown` — tables returned separately as markdown tables.
- `html` — tables returned separately as HTML.

### Step 3 — Parse Extracted Content

```python
def extract_full_text(ocr_response) -> str:
    """Concatenate all pages into a single markdown string."""
    pages = []
    for page in ocr_response.pages:
        pages.append(page.markdown)
    return "\n\n---\n\n".join(pages)  # page separator

full_text = extract_full_text(ocr_response)
```

Access metadata:
```python
for page in ocr_response.pages:
    print(f"Page {page.index}: {len(page.markdown)} chars")
    if page.header:
        print(f"  Header: {page.header}")
    if page.footer:
        print(f"  Footer: {page.footer}")
    for img in page.images:
        print(f"  Image placeholder: {img.id} at bbox {img.bbox}")
```

Image and table placeholders in markdown look like:
- `![img-0.jpeg](img-0.jpeg)` — replace using `page.images[i].image_base64`
- `[tbl-3.html](tbl-3.html)` — replace using `page.tables[i].content`

### Step 4 — Pipe Content to LLM for Downstream Tasks

**Summarization:**
```python
def summarize_document(text: str, model: str = "mistral-large-latest") -> str:
    response = client.chat.complete(
        model=model,
        messages=[
            {"role": "system", "content": "Summarize the document in 3–5 bullet points. Focus on key findings."},
            {"role": "user", "content": text[:32000]},  # respect context window
        ],
    )
    return response.choices[0].message.content
```

**Document Q&A:**
```python
def ask_document(text: str, question: str, model: str = "mistral-large-latest") -> str:
    response = client.chat.complete(
        model=model,
        messages=[
            {"role": "system", "content": "Answer questions based only on the provided document."},
            {"role": "user", "content": f"Document:\n{text[:28000]}\n\nQuestion: {question}"},
        ],
    )
    return response.choices[0].message.content
```

**Structured extraction (combine with `mistral-structured-outputs`):**
```python
# Pass extracted text as input to the structured extraction skill
from pydantic import BaseModel

class ContractSummary(BaseModel):
    parties: list[str]
    effective_date: str
    termination_clause: str | None

response = client.chat.parse(
    model="mistral-large-latest",
    messages=[
        {"role": "system", "content": "Extract contract details from the document."},
        {"role": "user", "content": full_text[:28000]},
    ],
    response_format=ContractSummary,
)
contract = response.choices[0].message.parsed
```

### Step 5 — Scale with Batch API

For 10+ documents, use the Batch API to process in parallel at lower cost:

```python
# Prepare batch requests as JSONL
import jsonlines

requests = []
for i, doc_url in enumerate(document_urls):
    requests.append({
        "custom_id": f"doc-{i}",
        "method": "POST",
        "url": "/v1/ocr",
        "body": {
            "model": "mistral-ocr-latest",
            "document": {"type": "document_url", "document_url": doc_url},
            "table_format": "markdown",
        }
    })

with open("batch_ocr.jsonl", "w") as f:
    writer = jsonlines.Writer(f)
    writer.write_all(requests)

# Submit batch
with open("batch_ocr.jsonl", "rb") as f:
    batch_file = client.files.upload(file=("batch_ocr.jsonl", f, "application/json"))

batch_job = client.batch.jobs.create(
    input_files=[batch_file.id],
    endpoint="/v1/ocr",
    model="mistral-ocr-latest",
)

# Poll for completion
import time
while batch_job.status not in ("SUCCESS", "FAILED", "CANCELLED"):
    time.sleep(10)
    batch_job = client.batch.jobs.get(job_id=batch_job.id)

print(f"Batch status: {batch_job.status}")
```

## Completion Checks
- [ ] Document URL is publicly accessible or file is uploaded via the Files API before calling OCR.
- [ ] `table_format` and header/footer options match the document type and downstream needs.
- [ ] Page content respects the generation model's context window (truncate or chunk if needed).
- [ ] Image and table placeholders resolved before passing markdown to the downstream LLM.
- [ ] Batch jobs poll no faster than every 10 seconds; status checked until `SUCCESS`, `FAILED`, or `CANCELLED`.

## References
- [Document preprocessing patterns](./references/document-preprocessing.md)
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
