# Best Models for Telecom Test Case Matching

## Goal
Match ~3000 vs ~3000 telecom carrier test cases (Verizon, T-Mobile, etc.) and identify:
- Strong 1:1 matches
- Likely matches
- Possible 1:N / N:1 mappings
- No clear match

---

## Recommended Local Stack (A4000 16GB GPU)

### Embedding Models

#### 1. BGE-M3
**Use as primary embedding model**
- Strong semantic retrieval
- Good with technical keywords and acronyms
- Supports hybrid retrieval patterns

```bash
ollama pull bge-m3
```

#### 2. Qwen3 Embedding
**Modern alternative**
- Strong benchmark performance
- Good multilingual/general retrieval

```bash
ollama pull qwen3-embedding
```

---

### Reranker Models

#### 3. Qwen3 Reranker 0.6B
**Best balance of speed + quality**
- Good for production use
- Light enough for continuous local serving

```bash
ollama pull dengcao/Qwen3-Reranker-0.6B
```

#### 4. Qwen3 Reranker 4B
**Higher quality / slower**
- Use for harder ambiguous matches
- Better reasoning than smaller models

```bash
ollama pull dengcao/Qwen3-Reranker-4B
```

#### 5. BGE Reranker Base
**Solid fallback option**
- Efficient cross-encoder style reranking

```bash
ollama pull bbjson/bge-reranker-base
```

---

## Best Configurations

### Recommended Starter Stack
```text
Embedding: bge-m3
Reranker: Qwen3-Reranker-0.6B
```

### Higher Accuracy Stack
```text
Embedding: qwen3-embedding
Reranker: Qwen3-Reranker-4B
```

### Cost Efficient Stack
```text
Embedding: bge-m3
Reranker: bge-reranker-base
```

---

## Suggested Matching Pipeline
1. Embed all test cases
2. Retrieve top 50 candidates using vector search
3. Add BM25 keyword search candidates
4. Merge candidates
5. Rerank candidates
6. Output confidence buckets:
   - Strong Match
   - Likely Match
   - Needs Review
   - No Match

---

## Practical Advice
Do not chase huge models first.
For telecom data, acronyms + structured wording often means retrieval quality matters as much as model size.

Start simple, benchmark on 100 labeled examples, then upgrade only if needed.

---

## Single Pull Command
```bash
ollama pull bge-m3 && \
ollama pull qwen3-embedding && \
ollama pull dengcao/Qwen3-Reranker-0.6B && \
ollama pull dengcao/Qwen3-Reranker-4B && \
ollama pull bbjson/bge-reranker-base
```

