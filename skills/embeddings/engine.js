import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const DATA_DIR = resolve(__dirname, 'data')

const OLLAMA_URL = 'http://localhost:11434/api/embed'
const MODEL = 'nomic-embed-text'

if (!existsSync(DATA_DIR)) mkdirSync(DATA_DIR, { recursive: true })

/** @param {string} text */
export async function embed(text) {
  const res = await fetch(OLLAMA_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ model: MODEL, input: text })
  })
  const data = await res.json()
  return data.embeddings[0]
}

/** @param {number[]} a @param {number[]} b */
export function cosine_similarity(a, b) {
  let dot = 0, mag_a = 0, mag_b = 0
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i]
    mag_a += a[i] * a[i]
    mag_b += b[i] * b[i]
  }
  return dot / (Math.sqrt(mag_a) * Math.sqrt(mag_b))
}

/**
 * @param {string} source
 * @returns {Array<{id: string, text: string, source: string, vec: number[]}>}
 */
export function load_store(source) {
  const file = resolve(DATA_DIR, `${source}.jsonl`)
  if (!existsSync(file)) return []
  return readFileSync(file, 'utf-8')
    .split('\n')
    .filter(Boolean)
    .map(line => JSON.parse(line))
}

/** @param {string} source @param {Array<{id: string, text: string, source: string, vec: number[]}>} items */
export function save_store(source, items) {
  const file = resolve(DATA_DIR, `${source}.jsonl`)
  const content = items.map(item => JSON.stringify(item)).join('\n')
  writeFileSync(file, content + '\n')
}

/** @param {string} source @param {{id: string, text: string, vec: number[]}} item */
export function append_store(source, item) {
  const file = resolve(DATA_DIR, `${source}.jsonl`)
  const line = JSON.stringify({ ...item, source }) + '\n'
  if (existsSync(file)) {
    const fd = await import('fs').then(fs => fs.openSync(file, 'a'))
    const fs = await import('fs')
    fs.writeSync(fd, line)
    fs.closeSync(fd)
  } else {
    writeFileSync(file, line)
  }
}

/**
 * @param {number[]} query_vec
 * @param {string[]} sources — which stores to search
 * @param {number} top_k
 */
export function query(query_vec, sources, top_k = 10) {
  const results = []
  for (const source of sources) {
    for (const item of load_store(source)) {
      results.push({
        id: item.id,
        source: item.source,
        text: item.text,
        score: cosine_similarity(query_vec, item.vec)
      })
    }
  }
  results.sort((a, b) => b.score - a.score)
  return results.slice(0, top_k)
}
