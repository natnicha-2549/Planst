-- ตั้งค่าฐานข้อมูลสำหรับ PlantsProject
-- วางทั้งหมดใน Supabase Dashboard > SQL Editor แล้วกด Run (รันซ้ำได้ ไม่พัง)

-- 1. ตาราง plants
create table if not exists public.plants (
  plant_code      text primary key,
  thai_name       text not null,
  scientific_name text,
  location        text,
  images          text[] not null default '{}',
  created_at      timestamptz not null default now()
);

-- ถ้ามีตารางอยู่แล้วแต่ยังไม่มีคอลัมน์รูป ให้เพิ่มเข้าไป
alter table public.plants add column if not exists images text[] not null default '{}';

-- 2. เปิด RLS และอนุญาตให้หน้าเว็บ (anon) อ่าน/เพิ่ม/แก้/ลบได้
alter table public.plants enable row level security;

drop policy if exists "plants_select" on public.plants;
drop policy if exists "plants_insert" on public.plants;
drop policy if exists "plants_update" on public.plants;
drop policy if exists "plants_delete" on public.plants;

create policy "plants_select" on public.plants for select to anon, authenticated using (true);
create policy "plants_insert" on public.plants for insert to anon, authenticated with check (true);
create policy "plants_update" on public.plants for update to anon, authenticated using (true) with check (true);
create policy "plants_delete" on public.plants for delete to anon, authenticated using (true);

-- 3. Storage bucket สำหรับรูป (public = เปิดดูรูปผ่าน URL ได้)
insert into storage.buckets (id, name, public)
values ('plant-images', 'plant-images', true)
on conflict (id) do update set public = true;

drop policy if exists "plant_images_select" on storage.objects;
drop policy if exists "plant_images_insert" on storage.objects;
drop policy if exists "plant_images_delete" on storage.objects;

create policy "plant_images_select" on storage.objects for select to anon, authenticated
  using (bucket_id = 'plant-images');
create policy "plant_images_insert" on storage.objects for insert to anon, authenticated
  with check (bucket_id = 'plant-images');
create policy "plant_images_delete" on storage.objects for delete to anon, authenticated
  using (bucket_id = 'plant-images');
