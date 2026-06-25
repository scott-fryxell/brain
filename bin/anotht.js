#!/usr/bin/env node
import { execSync } from 'child_process'
import { dirname, resolve } from 'path'
import { fileURLToPath } from 'url'

const project_root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
execSync('./bin/pi', { cwd: project_root, stdio: 'inherit' })
