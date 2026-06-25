import { readdirSync, readFileSync } from 'fs'
import { resolve } from 'path'
import { embed, save_store } from './engine.js'

const VAULT = resolve(
  process.env.HOME,
  'Library/Mobile Documents/iCloud~md~obsidian/Documents/Anotht'
)
const SMART_ENV = resolve(VAULT, '.smart-env/multi')

function load_smart_connections() {
  const items = []
  for (const file of readdirSync(SMART_ENV)) {
    if (!file.endsWith('.ajson')) continue
    const raw = readFileSync(resolve(SMART_ENV, file), 'utf-8')
    for (const line of raw.split('\n').filter(Boolean)) {
      const entry = JSON.parse(line)
      const key = Object.keys(entry)[0]
      const data = entry[key]
      if (!data.embeddings?.['TaylorAI/bge-micro-v2']?.vec) continue
      if (data.class_name !== 'SmartSource') continue
      items.push({
        id: `vault::${data.path}`,
        text: data.path,
        source: 'vault',
        vec: data.embeddings['TaylorAI/bge-micro-v2'].vec
      })
    }
  }
  return items
}

async function ingest_with_ollama() {
  const items = []
  const sections = ['01 Projects', '02 Areas', '03 Resources']
  for (const section of sections) {
    const section_path = resolve(VAULT, section)
    for (const entry of walk_md_files(section_path)) {
      const content = readFileSync(entry, 'utf-8').slice(0, 2000)
      const rel = entry.replace(VAULT + '/', '')
      const vec = await embed(content)
      items.push({ id: `vault::${rel}`, text: rel, source: 'vault', vec })
      console.log(`embedded: ${rel}`)
    }
  }
  return items
}

function walk_md_files(dir) {
  const results = []
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = resolve(dir, entry.name)
    if (entry.isDirectory()) results.push(...walk_md_files(full))
    else if (entry.name.endsWith('.md')) results.push(full)
  }
  return results
}

const use_smart = process.argv.includes('--smart')

if (use_smart) {
  console.log('Loading existing Smart Connections embeddings...')
  const items = load_smart_connections()
  save_store('vault', items)
  console.log(`Stored ${items.length} vault embeddings`)
} else {
  console.log('Embedding vault with Ollama (nomic-embed-text)...')
  const items = await ingest_with_ollama()
  save_store('vault', items)
  console.log(`Stored ${items.length} vault embeddings`)
}
