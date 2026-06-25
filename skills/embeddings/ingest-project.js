import { readdirSync, readFileSync } from 'fs'
import { resolve, extname } from 'path'
import { embed, save_store } from './engine.js'

const CODE_EXTENSIONS = new Set([
  '.js', '.ts', '.jsx', '.tsx', '.py', '.rs',
  '.md', '.json', '.css', '.html', '.vue', '.svelte'
])

const IGNORE = new Set(['node_modules', '.git', 'dist', 'build', '.smart-env'])

function walk_files(dir) {
  const results = []
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (IGNORE.has(entry.name)) continue
    const full = resolve(dir, entry.name)
    if (entry.isDirectory()) results.push(...walk_files(full))
    else if (CODE_EXTENSIONS.has(extname(entry.name))) results.push(full)
  }
  return results
}

async function main() {
  const project_path = process.argv[2]
  if (!project_path) {
    console.log('Usage: node ingest-project.js <path-to-project>')
    process.exit(1)
  }

  const abs_path = resolve(project_path)
  const project_name = abs_path.split('/').pop()
  const files = walk_files(abs_path)
  const items = []

  for (const file of files) {
    const content = readFileSync(file, 'utf-8').slice(0, 2000)
    const rel = file.replace(abs_path + '/', '')
    const vec = await embed(`${project_name}/${rel}\n${content}`)
    items.push({
      id: `project::${project_name}::${rel}`,
      text: `${project_name}/${rel}`,
      source: `project:${project_name}`,
      vec
    })
    console.log(`embedded: ${project_name}/${rel}`)
  }

  save_store(`project-${project_name}`, items)
  console.log(`Stored ${items.length} embeddings for ${project_name}`)
}

main()
