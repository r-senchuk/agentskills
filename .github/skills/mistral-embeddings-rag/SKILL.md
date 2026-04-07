---
name: mistral-embeddings-rag
description: "Use when you need to build a retrieval-augmented generation (RAG) pipeline with Mistral embeddings: chunking strategy, embedding text or code, vector storage, similarity search, and grounding LLM answers in retrieved context. Use when user asks to 'build RAG pipeline', 'set up document retrieval', 'create semantic search', or 'ground LLM answers in documents'. Do NOT use for plain chat completions, fine-tuning, or tasks solvable from model knowledge without document retrieval."
argument-hint: "Document source (file path, URL, or raw text), chunk size preference, vector store choice (faiss/in-memory/external), and query or question to answer"
user-invocable: false
license: MIT
compatibility: "Requires Python 3.9+, Mistral embeddings API access, and optional vector stores (FAISS, Pinecone, Qdrant, etc.)."
metadata:
  author: "Roman Senchuk"
  version: "1.1.0"
  last-updated: "2024-07-15"
---

# Mistral Embeddings & RAG

End-to-end workflow for building retrieval-augmented generation pipelines using Mistral's embeddings API. Covers document ingestion, chunking, embedding, vector storage, retrieval, and grounded generation.

## When To Use
- You need an LLM to answer questions about documents it was not trained on.
- You are building semantic search over a codebase, knowledge base, or document corpus.
- You need to cluster, classify, or find duplicates in large text datasets.
- You want to ground model responses in specific source material and reduce hallucinations.

**Do NOT use for:**
- General chat completions or prompt engineering without document retrieval.
- Fine-tuning or training Mistral models.
- Tasks fully solvable from the model's parametric knowledge (no external documents needed).

## Inputs To Collect First
1. Document source: file paths, URLs, or raw text strings to index.
2. Embedding model: `mistral-embed` (general text) or `codestral-embed` (code).
3. Chunk strategy: size in characters/tokens and overlap.
4. Vector store: `faiss` (local, zero-dependency), or an external store (Pinecone, Qdrant, etc.).
5. Query: the question or search term to answer from the indexed content.
6. Generation model: which Mistral model to use for the final answer.

## Procedure

### Step 1 — Ingest and Chunk Documents

Split before embedding — chunk size directly impacts retrieval quality.

```python
def chunk_text(text: str, chunk_size: int = 1024, overlap: int = 128) -> list[str]:
    """Character-based chunking with overlap."""
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        start += chunk_size - overlap
    return chunks
```

Chunking guidance:

| Content type | Recommended chunk size | Split boundary |
|---|---|---|
| Prose / articles | 512–1024 chars | Sentence or paragraph |
| Technical docs | 1024–2048 chars | Section heading |
| Source code | Function/class | AST node boundary |
| Short Q&A pairs | Full pair | Document boundary |

Overlap of 10–15% of chunk size reduces context loss at boundaries.

### Step 2 — Generate Embeddings

```python
import os
from mistralai import Mistral

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])

def embed_batch(texts: list[str], model: str = "mistral-embed") -> list[list[float]]:
    """Embed a list of texts, respecting API batch limits."""
    BATCH_SIZE = 64  # stay well under rate limits
    all_embeddings = []
    for i in range(0, len(texts), BATCH_SIZE):
        batch = texts[i : i + BATCH_SIZE]
        response = client.embeddings.create(model=model, inputs=batch)
        all_embeddings.extend([e.embedding for e in response.data])
    return all_embeddings
```

Models:
- `mistral-embed` — general-purpose text; 1024-dimensional output.
- `codestral-embed` — optimized for source code retrieval.

Embed the **query** with the same model used for indexing.

### Step 3 — Store in a Vector Index (Faiss)

```python
import numpy as np
import faiss

def build_faiss_index(embeddings: list[list[float]]) -> faiss.IndexFlatL2:
    matrix = np.array(embeddings, dtype="float32")
    dim = matrix.shape[1]
    index = faiss.IndexFlatL2(dim)  # L2 distance; use IndexFlatIP for cosine
    index.add(matrix)
    return index
```

For cosine similarity (often preferred for semantic search), normalize vectors before `IndexFlatIP`:

```python
faiss.normalize_L2(matrix)
index = faiss.IndexFlatIP(dim)
index.add(matrix)
```

### Step 4 — Retrieve Relevant Chunks

```python
def retrieve(
    query: str,
    chunks: list[str],
    index: faiss.IndexFlatL2,
    model: str = "mistral-embed",
    top_k: int = 5,
) -> list[str]:
    query_embedding = embed_batch([query], model=model)[0]
    q_vec = np.array([query_embedding], dtype="float32")
    _, indices = index.search(q_vec, top_k)
    return [chunks[i] for i in indices[0] if i < len(chunks)]
```

Retrieval tips:
- `top_k=5` is a good default; increase for broad questions, decrease for precision.
- Include the source document name/page in each chunk's metadata for citations.
- Re-rank retrieved chunks with a cross-encoder if precision is critical.

### Step 5 — Generate a Grounded Answer

```python
def rag_answer(
    query: str,
    retrieved_chunks: list[str],
    model: str = "mistral-large-latest",
) -> str:
    context = "\n\n---\n\n".join(retrieved_chunks)
    messages = [
        {
            "role": "system",
            "content": (
                "Answer the question using ONLY the provided context. "
                "If the answer is not in the context, say so explicitly."
            ),
        },
        {
            "role": "user",
            "content": f"Context:\n{context}\n\nQuestion: {query}",
        },
    ]
    response = client.chat.complete(model=model, messages=messages)
    return response.choices[0].message.content
```

### Full Pipeline Example

```python
# 1. Load and chunk
raw_text = open("knowledge_base.txt").read()
chunks = chunk_text(raw_text, chunk_size=1024, overlap=128)

# 2. Embed
embeddings = embed_batch(chunks)

# 3. Index
index = build_faiss_index(embeddings)

# 4. Retrieve
relevant = retrieve("What is Mistral's approach to safety?", chunks, index)

# 5. Answer
answer = rag_answer("What is Mistral's approach to safety?", relevant)
print(answer)
```

## Completion Checks
- [ ] Chunks and query use the same embedding model.
- [ ] Chunk size and overlap tuned for the content type (not left at defaults).
- [ ] Vector store populated before any retrieval call.
- [ ] Retrieved context fits within the generation model's context window.
- [ ] Generation prompt instructs the model to stay grounded in context.
- [ ] Tested with an in-context question (answers correctly) and an out-of-context question (says it doesn't know).

## References
- [Chunking strategy guide](./references/chunking-strategies.md)
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
