-- GYMFLOW multi-tenant starter schema
-- Apply only after creating a Supabase project. Review policies before production.
create extension if not exists pgcrypto;

create table if not exists public.gyms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  city text,
  state text,
  country text default 'India',
  email text,
  phone text,
  subscription_status text not null default 'trial'
    check (subscription_status in ('trial','active','past_due','cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.gym_users (
  id uuid primary key references auth.users(id) on delete cascade,
  gym_id uuid not null references public.gyms(id) on delete cascade,
  role text not null check (role in ('owner','manager','reception','trainer','billing')),
  created_at timestamptz not null default now(),
  unique(id, gym_id)
);

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  member_code text not null,
  full_name text not null,
  email text,
  phone text,
  status text not null default 'active' check (status in ('active','pending','expired','paused')),
  joined_on date default current_date,
  created_at timestamptz not null default now(),
  unique(gym_id, member_code)
);

create table if not exists public.membership_plans (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  name text not null,
  duration_days integer not null check(duration_days > 0),
  price numeric(12,2) not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  plan_id uuid references public.membership_plans(id) on delete set null,
  starts_on date not null,
  ends_on date not null,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  checked_in_at timestamptz not null default now(),
  method text not null default 'manual'
);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  member_id uuid references public.members(id) on delete set null,
  invoice_number text not null,
  amount numeric(12,2) not null,
  tax_amount numeric(12,2) not null default 0,
  status text not null default 'unpaid' check(status in ('unpaid','paid','void','refunded')),
  due_date date,
  created_at timestamptz not null default now(),
  unique(gym_id, invoice_number)
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  invoice_id uuid references public.invoices(id) on delete set null,
  amount numeric(12,2) not null,
  method text,
  provider_reference text,
  verified_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.message_preferences (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  whatsapp_opt_in boolean not null default false,
  email_opt_in boolean not null default false,
  opted_out_at timestamptz,
  consent_source text,
  consent_at timestamptz,
  unique(gym_id, member_id)
);

create table if not exists public.message_logs (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid not null references public.gyms(id) on delete cascade,
  member_id uuid references public.members(id) on delete set null,
  channel text not null check(channel in ('whatsapp','email')),
  template_key text not null,
  status text not null default 'queued',
  provider_message_id text,
  error_message text,
  created_at timestamptz not null default now()
);

-- Helper: a signed-in user may access rows only for gyms assigned to them.
create or replace function public.user_has_gym_access(target_gym uuid)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.gym_users gu
    where gu.id = auth.uid() and gu.gym_id = target_gym
  );
$$;

alter table public.gyms enable row level security;
alter table public.gym_users enable row level security;
alter table public.members enable row level security;
alter table public.membership_plans enable row level security;
alter table public.memberships enable row level security;
alter table public.attendance enable row level security;
alter table public.invoices enable row level security;
alter table public.payments enable row level security;
alter table public.message_preferences enable row level security;
alter table public.message_logs enable row level security;

create policy "users see assigned gyms" on public.gyms
for select using (public.user_has_gym_access(id));
create policy "users see own gym assignments" on public.gym_users
for select using (id = auth.uid() or public.user_has_gym_access(gym_id));

create policy "gym members scoped" on public.members
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym plans scoped" on public.membership_plans
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym memberships scoped" on public.memberships
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym attendance scoped" on public.attendance
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym invoices scoped" on public.invoices
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym payments scoped" on public.payments
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym message preferences scoped" on public.message_preferences
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));
create policy "gym message logs scoped" on public.message_logs
for all using (public.user_has_gym_access(gym_id))
with check (public.user_has_gym_access(gym_id));

-- IMPORTANT:
-- This is a starter baseline, not a production security audit.
-- Platform-super-admin policies, member self-service access, invite flows,
-- server-side role checks, and webhook verification must be added before launch.
