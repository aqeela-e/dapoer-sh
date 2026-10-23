import { existsSync, copyFileSync } from 'node:fs'

if (existsSync('.env')) {
  for (const dir of ['storefront', 'admin']) copyFileSync('.env', `${dir}/.env`)
}
