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
    title text NULL,
    created date default 'now()'
);


CREATE TABLE tournament_register (
    tournament_id integer NOT NULL REFERENCES tournaments(id),
    player_id integer NOT NULL REFERENCES players(id),
    PRIMARY KEY (tournament_id, player_id)
);


CREATE TABLE matches (
    id serial PRIMARY KEY,
    tournament_id integer REFERENCES tournaments(id),
    round integer
);


CREATE TABLE results (
    match_id integer NOT NULL REFERENCES matches(id),
    player_id integer NOT NULL REFERENCES players(id),
    winner boolean NOT NULL,
    PRIMARY KEY (match_id, player_id)
);


CREATE VIEW match_details AS 
SELECT wintable.match_id, 
       tournament_id,
       round,
       wintable.winner_id,
       (SELECT name FROM players WHERE wintable.winner_id = players.id) as winner,
       player_id AS loser_id,
       (SELECT name FROM players WHERE player_id = players.id) AS loser
FROM (
    SELECT matches.id AS match_id, 
           tournament_id,
           round,
           player_id as winner_id
    FROM matches LEFT JOIN results ON matches.id = results.match_id WHERE results.winner = True
) AS wintable
LEFT JOIN results ON wintable.match_id = results.match_id AND results.winner = False
ORDER BY tournament_id, round;


CREATE VIEW player_OMW AS
SELECT winner, COALESCE(CAST(SUM(wins_total) AS bigint), 0) as OMW
FROM match_details
LEFT JOIN (SELECT player_id, COUNT(CASE WHEN winner = True THEN 1 END) AS wins_total FROM results GROUP BY player_id) AS bar ON match_details.loser_id = bar.player_id
GROUP BY winner;


CREATE VIEW player_standings AS
SELECT players.id, -- Add player name to returned table.
       players.name, 
       (SELECT COUNT(*) FROM results WHERE player_id = players.id) AS matches,
       COALESCE(foo.cwin, 0) AS wins, 
       COALESCE(foo.byes, 0) AS byes,
       COALESCE((SELECT omw FROM player_omw WHERE players.name = winner), 0) AS omw
FROM players LEFT JOIN (
    SELECT winner_id, -- Get count of each player's total matches and total wins.
           COUNT(winner_id) AS cwin, 
           COUNT(CASE WHEN loser_id IS NULL THEN 1 END) AS byes 
    FROM match_details GROUP BY winner_id
) AS foo
ON players.id = foo.winner_id
ORDER BY wins DESC, omw DESC;



-- Remember: In SQL, we always put string and date values inside single quotes.