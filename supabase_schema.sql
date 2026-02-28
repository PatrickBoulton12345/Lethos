-- Lethos Supabase Schema
-- Run this in the Supabase SQL Editor after creating your project

-- 1. Profiles
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  height_cm integer,
  weight_kg double precision,
  age integer,
  gender text,
  current_body_type text,
  goal_physique_type text,
  training_days_per_week integer default 3,
  equipment_access text default 'full_gym',
  dietary_requirements text[] default '{}',
  is_pro boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. Physique Analyses
create table public.physique_analyses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles on delete cascade not null,
  goal_image_url text,
  analysis_json jsonb,
  percentage_difference integer,
  created_at timestamptz default now()
);

-- 3. Workout Plans
create table public.workout_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles on delete cascade not null,
  physique_analysis_id uuid references public.physique_analyses,
  plan_json jsonb,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- 4. Weekly Check-ins
create table public.weekly_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles on delete cascade not null,
  week_number integer not null,
  photo_url text,
  weight_kg double precision,
  sessions_completed integer,
  sessions_planned integer,
  energy_level integer,
  user_notes text,
  ai_response_json jsonb,
  progress_percentage integer,
  created_at timestamptz default now()
);

-- 5. Workout Completions
create table public.workout_completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles on delete cascade not null,
  workout_plan_id uuid references public.workout_plans,
  day_number integer not null,
  completed_at timestamptz default now()
);

-- 6. Storage bucket for user images
insert into storage.buckets (id, name, public)
values ('user-images', 'user-images', true);

-- 7. Row Level Security (users can only access their own data)
alter table public.profiles enable row level security;
alter table public.physique_analyses enable row level security;
alter table public.workout_plans enable row level security;
alter table public.weekly_checkins enable row level security;
alter table public.workout_completions enable row level security;

-- Profiles: users can read/write their own
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can insert own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Physique analyses: users can CRUD their own
create policy "Users can view own analyses" on public.physique_analyses for select using (auth.uid() = user_id);
create policy "Users can insert own analyses" on public.physique_analyses for insert with check (auth.uid() = user_id);

-- Workout plans: users can CRUD their own
create policy "Users can view own plans" on public.workout_plans for select using (auth.uid() = user_id);
create policy "Users can insert own plans" on public.workout_plans for insert with check (auth.uid() = user_id);

-- Weekly check-ins: users can CRUD their own
create policy "Users can view own checkins" on public.weekly_checkins for select using (auth.uid() = user_id);
create policy "Users can insert own checkins" on public.weekly_checkins for insert with check (auth.uid() = user_id);

-- Workout completions: users can CRUD their own
create policy "Users can view own completions" on public.workout_completions for select using (auth.uid() = user_id);
create policy "Users can insert own completions" on public.workout_completions for insert with check (auth.uid() = user_id);

-- Storage: users can upload to their own folder
create policy "Users can upload own images" on storage.objects for insert with check (
  bucket_id = 'user-images' and auth.uid()::text = (storage.foldername(name))[1]
);
create policy "Anyone can view user images" on storage.objects for select using (
  bucket_id = 'user-images'
);
