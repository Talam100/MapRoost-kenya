-- NyumbaLink Kenya: shared rental listings
-- Run this whole file in Supabase Dashboard > SQL Editor.
-- New listings are private/pending until the site owner approves them.

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 4 and 70),
  property_type text not null,
  town text not null,
  area text not null,
  rent integer not null check (rent > 0 and rent <= 10000000),
  bedrooms text,
  phone text not null,
  photo_url text,
  description text not null check (char_length(description) <= 600),
  amenities text[] not null default '{}',
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

alter table public.listings enable row level security;

-- Grant the minimum table actions needed; Row Level Security narrows the rows/actions.
grant select, insert on public.listings to anon, authenticated;

drop policy if exists "Anyone can read approved listings" on public.listings;
create policy "Anyone can read approved listings"
  on public.listings for select
  to anon, authenticated
  using (status = 'approved');

drop policy if exists "Visitors can submit pending listings" on public.listings;
create policy "Visitors can submit pending listings"
  on public.listings for insert
  to anon, authenticated
  with check (status = 'pending');

-- There are intentionally no public UPDATE or DELETE policies.
-- To approve a listing, open Table Editor > listings in Supabase and change
-- status from 'pending' to 'approved'. Reject fake listings by setting 'rejected'.
