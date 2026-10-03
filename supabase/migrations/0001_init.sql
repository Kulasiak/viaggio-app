-- Viaggio — initial schema (draft). Postgres / Supabase.
-- Conventions: uuid PKs, timestamptz, i18n text as jsonb {"fr":..,"en":..,"pl":..,"es":..,"ro":..}

create extension if not exists "pgcrypto";

-- ---------- Reference data ----------
create table cities (
  id text primary key,                 -- 'roma', 'milano', ...
  name jsonb not null,
  lat double precision, lng double precision,
  transit_operator text, transit_url text
);

create table pois (
  id uuid primary key default gen_random_uuid(),
  city_id text not null references cities(id),
  local_name text not null,
  name jsonb not null,
  category text not null check (category in ('art','history','church','food','panorama','hood')),
  duration_min int not null check (duration_min > 0),
  price_eur numeric(8,2) not null default 0,
  is_museum boolean not null default false,
  hours jsonb, note jsonb,
  official_url text,
  lat double precision, lng double precision,
  updated_at timestamptz not null default now()
);

create table transport_products (
  id uuid primary key default gen_random_uuid(),
  city_id text not null references cities(id),
  name jsonb not null, meta jsonb, how jsonb,
  price_eur numeric(8,2),
  official_url text,
  purchasable boolean not null default true
);

create table currencies (code text primary key, rate_per_eur numeric(12,4) not null, name jsonb, updated_at timestamptz default now());

-- ---------- People & groups ----------
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  lang text not null default 'fr' check (lang in ('fr','en','pl','es','ro','it')),
  home_currency text references currencies(code),
  phone text,
  created_at timestamptz not null default now()
);

create table agencies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid not null references profiles(id),
  created_at timestamptz not null default now()
);

create table trips (
  id uuid primary key default gen_random_uuid(),
  name text not null,                  -- 'Roma Eterna'
  guide_id uuid not null references profiles(id),
  agency_id uuid references agencies(id),
  client_type text not null default 'agency' check (client_type in ('agency','private')),
  invite_code text unique not null,    -- 'ROMA-2026'
  starts_on date, ends_on date,
  travellers_can_post boolean not null default true,
  status text not null default 'draft' check (status in ('draft','approved','active','closed')),
  created_at timestamptz not null default now()
);

create table trip_members (
  trip_id uuid references trips(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  role text not null check (role in ('guide','tourist')),
  present boolean, last_seen_label text, last_seen_at timestamptz,
  primary key (trip_id, user_id)
);

create table consents (
  user_id uuid references profiles(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  location_mode text not null default 'activities' check (location_mode in ('always','activities','sos_only')),
  documents boolean not null default true,
  health_shared boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, trip_id)
);

-- ---------- Programme ----------
create table programmes (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references trips(id) on delete cascade,
  created_by uuid not null references profiles(id),
  params jsonb not null,               -- client, pax, days, cities[], themes[], pace, budget
  cost_per_person_eur numeric(10,2),
  status text not null default 'draft' check (status in ('draft','approved')),
  approved_at timestamptz,
  is_template boolean not null default false,
  created_at timestamptz not null default now()
);

create table programme_items (
  id uuid primary key default gen_random_uuid(),
  programme_id uuid not null references programmes(id) on delete cascade,
  day_index int not null,
  city_id text references cities(id),
  starts_at time not null, ends_at time,
  kind text not null check (kind in ('poi','meal','train','transfer','free','hotel')),
  poi_id uuid references pois(id),
  title jsonb,
  move_mode text check (move_mode in ('walk','metro','bus','train','tram','taxi')),
  move_min int,
  price_eur numeric(8,2),
  is_meeting_point boolean not null default false,
  meeting_point jsonb,                 -- {name, local_name, lat, lng, note}
  tip jsonb,
  sort int not null
);

create table meeting_replies (
  item_id uuid references programme_items(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  reply text not null check (reply in ('coming','late')),
  at timestamptz not null default now(),
  primary key (item_id, user_id)
);

-- ---------- Communication ----------
create table messages (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  sender_id uuid not null references profiles(id),
  recipient_id uuid references profiles(id),   -- null = group
  body text not null,
  priority boolean not null default false,
  pinned boolean not null default false,
  created_at timestamptz not null default now()
);
create table message_reads (message_id uuid references messages(id) on delete cascade, user_id uuid references profiles(id) on delete cascade, read_at timestamptz default now(), primary key (message_id, user_id));

create table votes (id uuid primary key default gen_random_uuid(), trip_id uuid references trips(id) on delete cascade, question jsonb not null, closes_at timestamptz, closed_option uuid);
create table vote_options (id uuid primary key default gen_random_uuid(), vote_id uuid references votes(id) on delete cascade, title jsonb not null, detail jsonb, poi_id uuid references pois(id), price_eur numeric(8,2));
create table vote_ballots (vote_id uuid references votes(id) on delete cascade, user_id uuid references profiles(id) on delete cascade, option_id uuid references vote_options(id), primary key (vote_id, user_id));

-- ---------- Safety ----------
create table sos_alerts (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references trips(id) on delete cascade,
  user_id uuid not null references profiles(id),
  category text not null check (category in ('medical','theft','document','lost','other')),
  started_at timestamptz not null default now(),
  ended_at timestamptz
);
create table location_pings (                -- short retention (purge job)
  id bigserial primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  trip_id uuid references trips(id) on delete cascade,
  lat double precision not null, lng double precision not null,
  reason text not null check (reason in ('activity','sos','lost')),
  at timestamptz not null default now()
);

-- ---------- Sensitive data (GDPR art. 9) ----------
create table health_cards (
  user_id uuid primary key references profiles(id) on delete cascade,
  encrypted_payload bytea not null,           -- client-side encrypted (conditions, treatment, allergies, blood type, emergency contact)
  diet_summary text,                          -- non-identifying summary for restaurant lists (opt-in)
  updated_at timestamptz not null default now()
);

create table documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  kind text not null check (kind in ('passport','boarding','insurance','hotel','ticket','other')),
  title text, subtitle text,
  storage_path text not null,                 -- Supabase Storage, encrypted object
  mrz_verified boolean default false,
  created_at timestamptz not null default now()
);

create table tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  trip_id uuid references trips(id) on delete set null,
  title text not null, details text,
  quantity int not null default 1,
  price_eur numeric(10,2),
  official_url text,
  document_id uuid references documents(id),
  valid_on date,
  created_at timestamptz not null default now()
);

create table taxfree_receipts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  shop text, amount_eur numeric(10,2) not null, vat_eur numeric(10,2),
  receipt_document_id uuid references documents(id),
  created_at timestamptz not null default now()
);

-- ---------- Helpers & RLS ----------
create or replace function is_trip_member(t uuid) returns boolean language sql stable security definer as
$$ select exists(select 1 from trip_members where trip_id = t and user_id = auth.uid()) $$;
create or replace function is_trip_guide(t uuid) returns boolean language sql stable security definer as
$$ select exists(select 1 from trip_members where trip_id = t and user_id = auth.uid() and role = 'guide') $$;

-- consent checks run as definer (consents/trip_members are themselves protected by RLS)
create or replace function guide_sees_health(u uuid) returns boolean language sql stable security definer as
$$ select exists(select 1 from consents c join trip_members m on m.trip_id = c.trip_id
   where c.user_id = u and c.health_shared and m.user_id = auth.uid() and m.role = 'guide') $$;
create or replace function location_mode_of(u uuid, t uuid) returns text language sql stable security definer as
$$ select coalesce((select location_mode from consents where user_id = u and trip_id = t), 'activities') $$;

alter table profiles enable row level security;
alter table trips enable row level security;
alter table trip_members enable row level security;
alter table consents enable row level security;
alter table programmes enable row level security;
alter table programme_items enable row level security;
alter table meeting_replies enable row level security;
alter table messages enable row level security;
alter table message_reads enable row level security;
alter table sos_alerts enable row level security;
alter table location_pings enable row level security;
alter table health_cards enable row level security;
alter table documents enable row level security;
alter table tickets enable row level security;
alter table taxfree_receipts enable row level security;

create policy own_profile on profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy trip_read on trips for select using (is_trip_member(id) or guide_id = auth.uid());
create policy trip_write on trips for all using (guide_id = auth.uid()) with check (guide_id = auth.uid());
create policy members_read on trip_members for select using (is_trip_member(trip_id));
create policy members_guide on trip_members for all using (is_trip_guide(trip_id));
create policy own_consents on consents for all using (user_id = auth.uid()) with check (user_id = auth.uid());
-- travellers see only APPROVED programmes; guide sees all of his
create policy prog_read on programmes for select using (created_by = auth.uid() or (status = 'approved' and is_trip_member(trip_id)));
create policy prog_write on programmes for all using (created_by = auth.uid()) with check (created_by = auth.uid());
create policy items_read on programme_items for select using (exists(select 1 from programmes p where p.id = programme_id and (p.created_by = auth.uid() or (p.status = 'approved' and is_trip_member(p.trip_id)))));
create policy items_write on programme_items for all using (exists(select 1 from programmes p where p.id = programme_id and p.created_by = auth.uid()));
create policy replies_own on meeting_replies for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy replies_guide on meeting_replies for select using (exists(select 1 from programme_items i join programmes p on p.id = i.programme_id where i.id = item_id and is_trip_guide(p.trip_id)));
create policy msg_read on messages for select using (is_trip_member(trip_id) and (recipient_id is null or recipient_id = auth.uid() or sender_id = auth.uid()));
create policy msg_write on messages for insert with check (sender_id = auth.uid() and is_trip_member(trip_id) and (recipient_id is not null or is_trip_guide(trip_id) or (select travellers_can_post from trips where id = trip_id)));
create policy reads_own on message_reads for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy sos_own on sos_alerts for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy sos_guide on sos_alerts for select using (is_trip_guide(trip_id));
create policy ping_own on location_pings for insert with check (user_id = auth.uid());
create policy ping_guide on location_pings for select using (user_id = auth.uid() or (is_trip_guide(trip_id) and (reason <> 'activity' or location_mode_of(user_id, trip_id) <> 'sos_only')));
create policy health_own on health_cards for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy health_guide on health_cards for select using (guide_sees_health(user_id));
create policy docs_own on documents for all using (user_id = auth.uid()) with check (user_id = auth.uid());   -- guide NEVER reads documents
create policy tickets_own on tickets for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy taxfree_own on taxfree_receipts for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- reference data: readable by everyone authenticated
alter table cities enable row level security; create policy cities_read on cities for select using (true);
alter table pois enable row level security; create policy pois_read on pois for select using (true);
alter table transport_products enable row level security; create policy tp_read on transport_products for select using (true);
alter table currencies enable row level security; create policy cur_read on currencies for select using (true);

create index on programme_items (programme_id, day_index, sort);
create index on messages (trip_id, created_at desc);
create index on location_pings (trip_id, at desc);
create index on pois (city_id, category);
