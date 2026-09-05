-- Senzala Cametá — banco Supabase
-- Execute no SQL Editor do Supabase.

create extension if not exists pgcrypto;

create table if not exists public.settings (
  id integer primary key default 1 check (id = 1),
  group_name text default 'Grupo Senzala Cametá',
  whatsapp text default '5591999999999',
  instagram text default 'https://instagram.com/',
  email text default 'contato@senzalacameta.com',
  address text default 'Cametá — Pará',
  map_query text default 'Cametá PA',
  hero_title text default 'Capoeira que preserva. Cultura que transforma.',
  hero_text text default 'Treinos, rodas, eventos, oficinas, musicalidade, projetos culturais e a nossa família de capoeiristas.',
  updated_at timestamptz default now()
);
insert into public.settings (id) values (1) on conflict (id) do nothing;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(), name text not null, role text, category text, initials text, bio text, photo text, created_at timestamptz default now()
);
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(), type text, date text, time text, title text not null, place text, address text, description text, image text, link text, created_at timestamptz default now()
);
create table if not exists public.schedule (
  id uuid primary key default gen_random_uuid(), category text, day text, time text, place text, focus text, created_at timestamptz default now()
);
create table if not exists public.gallery (
  id uuid primary key default gen_random_uuid(), category text, url text not null, caption text, created_at timestamptz default now()
);
create table if not exists public.music (
  id uuid primary key default gen_random_uuid(), title text not null, author text, file text, lyrics text, created_at timestamptz default now()
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(), title text not null, type text, description text, image text, created_at timestamptz default now()
);
create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(), name text, text text, created_at timestamptz default now()
);
create table if not exists public.partners (
  id uuid primary key default gen_random_uuid(), name text, url text, created_at timestamptz default now()
);
create table if not exists public.notices (
  id uuid primary key default gen_random_uuid(), title text, message text, created_at timestamptz default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(), name text not null, phone text, subject text, message text, status text default 'novo', created_at timestamptz default now()
);

-- RLS
alter table public.settings enable row level security;
alter table public.admins enable row level security;
alter table public.members enable row level security;
alter table public.events enable row level security;
alter table public.schedule enable row level security;
alter table public.gallery enable row level security;
alter table public.music enable row level security;
alter table public.projects enable row level security;
alter table public.testimonials enable row level security;
alter table public.partners enable row level security;
alter table public.notices enable row level security;
alter table public.messages enable row level security;

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- Public read for website content
create policy "public read settings" on public.settings for select using (true);
create policy "public read members" on public.members for select using (true);
create policy "public read events" on public.events for select using (true);
create policy "public read schedule" on public.schedule for select using (true);
create policy "public read gallery" on public.gallery for select using (true);
create policy "public read music" on public.music for select using (true);
create policy "public read projects" on public.projects for select using (true);
create policy "public read testimonials" on public.testimonials for select using (true);
create policy "public read partners" on public.partners for select using (true);
create policy "public read notices" on public.notices for select using (true);

-- Admin full access
create policy "admin settings" on public.settings for all using (public.is_admin()) with check (public.is_admin());
create policy "admin members" on public.members for all using (public.is_admin()) with check (public.is_admin());
create policy "admin events" on public.events for all using (public.is_admin()) with check (public.is_admin());
create policy "admin schedule" on public.schedule for all using (public.is_admin()) with check (public.is_admin());
create policy "admin gallery" on public.gallery for all using (public.is_admin()) with check (public.is_admin());
create policy "admin music" on public.music for all using (public.is_admin()) with check (public.is_admin());
create policy "admin projects" on public.projects for all using (public.is_admin()) with check (public.is_admin());
create policy "admin testimonials" on public.testimonials for all using (public.is_admin()) with check (public.is_admin());
create policy "admin partners" on public.partners for all using (public.is_admin()) with check (public.is_admin());
create policy "admin notices" on public.notices for all using (public.is_admin()) with check (public.is_admin());
create policy "admin messages" on public.messages for select using (public.is_admin());
create policy "admin update messages" on public.messages for update using (public.is_admin()) with check (public.is_admin());
create policy "admin delete messages" on public.messages for delete using (public.is_admin());

-- Contact form: anonymous/public can create messages, but never read them.
create policy "public create messages" on public.messages for insert with check (true);

-- Storage: public image/audio delivery; only admins can upload/update/delete.
insert into storage.buckets (id, name, public) values ('media','media',true) on conflict (id) do update set public=true;
create policy "public media read" on storage.objects for select using (bucket_id='media');
create policy "admin media insert" on storage.objects for insert with check (bucket_id='media' and public.is_admin());
create policy "admin media update" on storage.objects for update using (bucket_id='media' and public.is_admin()) with check (bucket_id='media' and public.is_admin());
create policy "admin media delete" on storage.objects for delete using (bucket_id='media' and public.is_admin());

-- Seed data
insert into public.members (name,role,category,initials,bio) select * from (values
 ('Responsável do Grupo','Responsável / Graduação','Responsáveis','RG','Responsável pelo trabalho do núcleo.'),
 ('Professor(a)','Professor / Instrutor','Professores','PR',''),
 ('Graduado(a)','Graduado','Graduados','GR',''),
 ('Tenente','Intermediário · Verde e Amarelo','Graduados','TN','') ) v(name,role,category,initials,bio)
where not exists (select 1 from public.members);

insert into public.events (type,date,time,title,place,address,description) select * from (values
 ('Roda','12/09/2026','18:00','Roda de Capoeira','Cametá — PA','Endereço a confirmar','Roda aberta para alunos, convidados e comunidade.'),
 ('Oficina','26/09/2026','18:00','Oficina de Musicalidade','Cametá — PA','Local a confirmar','Berimbau, pandeiro, canto e fundamentos da bateria.'),
 ('Evento','17/10/2026','17:00','Encontro Senzala Cametá','Cametá — PA','Local a confirmar','Integração, treino coletivo, roda e confraternização.') ) v(type,date,time,title,place,address,description)
where not exists (select 1 from public.events);

insert into public.schedule (category,day,time,place,focus) select * from (values
 ('Treino geral','Terça-feira','19:00 — 20:30','Local principal','Fundamentos + técnica'),
 ('Treino geral','Quinta-feira','19:00 — 20:30','Local principal','Sequências + roda'),
 ('Adultos e graduados','Sábado','17:00 — 19:00','Local principal','Aperfeiçoamento') ) v(category,day,time,place,focus)
where not exists (select 1 from public.schedule);

insert into public.projects (title,type,description) select * from (values
 ('Capoeira nas escolas','Escolas','Vivências, apresentações e atividades educativas.'),
 ('Palestras','Palestra','História da capoeira, cultura, musicalidade e identidade.'),
 ('Oficinas','Oficina','Vivências de movimentos, instrumentos, canto e fundamentos.') ) v(title,type,description)
where not exists (select 1 from public.projects);
