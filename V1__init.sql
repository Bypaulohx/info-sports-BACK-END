-- =====================================================================
-- Sports Info – Schema PostgreSQL
-- =====================================================================
create extension if not exists "uuid-ossp";

-- ===============
-- Utilidades
-- ===============
create table if not exists sports (
  id              bigserial primary key,
  key             varchar(50) not null unique, -- football, basketball, ...
  name            varchar(100) not null
);

create table if not exists competitions (
  id              bigserial primary key,
  sport_id        bigint not null references sports(id) on delete cascade,
  name            varchar(150) not null,
  type            varchar(30) not null default 'LEAGUE' -- LEAGUE|CUP|TOURNAMENT
);

create table if not exists seasons (
  id              bigserial primary key,
  competition_id  bigint not null references competitions(id) on delete cascade,
  name            varchar(100) not null, -- e.g. 2025, 2024/2025
  year_start      int not null,
  year_end        int not null
);

create table if not exists venues (
  id              bigserial primary key,
  name            varchar(150) not null,
  city            varchar(100),
  country         varchar(100),
  capacity        int
);

create table if not exists teams (
  id              bigserial primary key,
  sport_id        bigint not null references sports(id) on delete cascade,
  name            varchar(150) not null,
  short_name      varchar(50),
  country         varchar(100),
  city            varchar(100),
  founded_year    int
);

create table if not exists athletes (
  id              bigserial primary key,
  sport_id        bigint not null references sports(id) on delete cascade,
  full_name       varchar(150) not null,
  birthdate       date,
  country         varchar(100),
  position        varchar(50) -- genérico: FWD, G, etc.
);

create table if not exists team_memberships (
  id              bigserial primary key,
  athlete_id      bigint not null references athletes(id) on delete cascade,
  team_id         bigint not null references teams(id) on delete cascade,
  season_id       bigint references seasons(id) on delete set null,
  shirt_number    varchar(10),
  role            varchar(50),
  unique(athlete_id, team_id, coalesce(season_id, 0))
);

create type match_status as enum ('NOT_STARTED','LIVE','FINISHED','POSTPONED','CANCELED');

create table if not exists matches (
  id              bigserial primary key,
  sport_id        bigint not null references sports(id) on delete restrict,
  competition_id  bigint references competitions(id) on delete set null,
  season_id       bigint references seasons(id) on delete set null,
  venue_id        bigint references venues(id) on delete set null,
  home_team_id    bigint references teams(id) on delete set null,
  away_team_id    bigint references teams(id) on delete set null,
  start_time      timestamptz,
  status          match_status not null default 'NOT_STARTED',
  home_score      int default 0,
  away_score      int default 0,
  metadata        jsonb default '{}'::jsonb
);

create table if not exists match_periods (
  id              bigserial primary key,
  match_id        bigint not null references matches(id) on delete cascade,
  period_number   int not null,
  name            varchar(50), -- 1st half, Q1, Set 1
  home_score      int default 0,
  away_score      int default 0,
  started_at      timestamptz,
  ended_at        timestamptz,
  unique(match_id, period_number)
);

create table if not exists match_events (
  id              bigserial primary key,
  match_id        bigint not null references matches(id) on delete cascade,
  minute          int,
  second          int,
  period_number   int,
  event_type      varchar(50) not null, -- GOAL, CARD, SUB, SHOT, REBOUND, etc.
  team_id         bigint references teams(id) on delete set null,
  athlete_id      bigint references athletes(id) on delete set null,
  assist_id       bigint references athletes(id) on delete set null,
  data            jsonb not null default '{}'::jsonb
);

-- Classificações (snapshots)
create table if not exists league_table_snapshots (
  id              bigserial primary key,
  competition_id  bigint not null references competitions(id) on delete cascade,
  season_id       bigint not null references seasons(id) on delete cascade,
  created_at      timestamptz not null default now()
);

create table if not exists league_table_rows (
  snapshot_id     bigint not null references league_table_snapshots(id) on delete cascade,
  position        int not null,
  team_id         bigint not null references teams(id) on delete cascade,
  played          int not null default 0,
  won             int not null default 0,
  draw            int not null default 0,
  lost            int not null default 0,
  goals_for       int not null default 0,
  goals_against   int not null default 0,
  points          int not null default 0,
  primary key (snapshot_id, position)
);

-- ============================
-- Estatísticas específicas
-- ============================
-- Futebol (por jogador)
create table if not exists football_player_stats (
  id              bigserial primary key,
  match_id        bigint not null references matches(id) on delete cascade,
  team_id         bigint references teams(id) on delete set null,
  athlete_id      bigint references athletes(id) on delete set null,
  goals           int default 0,
  assists         int default 0,
  shots           int default 0,
  shots_on_target int default 0,
  passes          int default 0,
  passes_completed int default 0,
  yellow_cards    int default 0,
  red_cards       int default 0,
  tackles         int default 0,
  saves           int default 0,
  xg              numeric(5,2),
  xa              numeric(5,2)
);

-- Basquete (boxscore)
create table if not exists basketball_boxscore (
  id              bigserial primary key,
  match_id        bigint not null references matches(id) on delete cascade,
  team_id         bigint references teams(id) on delete set null,
  athlete_id      bigint references athletes(id) on delete set null,
  minutes         int default 0,
  pts             int default 0,
  reb             int default 0,
  ast             int default 0,
  stl             int default 0,
  blk             int default 0,
  turnovers       int default 0,
  fgm             int default 0,
  fga             int default 0,
  tpm             int default 0,
  tpa             int default 0,
  ftm             int default 0,
  fta             int default 0,
  plus_minus      int default 0
);

-- Vôlei (estatísticas básicas)
create table if not exists volleyball_stats (
  id              bigserial primary key,
  match_id        bigint not null references matches(id) on delete cascade,
  team_id         bigint references teams(id) on delete set null,
  athlete_id      bigint references athletes(id) on delete set null,
  aces            int default 0,
  service_errors  int default 0,
  blocks          int default 0,
  attacks         int default 0,
  attack_errors   int default 0,
  digs            int default 0,
  receptions      int default 0
);

-- Tênis (games por set)
create table if not exists tennis_match_sets (
  id              bigserial primary key,
  match_id        bigint not null references matches(id) on delete cascade,
  set_number      int not null,
  home_games      int default 0,
  away_games      int default 0,
  tiebreak_home   int,
  tiebreak_away   int,
  unique(match_id, set_number)
);

-- F1
create table if not exists f1_sessions (
  id                 bigserial primary key,
  competition_id     bigint references competitions(id) on delete set null,
  season_id          bigint references seasons(id) on delete set null,
  gp_name            varchar(150) not null,
  circuit_name       varchar(150),
  session_type       varchar(20) not null, -- PRACTICE|QUALI|RACE
  started_at         timestamptz
);

create table if not exists f1_results (
  id                 bigserial primary key,
  session_id         bigint not null references f1_sessions(id) on delete cascade,
  driver_name        varchar(150) not null,
  team_name          varchar(150),
  position           int,
  best_lap_time_ms   int,
  laps               int,
  average_speed_kmh  numeric(6,2)
);

-- Ciclismo
create table if not exists cycling_stages (
  id                 bigserial primary key,
  competition_id     bigint references competitions(id) on delete set null,
  season_id          bigint references seasons(id) on delete set null,
  name               varchar(150) not null,
  stage_number       int not null,
  date               date,
  distance_km        numeric(6,2),
  elevation_gain_m   int,
  start_city         varchar(100),
  finish_city        varchar(100)
);

create table if not exists cycling_results (
  id                 bigserial primary key,
  stage_id           bigint not null references cycling_stages(id) on delete cascade,
  athlete_id         bigint references athletes(id) on delete set null,
  team_name          varchar(150),
  position           int,
  time_ms            bigint,
  points             int,
  mountain_points    int
);

-- ============================
-- Identidades / Preferências
-- ============================
create type user_role as enum ('USER','ADMIN');

create table if not exists users (
  id              bigserial primary key,
  email           varchar(255) not null unique,
  phone           varchar(40) unique,
  password_hash   varchar(255) not null,
  name            varchar(150),
  role            user_role not null default 'USER',
  theme           varchar(10) not null default 'light'
);

create table if not exists favorite (
  id              bigserial primary key,
  user_id         bigint not null references users(id) on delete cascade,
  entity_type     varchar(30) not null,
  entity_id       varchar(100) not null,
  name            varchar(150),
  sport           varchar(50)
);

-- ============================
-- Comunidade
-- ============================
create table if not exists discussions (
  id              bigserial primary key,
  sport           varchar(50),
  title           varchar(200) not null,
  content         text,
  author          varchar(150),
  created_at      timestamptz not null default now()
);

create table if not exists polls (
  id              bigserial primary key,
  sport           varchar(50),
  question        varchar(255) not null,
  options_csv     text not null
);

create table if not exists poll_votes (
  id              bigserial primary key,
  poll_id         bigint not null references polls(id) on delete cascade,
  user_id         bigint references users(id) on delete set null,
  option_index    int not null,
  voted_at        timestamptz not null default now()
);

-- ============================
-- Índices úteis
-- ============================
create index if not exists idx_matches_status on matches(status);
create index if not exists idx_matches_competition on matches(competition_id);
create index if not exists idx_events_match on match_events(match_id);
create index if not exists idx_events_type on match_events(event_type);
create index if not exists idx_ft_stats_match on football_player_stats(match_id);
create index if not exists idx_bb_box_match on basketball_boxscore(match_id);
