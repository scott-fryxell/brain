import { readdirSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { embed, query } from './engine.js'

const __dirname = dirname(fileURLToPath(import.meta.url))
const DATA_DIR = resolve(__dirname, 'data')

const input = process.argv.slice(2).join(' ')
if (!input) {
  console.log('Usage: node query.js "some text to find similar items for"')
  process.exit(1)
}

const sources = readdirSync(DATA_DIR)
  .filter(f => f.endsWith('.jsonl'))
  .map(f => f.replace('.jsonl', ''))

const query_vec = await embed(input)
const results = query(query_vec, sources, 15)

console.log(`\nTop matches for: "${input}"\n`)
for (const r of results) {
  const score = (r.score * 100).toFixed(1)
  console.log(`  ${score}%  [${r.source}]  ${r.text}`)
}
