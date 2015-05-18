-- Table definitions for the tournament project.
--
-- SQL 'create table' and 'create view' statements
--
-- Usage:
-- At "vagrant=>" prompt, enter "\i tournament.sql"
-- You should see confirmation that tables and views were created or that
-- they already existed.
--
-- Remember: Always put string and date values inside single quotes.

CREATE DATABASE tournament;
\c tournament;


CREATE TABLE players (  
    id serial PRIMARY KEY,
    name text
);


CREATE TABLE tournaments (
    id serial PRIMARY KEY,
    title text NULL,
    created timestamp default CURRENT_TIMESTAMP
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


CREATE VIEW current_tournament AS
SELECT id FROM tournaments ORDER BY created DESC LIMIT 1;


CREATE VIEW current_results AS
SELECT match_id, player_id, winner 
FROM results 
JOIN matches ON matches.id = results.match_id 
WHERE matches.tournament_id = (SELECT * FROM current_tournament);


CREATE VIEW current_players AS
SELECT id, name 
FROM players
JOIN tournament_register ON tournament_register.player_id = players.id 
WHERE tournament_register.tournament_id = (SELECT * FROM current_tournament);


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
    FROM matches 
    LEFT JOIN current_results ON matches.id = current_results.match_id 
    WHERE current_results.winner = True
) AS wintable
LEFT JOIN current_results ON wintable.match_id = current_results.match_id AND current_results.winner = False
WHERE tournament_id = (SELECT * FROM current_tournament)
ORDER BY tournament_id, round;


CREATE VIEW player_OMW AS
SELECT winner as id, COALESCE(CAST(SUM(wins_total) AS bigint), 0) as OMW
FROM match_details
LEFT JOIN (
    SELECT player_id, COUNT(CASE WHEN winner = True THEN 1 END) AS wins_total 
    FROM current_results
    GROUP BY player_id
) AS wins_counter 
ON match_details.loser_id = wins_counter.player_id
GROUP BY id;


CREATE VIEW player_standings AS
SELECT current_players.id, -- Add player name to returned table.
       current_players.name, 
       (SELECT COUNT(*) FROM current_results WHERE player_id = current_players.id) AS matches,
       COALESCE(player_counts.cwin, 0) AS wins, 
       COALESCE(player_counts.byes, 0) AS byes,
       COALESCE((SELECT omw FROM player_omw WHERE current_players.name = id), 0) AS omw
FROM current_players LEFT JOIN (
    SELECT winner_id, -- Get count of each player's total matches and total wins.
           COUNT(winner_id) AS cwin, 
           COUNT(CASE WHEN loser_id IS NULL THEN 1 END) AS byes 
    FROM match_details GROUP BY winner_id
) AS player_counts
ON current_players.id = player_counts.winner_id
ORDER BY wins DESC, omw DESC;


-- SELECT * FROM player_standings