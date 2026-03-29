# Chunking Strategies

## Character-Based (default, simplest)
Split every N characters with overlap. Fast, no dependencies.

```python
def chunk_text(text: str, size: int = 1024, overlap: int = 128) -> list[str]:
    chunks, start = [], 0
    while start < len(text):
        chunks.append(text[start:start + size])
        start += size - overlap
    return chunks
```

Good for: homogeneous prose, quick prototyping.

## Sentence-Based
Respect sentence boundaries. Better coherence for dense text.

```python
import re

def chunk_by_sentences(text: str, max_chars: int = 1024) -> list[str]:
    sentences = re.split(r'(?<=[.!?])\s+', text)
    chunks, current = [], ""
    for sentence in sentences:
        if len(current) + len(sentence) > max_chars and current:
            chunks.append(current.strip())
            current = sentence
        else:
            current += " " + sentence
    if current:
        chunks.append(current.strip())
    return chunks
```

Good for: articles, reports, documentation.

## Paragraph-Based
Split on blank lines. Preserves semantic units.

```python
def chunk_by_paragraphs(text: str, max_chars: int = 2048) -> list[str]:
    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    chunks, current = [], ""
    for para in paragraphs:
        if len(current) + len(para) > max_chars and current:
            chunks.append(current.strip())
            current = para
        else:
            current += "\n\n" + para
    if current:
        chunks.append(current.strip())
    return chunks
```

Good for: structured documents, markdown files, wikis.

## Code (Function-Level)
Use language parsers to split at function/class boundaries.

```python
import ast, textwrap

def chunk_python_functions(source: str) -> list[str]:
    tree = ast.parse(source)
    chunks = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            start = node.lineno - 1
            end = node.end_lineno
            lines = source.splitlines()[start:end]
            chunks.append(textwrap.dedent("\n".join(lines)))
    return chunks
```

Good for: code search, code review, Codestral embedding.

## Chunk Size Guidelines

| Content | Chunk size | Overlap |
|---|---|---|
| Short Q&A / FAQs | Full document | None |
| Prose / blog posts | 512–1024 chars | 10–15% |
| Technical manuals | 1024–2048 chars | 10% |
| Source code | Per function/class | None |
| OCR output (PDFs) | Per page or 2048 chars | 128 chars |
