insert into categories(name, slug, sort_order) values
('Es Krim Cup', 'es-krim-cup', 1),
('Pint', 'pint', 2),
('Sundae Box', 'sundae-box', 3);

insert into product_labels(name, color, sort_order) values
('BEST SELLER', '#ff4f7b', 1),
('SECRET MENU', '#2a1b4d', 2),
('NEW FLAVOR', '#19b394', 3),
('MOST LOVED', '#e8590c', 4),
('LIMITED EDITION', '#7048e8', 5),
('NEXT PO', '#f59f00', 6);

insert into products(name, slug, description, category_id, price, stock, is_published, po_status, is_featured, sort_order, shipping_estimate, storage_info)
select v.name, v.slug, v.description, c.id, v.price, v.stock, true, v.po, v.feat, v.ord,
  'Dikirim 1-2 hari setelah PO ditutup', 'Simpan di freezer, jangan dicairkan ulang'
from (values
  ('Strawberry Cloud', 'strawberry-cloud', 'Es krim stroberi lembut dengan potongan buah asli.', 28000, 0, 'ready', true, 1, 'Es Krim Cup'),
  ('Choco Lava Dream', 'choco-lava-dream', 'Cokelat pekat dengan pusaran saus cokelat leleh.', 30000, 18, 'ready', true, 2, 'Es Krim Cup'),
  ('Matcha Latte Swirl', 'matcha-latte-swirl', 'Matcha creamy dengan sentuhan susu hangat.', 32000, 0, 'po', true, 3, 'Es Krim Cup'),
  ('Salted Caramel Crunch', 'salted-caramel-crunch', 'Karamel asin dengan remahan biskuit renyah.', 68000, 12, 'ready', false, 4, 'Pint'),
  ('Gabin Rahasia', 'gabin-rahasia', 'Rasa kejutan yang hanya diketahui pelanggan setia.', 35000, 9, 'ready', false, 5, 'Sundae Box'),
  ('Mango Sunshine', 'mango-sunshine', 'Mangga segar yang manis dan menyegarkan.', 29000, 0, 'closed', false, 6, 'Es Krim Cup')
) as v(name, slug, description, price, stock, po, feat, ord, cat)
join categories c on c.name = v.cat;

insert into product_label_assignments(product_id, label_id)
select p.id, l.id
from (values
  ('strawberry-cloud', 'BEST SELLER'),
  ('choco-lava-dream', 'MOST LOVED'),
  ('matcha-latte-swirl', 'NEW FLAVOR'),
  ('matcha-latte-swirl', 'NEXT PO'),
  ('gabin-rahasia', 'SECRET MENU'),
  ('salted-caramel-crunch', 'LIMITED EDITION')
) as v(slug, label)
join products p on p.slug = v.slug
join product_labels l on l.name = v.label;

insert into product_variants(product_id, name, price, stock, sort_order)
select p.id, v.name, v.price, v.stock, v.ord
from (values
  ('strawberry-cloud', 'Cup 120ml', 28000, 14, 1),
  ('strawberry-cloud', 'Cup 240ml', 48000, 8, 2),
  ('choco-lava-dream', 'Cup 120ml', 30000, 10, 1),
  ('choco-lava-dream', 'Cup 240ml', 52000, 8, 2)
) as v(slug, name, price, stock, ord)
join products p on p.slug = v.slug;

update products set stock = 0 where slug in ('strawberry-cloud', 'choco-lava-dream');

insert into faq_categories(name, sort_order) values
('Pemesanan dan Pre-Order', 1),
('Pembayaran', 2),
('Pengiriman', 3),
('Penyimpanan Produk', 4),
('Produk dan Varian', 5),
('Komplain dan Kontak', 6);

insert into faqs(category_id, question, answer, show_on_home, sort_order)
select c.id, v.q, v.a, v.home, v.ord
from (values
  ('Pemesanan dan Pre-Order', 'Kapan jadwal PO berikutnya?', '<p>Jadwal PO terbaru selalu kami umumkan di halaman <b>Next PO</b> dan WhatsApp Channel.</p>', true, 1),
  ('Pemesanan dan Pre-Order', 'Bagaimana cara memesan?', '<ol><li>Pilih produk dan varian.</li><li>Klik tombol pesan lewat WhatsApp.</li><li>Kirim pesan otomatis ke admin dan tunggu konfirmasi.</li></ol>', true, 2),
  ('Pembayaran', 'Metode pembayaran apa yang tersedia?', '<p>Metode pembayaran dikonfirmasi langsung oleh admin saat pesananmu diproses lewat WhatsApp.</p>', false, 3),
  ('Pengiriman', 'Pengiriman dilakukan ke mana saja?', '<p>Area dan opsi pengiriman dikonfirmasi admin sesuai alamatmu. Tanyakan lewat WhatsApp sebelum memesan.</p>', true, 4),
  ('Penyimpanan Produk', 'Bagaimana cara menyimpan es krim?', '<p>Langsung simpan di freezer begitu diterima dan hindari mencairkannya berulang kali.</p>', true, 5),
  ('Produk dan Varian', 'Apakah semua rasa selalu tersedia?', '<p>Ketersediaan mengikuti stok dan jadwal PO. Cek status di halaman produk.</p>', false, 6),
  ('Komplain dan Kontak', 'Bagaimana jika pesananku bermasalah?', '<p>Hubungi admin lewat WhatsApp dengan menyertakan kode pesanan dan foto produk agar cepat dibantu.</p>', false, 7)
) as v(cat, q, a, home, ord)
join faq_categories c on c.name = v.cat;

insert into whatsapp_settings(id, number_primary, label_primary, number_secondary, label_secondary, channel_url)
values (1, '6281234567890', 'Admin Gabin 1', '6281234567891', 'Admin Gabin 2', 'https://whatsapp.com/channel/');

insert into site_settings(key, value) values
('hero_intro', 'Es krim handmade dengan rasa yang bikin senyum. Pilih rasa, pesan lewat WhatsApp, kami kirim sampai pintu.'),
('about_story', '<p>Gabin Ice Cream lahir dari dapur kecil dengan satu keyakinan: es krim enak dibuat dari bahan yang jujur dan dibuat dengan sabar.</p><p>Setiap batch dibuat terbatas agar rasanya selalu segar.</p>'),
('storage_info', 'Simpan di freezer, jangan dicairkan ulang.'),
('contact_hours', 'Setiap hari, 09.00 - 20.00 WIB'),
('shipping_info', 'Pengiriman mengikuti jadwal PO. Detail ongkir dikonfirmasi admin.'),
('instagram_url', ''),
('tiktok_url', '');

insert into testimonials(name, content, rating, sort_order) values
('Nadia', 'Teksturnya lembut banget dan manisnya pas. Langsung pesan lagi.', 5, 1),
('Rafi', 'Packing rapi, es krim sampai masih beku sempurna.', 5, 2),
('Salsa', 'Matcha-nya wangi dan tidak pahit. Favorit keluarga.', 5, 3);

insert into announcements(title, body, placement, is_po, po_open, po_start, po_end, delivery_estimate, cta_label, cta_url) values
('PO Batch Berikutnya', '<p>Pesan lebih awal supaya rasa favoritmu tidak kehabisan.</p>', 'home', true, true, current_date + 3, current_date + 10, '2 hari setelah PO ditutup', 'Pesan lewat WhatsApp', null);
