# Document Preprocessing Patterns

## Strip Headers and Footers from OCR Output
When `extract_header=True` / `extract_footer=True`, headers and footers are returned separately. Remove them from main content to avoid noise:

```python
def clean_page(page) -> str:
    content = page.markdown
    # Headers/footers are in page.header and page.footer — they are already
    # separated when extract_header/extract_footer is True.
    return content.strip()
```

## Resolve Image Placeholders
OCR returns `![img-0.jpeg](img-0.jpeg)` placeholders. Resolve them if you need actual images:

```python
def resolve_images(page) -> str:
    content = page.markdown
    for img in page.images:
        if img.image_base64:
            # Replace placeholder with data URI
            placeholder = f"![{img.id}]({img.id})"
            data_uri = f"data:image/jpeg;base64,{img.image_base64}"
            content = content.replace(placeholder, f"![{img.id}]({data_uri})")
    return content
```

## Resolve Table Placeholders
```python
def resolve_tables(page) -> str:
    content = page.markdown
    for tbl in page.tables:
        placeholder = f"[{tbl.id}]({tbl.id})"
        content = content.replace(placeholder, tbl.content or "")
    return content
```

## Chunk OCR Output for RAG
PDF pages are natural chunk boundaries. If pages are long, sub-chunk within pages:

```python
def ocr_to_chunks(ocr_response, max_chars: int = 2048) -> list[dict]:
    chunks = []
    for page in ocr_response.pages:
        text = page.markdown
        if len(text) <= max_chars:
            chunks.append({"page": page.index, "text": text})
        else:
            # Sub-chunk long pages
            start = 0
            while start < len(text):
                chunks.append({
                    "page": page.index,
                    "text": text[start:start + max_chars],
                    "offset": start,
                })
                start += max_chars - 128  # 128-char overlap
    return chunks
```

## Supported Input Formats

| Format | `type` field | Notes |
|---|---|---|
| PDF | `document_url` | URL, base64, or uploaded file ID |
| PPTX | `document_url` | PowerPoint |
| DOCX | `document_url` | Word document |
| PNG / JPEG / AVIF | `image_url` | URL or base64 |
| TIFF | `image_url` | Check docs for latest supported formats |

Always verify format support in the [Mistral OCR FAQ](https://docs.mistral.ai/capabilities/document_ai/basic_ocr#faq) for the most current list.
