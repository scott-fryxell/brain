# Embeddings Engine

Personal vector store that embeds content from any source and finds connections across them.

## Usage

```bash
./ingest.sh vault          # embed obsidian vault notes
./ingest.sh music          # embed last.fm / youtube music history
./ingest.sh project <path> # embed a work project's docs and code
./query.sh "event description or any text"  # find similar items across all sources
```

## Architecture

```
Sources                    Engine                    Output
─────────────────          ──────────────            ──────────────
Obsidian vault    ──┐                                
last.fm history   ──┼──▶  embed ──▶ store  ──▶      similarity scores
YouTube Music     ──┤      (ollama)  (.jsonl)        ranked by source
Work projects     ──┘                                
Event listings    ──────▶  embed ──▶ compare ──▶     "relevant to you?"
```

## Provider

Uses Ollama locally with `nomic-embed-text` (768 dims, runs on Apple Silicon).

```bash
ollama pull nomic-embed-text
```

Can also read existing Smart Connections embeddings from the vault
(`bge-micro-v2`, 384 dims) — no re-embedding needed for vault notes.

## Store Format

One `.jsonl` file per source in `data/`:

```json
{"id": "vault::02 Areas/Music/Cowpunk", "text": "Cowpunk - Wikipedia", "source": "vault", "vec": [...]}
{"id": "music::artist::Siouxsie and the Banshees", "text": "post-punk, goth rock", "source": "music", "vec": [...]}
{"id": "project::realness::src/app.js", "text": "...", "source": "project:realness", "vec": [...]}
```
