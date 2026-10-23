create extension if not exists pgcrypto;

create table admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create function is_admin() returns boolean language sql security definer stable set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid())
$$;

create function handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from admins) then
    insert into admins(user_id) values (new.id);
  end if;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

create function touch_updated_at() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table product_labels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  color text not null default '#ff4f7b',
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  image_url text,
  category_id uuid references categories(id) on delete set null,
  price numeric(12,2) not null default 0 check (price >= 0),
  stock int not null default 0 check (stock >= 0),
  is_published boolean not null default false,
  is_archived boolean not null default false,
  is_featured boolean not null default false,
  po_status text not null default 'ready' check (po_status in ('ready','po','closed')),
  sort_order int not null default 0,
  shipping_estimate text,
  storage_info text,
  notes text,
  historical_sold int not null default 0 check (historical_sold >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index products_category_idx on products(category_id);
create index products_public_idx on products(is_published, is_archived, sort_order);
create trigger products_touch before update on products for each row execute function touch_updated_at();

create table product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  url text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);
create index product_images_product_idx on product_images(product_id);

create table product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  name text not null,
  price numeric(12,2) check (price >= 0),
  stock int not null default 0 check (stock >= 0),
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);
create index product_variants_product_idx on product_variants(product_id);

create table product_label_assignments (
  product_id uuid not null references products(id) on delete cascade,
  label_id uuid not null references product_labels(id) on delete cascade,
  primary key (product_id, label_id)
);

create table faq_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table faqs (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references faq_categories(id) on delete set null,
  question text not null,
  answer text not null,
  is_active boolean not null default true,
  show_on_home boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index faqs_public_idx on faqs(is_active, sort_order);
create trigger faqs_touch before update on faqs for each row execute function touch_updated_at();

create table announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text,
  image_url text,
  placement text not null default 'home' check (placement in ('home','popup')),
  is_po boolean not null default false,
  po_open boolean not null default true,
  po_start date,
  po_end date,
  delivery_estimate text,
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  is_active boolean not null default true,
  cta_label text,
  cta_url text,
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at > starts_at),
  check (po_end is null or po_start is null or po_end >= po_start)
);

create table banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  image_url text,
  cta_label text,
  cta_url text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table testimonials (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  content text not null,
  rating int not null default 5 check (rating between 1 and 5),
  image_url text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table site_settings (
  key text primary key,
  value text,
  updated_at timestamptz not null default now()
);

create table whatsapp_settings (
  id int primary key default 1 check (id = 1),
  label_primary text not null default 'Admin 1',
  number_primary text not null default '',
  label_secondary text not null default 'Admin 2',
  number_secondary text not null default '',
  channel_url text,
  message_template text not null default 'Halo kak, aku mau pesan {produk} varian {varian} harga {harga}',
  fallback_message text not null default 'Kalau admin pertama belum membalas, coba hubungi admin kedua ya.',
  updated_at timestamptz not null default now()
);
create trigger whatsapp_touch before update on whatsapp_settings for each row execute function touch_updated_at();

create sequence trx_seq;

create table transactions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique default ('GBN-' || to_char(now(), 'YYMMDD') || '-' || lpad(nextval('trx_seq')::text, 4, '0')),
  trx_date date not null default current_date,
  customer_name text not null,
  customer_contact text,
  status text not null default 'baru' check (status in ('baru','dikonfirmasi','diproses','dikirim','selesai','dibatalkan')),
  source text not null default 'WhatsApp',
  subtotal numeric(14,2) not null default 0,
  discount numeric(14,2) not null default 0 check (discount >= 0),
  shipping_fee numeric(14,2) not null default 0 check (shipping_fee >= 0),
  total numeric(14,2) not null default 0,
  notes text,
  stock_deducted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index transactions_date_idx on transactions(trx_date);
create index transactions_status_idx on transactions(status);

create table transaction_items (
  id uuid primary key default gen_random_uuid(),
  transaction_id uuid not null references transactions(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
  variant_id uuid references product_variants(id) on delete set null,
  product_name text not null,
  variant_name text,
  qty int not null check (qty > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  subtotal numeric(14,2) generated always as (qty * unit_price) stored,
  created_at timestamptz not null default now()
);
create index transaction_items_trx_idx on transaction_items(transaction_id);
create index transaction_items_product_idx on transaction_items(product_id);

create table inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete set null,
  variant_id uuid references product_variants(id) on delete set null,
  change int not null,
  reason text not null,
  transaction_id uuid references transactions(id) on delete set null,
  created_by uuid default auth.uid(),
  created_at timestamptz not null default now()
);
create index inventory_movements_product_idx on inventory_movements(product_id, created_at desc);

create table admin_activity_logs (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid,
  action text not null,
  entity text not null,
  entity_id text,
  detail jsonb,
  created_at timestamptz not null default now()
);
create index admin_logs_idx on admin_activity_logs(created_at desc);

create function trx_total() returns trigger language plpgsql as $$
begin
  new.total := new.subtotal - new.discount + new.shipping_fee;
  new.updated_at := now();
  return new;
end $$;
create trigger transactions_total before insert or update on transactions for each row execute function trx_total();

create function items_recalc() returns trigger language plpgsql security definer set search_path = public as $$
declare t uuid;
begin
  t := coalesce(new.transaction_id, old.transaction_id);
  update transactions set subtotal = coalesce((select sum(subtotal) from transaction_items where transaction_id = t), 0) where id = t;
  return null;
end $$;
create trigger items_recalc_trg after insert or update or delete on transaction_items for each row execute function items_recalc();

create function trx_stock_sync() returns trigger language plpgsql security definer set search_path = public as $$
declare r record;
begin
  if new.status not in ('baru','dibatalkan') and not new.stock_deducted then
    for r in select * from transaction_items where transaction_id = new.id loop
      if r.variant_id is not null then
        update product_variants set stock = stock - r.qty where id = r.variant_id;
      elsif r.product_id is not null then
        update products set stock = stock - r.qty where id = r.product_id;
      end if;
      insert into inventory_movements(product_id, variant_id, change, reason, transaction_id)
      values (r.product_id, r.variant_id, -r.qty, 'Penjualan ' || new.code, new.id);
    end loop;
    new.stock_deducted := true;
  elsif new.status in ('baru','dibatalkan') and new.stock_deducted then
    for r in select * from transaction_items where transaction_id = new.id loop
      if r.variant_id is not null then
        update product_variants set stock = stock + r.qty where id = r.variant_id;
      elsif r.product_id is not null then
        update products set stock = stock + r.qty where id = r.product_id;
      end if;
      insert into inventory_movements(product_id, variant_id, change, reason, transaction_id)
      values (r.product_id, r.variant_id, r.qty, 'Stok dikembalikan ' || new.code, new.id);
    end loop;
    new.stock_deducted := false;
  end if;
  return new;
end $$;
create trigger transactions_stock before update of status on transactions for each row execute function trx_stock_sync();

create function adjust_stock(p_product uuid, p_variant uuid, p_change int, p_reason text) returns void language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'Tidak diizinkan'; end if;
  if coalesce(trim(p_reason), '') = '' then raise exception 'Alasan wajib diisi'; end if;
  if p_variant is not null then
    update product_variants set stock = stock + p_change where id = p_variant;
  else
    update products set stock = stock + p_change where id = p_product;
  end if;
  insert into inventory_movements(product_id, variant_id, change, reason) values (p_product, p_variant, p_change, p_reason);
end $$;

create function log_activity() returns trigger language plpgsql security definer set search_path = public as $$
declare rec jsonb;
begin
  rec := case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end;
  insert into admin_activity_logs(admin_id, action, entity, entity_id, detail)
  values (auth.uid(), tg_op, tg_table_name, coalesce(rec->>'id', rec->>'key'),
    jsonb_build_object('label', coalesce(rec->>'name', rec->>'title', rec->>'question', rec->>'code', rec->>'key')));
  return null;
end $$;

do $$
declare t text;
begin
  foreach t in array array['products','faqs','faq_categories','announcements','transactions','categories','product_labels','banners','testimonials','site_settings','whatsapp_settings'] loop
    execute format('create trigger %I after insert or update or delete on %I for each row execute function log_activity()', t || '_log', t);
  end loop;
end $$;

do $$
declare t text;
begin
  foreach t in array array['admins','categories','product_labels','products','product_images','product_variants','product_label_assignments','faq_categories','faqs','announcements','banners','testimonials','site_settings','whatsapp_settings','transactions','transaction_items','inventory_movements','admin_activity_logs'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy admin_all on %I for all using (is_admin()) with check (is_admin())', t);
  end loop;
end $$;

create policy public_read on categories for select using (is_active);
create policy public_read on product_labels for select using (is_active);
create policy public_read on products for select using (is_published and not is_archived);
create policy public_read on product_images for select using (exists (select 1 from products p where p.id = product_id and p.is_published and not p.is_archived));
create policy public_read on product_variants for select using (is_active and exists (select 1 from products p where p.id = product_id and p.is_published and not p.is_archived));
create policy public_read on product_label_assignments for select using (exists (select 1 from products p where p.id = product_id and p.is_published and not p.is_archived));
create policy public_read on faq_categories for select using (is_active);
create policy public_read on faqs for select using (is_active);
create policy public_read on announcements for select using (is_active and starts_at <= now() and (ends_at is null or ends_at > now()));
create policy public_read on banners for select using (is_active);
create policy public_read on testimonials for select using (is_active);
create policy public_read on site_settings for select using (true);
create policy public_read on whatsapp_settings for select using (true);

insert into storage.buckets (id, name, public) values ('gabin-media', 'gabin-media', true) on conflict (id) do nothing;
create policy media_read on storage.objects for select using (bucket_id = 'gabin-media');
create policy media_admin_write on storage.objects for all using (bucket_id = 'gabin-media' and is_admin()) with check (bucket_id = 'gabin-media' and is_admin());
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
