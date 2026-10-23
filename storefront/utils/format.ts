export const rupiah = (n: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(n || 0)

export const sanitize = (html: string) => {
  if (!html) return ''
  const allowed = ['B', 'I', 'U', 'STRONG', 'EM', 'UL', 'OL', 'LI', 'A', 'P', 'BR', 'DIV', 'SPAN']
  const doc = new DOMParser().parseFromString(html, 'text/html')
  const clean = (node: Element) => {
    Array.from(node.children).forEach((el: Element) => {
      clean(el)
      if (!allowed.includes(el.tagName)) {
        el.replaceWith(...Array.from(el.childNodes))
        return
      }
      Array.from(el.attributes).forEach((a) => {
        if (!(el.tagName === 'A' && a.name === 'href')) el.removeAttribute(a.name)
      })
      if (el.tagName === 'A') {
        const href = el.getAttribute('href') || ''
        if (!/^(https?:|mailto:|tel:)/i.test(href)) el.removeAttribute('href')
        else {
          el.setAttribute('target', '_blank')
          el.setAttribute('rel', 'noopener noreferrer')
        }
      }
    })
  }
  clean(doc.body)
  return doc.body.innerHTML
}

export const PRODUCT_SELECT =
  '*, categories(name,slug), product_images(url,sort_order), product_variants(*), product_label_assignments(product_labels(*))'

export const normalizeProduct = (p: any) => {
  const variants = (p.product_variants || []).filter((v: any) => v.is_active).sort((a: any, b: any) => a.sort_order - b.sort_order)
  const labels = (p.product_label_assignments || [])
    .map((a: any) => a.product_labels)
    .filter((l: any) => l && l.is_active)
    .sort((a: any, b: any) => a.sort_order - b.sort_order)
  const stock = variants.length ? variants.reduce((s: number, v: any) => s + v.stock, 0) : p.stock
  const prices = variants.length ? variants.map((v: any) => v.price ?? p.price) : [p.price]
  const gallery = (p.product_images || []).sort((a: any, b: any) => a.sort_order - b.sort_order).map((i: any) => i.url)
  const images = [p.image_url, ...gallery].filter(Boolean)
  return { ...p, variants, labels, stock, images, minPrice: Math.min(...prices) }
}

export const availability = (p: any) => {
  if (p.po_status === 'po') return { text: 'Pre-Order', ok: true }
  if (p.po_status === 'closed') return { text: 'PO Ditutup', ok: false }
  return p.stock > 0 ? { text: 'Ready Stock', ok: true } : { text: 'Habis', ok: false }
}

export const waLink = (number: string, template: string, vars: Record<string, string>) => {
  const text = Object.entries(vars).reduce((t, [k, v]) => t.split(`{${k}}`).join(v), template || 'Halo kak, aku mau pesan {produk} varian {varian} harga {harga}')
  return `https://wa.me/${String(number).replace(/\D/g, '')}?text=${encodeURIComponent(text)}`
}

export const soldText = (n: number) =>
  n >= 1000 ? `${new Intl.NumberFormat('id-ID', { maximumFractionDigits: 1 }).format(n / 1000)}rb Terjual` : `${n} Terjual`