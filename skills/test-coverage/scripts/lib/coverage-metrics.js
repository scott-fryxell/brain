import { readFileSync, existsSync } from 'node:fs'
import { join, relative } from 'node:path'

/**
 * @param {Record<string, number | number[]>} hits
 * @returns {{ covered: number, total: number, pct: number }}
 */
export const metric = hits => {
  let covered = 0
  let total = 0
  for (const v of Object.values(hits || {})) {
    if (Array.isArray(v)) {
      for (const n of v) {
        total++
        if (n > 0) covered++
      }
    } else {
      total++
      if (v > 0) covered++
    }
  }
  const pct = total ? (covered / total) * 100 : 100
  return { covered, total, pct }
}

/** @param {import('istanbul-lib-coverage').FileCoverageData} file */
export const file_metrics = file => {
  const statements = metric(file.s || {})
  const branches = metric(file.b || {})
  const functions = metric(file.f || {})
  const lines = metric(file.l || file.s || {})
  const pct = Math.min(statements.pct, branches.pct, functions.pct, lines.pct)
  return { statements, branches, functions, lines, pct }
}

/**
 * @param {string} project_root
 * @returns {Map<string, { pct: number, statements: object, branches: object, functions: object, lines: object }>}
 */
export const load_coverage_by_src = project_root => {
  const json_path = join(project_root, 'coverage', 'coverage-final.json')
  if (!existsSync(json_path)) return null

  /** @type {Record<string, import('istanbul-lib-coverage').FileCoverageData>} */
  const raw = JSON.parse(readFileSync(json_path, 'utf8'))
  /** @type {Map<string, object>} */
  const by_src = new Map()

  for (const abs_path of Object.keys(raw)) {
    const rel = relative(project_root, abs_path).replace(/\\/g, '/')
    if (!rel.startsWith('src/')) continue
    const m = file_metrics(raw[abs_path])
    by_src.set(rel, {
      pct: m.pct,
      statements: m.statements,
      branches: m.branches,
      functions: m.functions,
      lines: m.lines
    })
  }

  return by_src
}
