-- Modalidades
insert into sports(key, name) values
  ('football','Futebol'),
  ('basketball','Basquete'),
  ('volleyball','Vôlei'),
  ('f1','Fórmula 1'),
  ('cycling','Ciclismo'),
  ('handball','Handebol'),
  ('tennis','Tênis'),
  ('futsal','Futsal'),
  ('esports','E‑Sports')
  on conflict do nothing;

-- Competição + temporada de exemplo (Futebol)
insert into competitions(sport_id, name, type)
select id, 'Brasileirão Série A', 'LEAGUE' from sports where key='football' limit 1;

insert into seasons(competition_id, name, year_start, year_end)
select c.id, '2025', 2025, 2025 from competitions c join sports s on s.id=c.sport_id where s.key='football' and c.name='Brasileirão Série A' limit 1;

-- Times
insert into teams(sport_id, name, short_name, country, city)
select id, 'Time A', 'TMA', 'Brasil', 'Palmas' from sports where key='football' limit 1;
insert into teams(sport_id, name, short_name, country, city)
select id, 'Time B', 'TMB', 'Brasil', 'Palmas' from sports where key='football' limit 1;

-- Partida exemplo
insert into matches(sport_id, competition_id, season_id, home_team_id, away_team_id, start_time, status, home_score, away_score)
select s.id, c.id, se.id, ta.id, tb.id, now(), 'LIVE', 1, 0
from sports s
join competitions c on c.sport_id=s.id and c.name='Brasileirão Série A'
join seasons se on se.competition_id=c.id and se.name='2025'
join teams ta on ta.name='Time A' and ta.sport_id=s.id
join teams tb on tb.name='Time B' and tb.sport_id=s.id
where s.key='football'
limit 1;

-- Usuário demo
insert into users(email, password_hash, name, role, theme)
values('paulo@example.com', '$2a$10$q3c4M0R2bqFfO1GZzqf9O.8d2wQzXwD0Pw6o8lU4bQY3i.1zJ3t0e', 'Paulo', 'USER', 'dark');
-- password_hash acima é um bcrypt dummy (não funcional real) de exemplo
