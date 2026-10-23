export const rupiah = (n: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(n || 0)

export const COUNTED = ['dikonfirmasi', 'diproses', 'dikirim', 'selesai']
export const STATUSES = ['baru', 'dikonfirmasi', 'diproses', 'dikirim', 'selesai', 'dibatalkan']

export const localDate = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`

export const daysAgo = (n: number) => localDate(new Date(Date.now() - n * 864e5))

export const slugify = (s: string) =>
  s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')

export const toLocalInput = (iso: string) => {
  const d = new Date(iso)
  const p = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}T${p(d.getHours())}:${p(d.getMinutes())}`
}

export const fmtDateTime = (iso: string) =>
  iso ? new Date(iso).toLocaleString('id-ID', { dateStyle: 'medium', timeStyle: 'short' }) : '-'

export const downloadCsv = (name: string, rows: any[][]) => {
  const esc = (v: any) => `"${String(v ?? '').replace(/"/g, '""')}"`
  const blob = new Blob(['\ufeff' + rows.map((r) => r.map(esc).join(',')).join('\n')], { type: 'text/csv;charset=utf-8' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob)
  a.download = name
  a.click()
  URL.revokeObjectURL(a.href)
}

export const statusTone = (s: string) => ({ baru: 'amber', dikonfirmasi: 'blue', diproses: 'blue', dikirim: 'blue', selesai: 'green', dibatalkan: 'red' } as Record<string, string>)[s] || ''