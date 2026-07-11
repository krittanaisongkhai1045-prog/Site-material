-- ============================================================
--  ระบบวัสดุไซต์งาน — โครงฐานข้อมูล Supabase
--  วิธีใช้: เปิด Supabase → โปรเจกต์ของคุณ → เมนู "SQL Editor"
--          วางทั้งไฟล์นี้ แล้วกด Run
-- ============================================================

-- ตารางเก็บข้อมูลแบบ key-value (แอปเก็บทุกอย่างลงตารางนี้: โครงการ วัสดุ ใบเบิก รูป ฯลฯ)
create table if not exists public.kv (
  key         text primary key,
  value       text,
  updated_at  timestamptz default now(),
  updated_by  uuid default auth.uid()
);

-- เปิด Row Level Security
alter table public.kv enable row level security;

-- อนุญาตให้ "ผู้ที่ล็อกอินแล้ว" ทุกคนอ่าน/เขียนข้อมูลกลางชุดเดียวกัน
drop policy if exists "kv read"   on public.kv;
drop policy if exists "kv insert" on public.kv;
drop policy if exists "kv update" on public.kv;
drop policy if exists "kv delete" on public.kv;

create policy "kv read"   on public.kv for select to authenticated using (true);
create policy "kv insert" on public.kv for insert to authenticated with check (true);
create policy "kv update" on public.kv for update to authenticated using (true) with check (true);
create policy "kv delete" on public.kv for delete to authenticated using (true);

-- เปิด Realtime ให้ตารางนี้ (ทุกคนเห็นข้อมูลอัปเดตแบบสด ๆ)
alter publication supabase_realtime add table public.kv;

-- เสร็จแล้ว ✅
-- หมายเหตุ: ทุกคนที่ล็อกอินจะเห็น "ข้อมูลชุดเดียวกัน" (workspace เดียว)
-- ถ้าต้องการแยกทีม/สิทธิ์ในอนาคต ค่อยเพิ่มคอลัมน์ team_id + policy ทีหลังได้
