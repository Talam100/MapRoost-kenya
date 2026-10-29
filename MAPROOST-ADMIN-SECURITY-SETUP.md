# MapRoost admin and advertiser-verification setup

This branch adds `admin.html`, a dashboard draft. **Do not merge/deploy it until the database checks below are complete.** GitHub Pages is a static host; it cannot protect admin data by itself. Supabase Authentication plus Row Level Security (RLS) must enforce access in the database.

## What was checked in the existing website

- The public site reads approved records from the `listings` table.
- Listing submissions set `status = 'pending'`.
- Existing listing fields used by the website include `id`, `title`, `property_type`, `town`, `area`, `rent`, `bedrooms`, `phone`, `photo_url`, `description`, `amenities`, `latitude`, `longitude`, `status`; the dashboard also attempts to display `created_at` if present.
- Photos and videos are stored in the public `property-media` bucket and photo/video URLs are embedded in the description. Because this bucket is public, anyone with a URL may view the uploaded media. Do not upload identity cards, title documents, private phone screenshots, or other sensitive evidence to this public bucket.
- The current browser publishable key is intended to be public. Never place a Supabase service-role/secret key in HTML or JavaScript.

## 1. Inspect existing policies before changing anything

Open Supabase Dashboard → SQL Editor → New query and run this read-only diagnostic first:

```sql
select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('listings', 'admin_users')
order by tablename, cmd, policyname;

select c.relname as table_name, c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relname in ('listings', 'admin_users');
```

Save the result privately. PostgreSQL policies for the same command are commonly combined with OR; adding a restrictive-looking policy does **not** neutralize an existing permissive policy. Inspect and remove/replace unsafe broad UPDATE/SELECT policies before considering the admin panel protected. Also inspect Storage → Policies for the `property-media` bucket.

## 2. Create the admin allowlist table

Run this SQL after confirming the project is the correct MapRoost project:

```sql
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;

revoke all on public.admin_users from anon;
revoke all on public.admin_users from authenticated;

grant select on public.admin_users to authenticated;

drop policy if exists "Admins can read admin allowlist" on public.admin_users;
create policy "Admins can read admin allowlist"
on public.admin_users for select to authenticated
using (exists (
  select 1 from public.admin_users a where a.user_id = (select auth.uid())
));
```

The policy above is intended for authenticated admins to check their own membership. Verify it with your project and Supabase policy tooling before use. Do not create public INSERT, UPDATE, or DELETE policies on `admin_users`.

## 3. Create the first administrator safely

1. In Supabase → Authentication → Users, create an account using an email you control and a strong unique password. Do not share the password in chat.
2. Copy that account's **UUID** from the Auth users screen (not its password or access token).
3. In SQL Editor, replace the placeholder below with that UUID and run:

```sql
insert into public.admin_users (user_id)
values ('REPLACE-WITH-YOUR-AUTH-USER-UUID')
on conflict (user_id) do nothing;
```

Only add people you personally trust. Never expose an admin registration form on the public site.

## 4. Fix listing permissions based on the diagnostic

Do not blindly paste a generic policy set over existing production policies. First identify every policy on `public.listings` and remove any policy that allows `anon` or ordinary authenticated users to update `status` or read pending records. Keep the public read policy limited to approved listings and keep visitor submission limited to inserting pending rows.

The desired security conditions are:

- Public/anonymous users: can read only approved listings; may submit new records only if the insert policy forces `status = 'pending'`.
- Ordinary authenticated users: no ability to approve, reject, or edit existing listings.
- Allowlisted administrators: can read pending listings and update status only through RLS-approved actions.
- Admin allowlist: no public writes; membership changes only by trusted project owner through Supabase SQL/dashboard.
- Verification evidence: stored privately, not in the public website or public media bucket.

**Important limitation:** PostgreSQL table-level UPDATE grants and RLS policies do not by themselves limit a user to only the `status` column if that user has UPDATE permission on the whole table. For a hardened production implementation, use a narrowly scoped database function (RPC) with a strict admin check to approve/reject, or grant update on only the status column and ensure all other policies are correct. Test from a non-admin account that approval fails. Do not call the dashboard production-secure until these tests pass.

## 5. Advertiser / property verification checklist

For each submission, record review results outside the public listing:
- Call or message the advertiser using the submitted phone number and confirm their name and authority to advertise.
- Confirm the property location and that current photos/video depict the actual property; check for reused or inconsistent images.
- Confirm rent, deposit, fees, availability, utilities, access, and whether the advertiser is owner or agent.
- Ask for ownership/authorization evidence through a private, access-controlled channel only when needed. Limit who can see it, do not publish it, and delete it when no longer needed under a documented retention rule.
- For land, encourage the prospective buyer to obtain an official search through the relevant land registry/Ardhisasa where applicable. A photo of a title deed is not sufficient proof by itself.
- Record the reviewer, date, checks completed, and reason for rejection. Never promise that approval guarantees safety or legal title.
- Provide a way for visitors to report suspicious listings and respond promptly to complaints.

## 6. Test before going live

- Sign in as the allowlisted administrator: dashboard should load pending listings.
- Sign in as a normal Auth user: dashboard must deny access.
- Signed out/anonymous: dashboard must not display pending records.
- From an ordinary user session, attempt an update to `status`: it must fail.
- Public homepage must still show approved records only.
- Test approve and reject actions with a harmless test listing, then remove the test listing.
- Check Storage policies: unauthenticated visitors should not be able to upload arbitrary files into public folders; enforce file-size and content-type limits where supported.
- If any check fails, do not deploy the dashboard. Keep the live homepage unchanged while fixing the database.

## Branch status

This is a preparation branch only. The live `main` branch and live site have not been intentionally changed by this work. The dashboard is not production-ready until the SQL/RLS configuration is inspected, applied, and tested.
