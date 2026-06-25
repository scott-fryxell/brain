#!/usr/bin/env node
/**
 * Summarize Vitest/Istanbul V8 coverage for gap analysis.
 * Reads coverage/coverage-final.json (from npm run test:coverage).
 *
 * Usage (from project root):
 *   node path/to/summarize-coverage.js
 *   node path/to/summarize-coverage.js --threshold 80 --top 25
 */

import { existsSync } from 'node:fs'
import { join } from 'node:path'
import { load_coverage_by_src } from './lib/coverage-metrics.js'

const args = process.argv.slice(2)
const get_arg = (flag, fallback) => {
  const i = args.indexOf(flag)
  if (i === -1) return fallback
  return args[i + 1] ?? fallback
}

const project_root = get_arg('--root', process.cwd())
const threshold = Number(get_arg('--threshold', '80'))
const top_n = Number(get_arg('--top', '30'))
const coverage_dir = join(project_root, 'coverage')

const by_src = load_coverage_by_src(project_root)

if (!by_src?.size) {
  console.error(`Missing ${join(coverage_dir, 'coverage-final.json')}`)
  console.error('Run: npm run test:coverage')
  process.exit(1)
}

/** @type {{ path: string, pct: number, statements: object, branches: object, functions: object, lines: object }[]} */
const files = [...by_src.entries()].map(([path, m]) => ({
  path,
  pct: m.pct,
  statements: m.statements,
  branches: m.branches,
  functions: m.functions,
  lines: m.lines
}))

files.sort((a, b) => a.pct - b.pct)

const below = files.filter(f => f.pct < threshold)

console.log('# Coverage summary')
console.log('')
console.log(`- Project: ${project_root}`)
console.log(`- Threshold: ${threshold}% (min of stmt/branch/fn/line per file)`)
console.log(`- Files under src/: ${files.length}`)
console.log(`- Below threshold: ${below.length}`)
console.log(`- HTML report: ${join(coverage_dir, 'index.html')}`)
console.log('')
console.log(
  '- Combined with fallow: `npm run test:risk` or see skills/test-coverage/references/fallow-integration.md'
)
console.log('')

if (below.length === 0) {
  console.log('All tracked src files meet the threshold.')
  process.exit(0)
}

console.log('## Lowest coverage (prioritize review)')
console.log('')
console.log('| file | % | stmt | branch | fn | line |')
console.log('| --- | ---: | ---: | ---: | ---: | ---: |')

for (const f of below.slice(0, top_n)) {
  const fmt = m => `${m.pct.toFixed(0)}`
  console.log(
    `| ${f.path} | ${f.pct.toFixed(0)} | ${fmt(f.statements)} | ${fmt(f.branches)} | ${fmt(f.functions)} | ${fmt(f.lines)} |`
  )
}

if (below.length > top_n)
  console.log(`\n… and ${below.length - top_n} more below threshold.`)
