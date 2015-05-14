-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

CREATE DATABASE tournament;
\c tournament;

CREATE TABLE players (  
       id serial PRIMARY KEY,
       name text
);

CREATE TABLE tournaments (
    id serial PRIMARY KEY,
    created date default 'now()'
);

CREATE TABLE matches (
    id serial PRIMARY KEY,
    tournament_id integer REFERENCES tournaments(id),
    round integer,
    arena integer
);

CREATE TABLE results (
    id serial PRIMARY KEY,
    match_id integer NOT NULL REFERENCES matches(id),
    player_id integer NOT NULL REFERENCES players(id),
    winner boolean NOT NULL
);

CREATE VIEW match_details AS 
SELECT wintable.match_id, 
       tournament_id,
       round,
       arena,
       wintable.winner_id,
       (SELECT name FROM players WHERE wintable.winner_id = players.id) as winner,
       player_id AS loser_id,
       (SELECT name FROM players WHERE player_id = players.id) AS loser
FROM (
    SELECT matches.id AS match_id, 
           tournament_id,
           round,
           arena,
           player_id as winner_id
    FROM matches LEFT JOIN results ON matches.id = results.match_id WHERE results.winner = True
) AS wintable
LEFT JOIN results ON wintable.match_id = results.match_id WHERE results.winner = False
ORDER BY tournament_id, round, arena;

CREATE VIEW player_standings AS
SELECT players.id, 
       players.name, 
       COALESCE(foo.cwin, 0) AS wins_total, 
       COALESCE(foo.cmatch, 0) AS matches_total
FROM players LEFT JOIN (
    SELECT player_id, 
           COUNT(NULLIF(results.winner, false)) AS cwin, 
           COUNT(results.id) AS cmatch 
    FROM results GROUP BY player_id
) AS foo
ON players.id = foo.player_id
ORDER BY wins_total DESC;


-- Remember: In SQL, we always put string and date values inside single quotes.