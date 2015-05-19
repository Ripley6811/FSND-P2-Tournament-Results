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

DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament;


-- Table for tournaments showing ID, title (optional) and date/time created.
CREATE TABLE tournaments (
    id serial PRIMARY KEY,
    title text DEFAULT '', -- Optional tournament name
    created timestamp DEFAULT CURRENT_TIMESTAMP
);


-- Table for players showing ID, name and registered tournament.
CREATE TABLE players (  
    id serial PRIMARY KEY,
    name text,
    tournament_id integer REFERENCES tournaments(id)
);


-- Table for individual match, showing tournament ID, round # and winner/loser.
CREATE TABLE matches (
    id serial PRIMARY KEY,
    tournament_id integer REFERENCES tournaments(id),
    round integer,
    winner_id integer NOT NULL REFERENCES players(id),
    loser_id integer NULL REFERENCES players(id) -- Null for 'bye' match.
);


-------------------------------------------------------------------------------
-- All views below are related to the most current tournament.

-- View for getting current tournament ID number.
CREATE VIEW current_tournament AS
SELECT id FROM tournaments ORDER BY created DESC LIMIT 1;


-- View of players in the current tournament.
CREATE VIEW current_players AS
SELECT id, name
FROM players
WHERE tournament_id = (SELECT * FROM current_tournament);


-- View of current tournament matches.
CREATE VIEW current_matches AS 
SELECT id AS match_id,
       round,
       winner_id,
       (SELECT name FROM players WHERE winner_id = players.id) AS winner_name,
       loser_id,
       (SELECT name FROM players WHERE loser_id = players.id) AS loser_name
FROM matches
WHERE tournament_id = (SELECT * FROM current_tournament)
ORDER BY round;


-- View of each players total wins for current tournament.
CREATE VIEW current_player_wins AS
SELECT winner_id AS player_id, 
       COUNT(*) AS wins
FROM current_matches -- Current matches view
GROUP BY winner_id;


-- View of each players total byes for current tournament.
CREATE VIEW current_player_byes AS
SELECT winner_id AS player_id,
       COUNT(CASE WHEN loser_id IS NULL THEN 1 END) AS byes
FROM current_matches -- Current matches view
GROUP BY winner_id;


-- View of players opponent match wins total.
CREATE VIEW current_player_OMW AS
SELECT winner_id as player_id, 
       COALESCE(CAST(SUM(wins) AS bigint), 0) as OMW
FROM current_matches
LEFT JOIN current_player_wins
ON current_matches.loser_id = current_player_wins.player_id
GROUP BY winner_id;


-- View of players standings
CREATE VIEW player_standings AS
SELECT id, -- Add player name to returned table.
       name, 
       (SELECT COUNT(*) FROM current_matches 
        WHERE id = current_matches.winner_id 
        OR id = current_matches.loser_id) AS matches,
       COALESCE((SELECT wins FROM current_player_wins 
                 WHERE id = current_player_wins.player_id), 0) AS wins, 
       COALESCE((SELECT byes FROM current_player_byes 
                 WHERE id = current_player_byes.player_id), 0) AS byes, 
       COALESCE((SELECT omw FROM current_player_OMW 
                 WHERE id = current_player_OMW.player_id), 0) AS omw
FROM current_players
ORDER BY wins DESC, omw DESC;

