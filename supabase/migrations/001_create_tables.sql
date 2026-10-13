create table public.scan_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  file_path text,
  original_text text,
  detected_language text,
  summary text,
  created_at timestamptz not null default now()
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  scan_id uuid references public.scan_history(id) on delete set null,
  title text not null,
  description text,
  due_date date,
  priority text not null default 'medium'
    check (priority in ('low', 'medium', 'high')),
  source_evidence text,
  status text not null default 'pending'
    check (status in ('pending', 'in_progress', 'completed')),
  created_at timestamptz not null default now()
);

alter table public.scan_history enable row level security;
alter table public.tasks enable row level security;

create policy "Users manage their own scans"
on public.scan_history
for all to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users manage their own tasks"
on public.tasks
for all to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create index tasks_user_due_date_idx
on public.tasks(user_id, due_date);

create index scans_user_created_idx
on public.scan_history(user_id, created_at desc);
