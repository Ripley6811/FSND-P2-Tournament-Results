#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2
import itertools
import math


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    connection = psycopg2.connect("dbname=tournament")
    return connection, connection.cursor()


def deleteMatches():
    """Remove all the match records from the database."""
    con, cur = connect()
    cur.execute('DELETE FROM results;')
    cur.execute('DELETE FROM matches;')
    con.commit()
    con.close()


def deletePlayers():
    """Remove all the player records from the database."""
    con, cur = connect()
    cur.execute('DELETE FROM players;')
    con.commit()
    con.close()


def deleteTournaments():
    """Remove all the tournament records from the database."""
    con, cur = connect()
    cur.execute('DELETE FROM tournaments;')
    con.commit()
    con.close()


def countPlayers():
    """Returns the number of players currently registered."""
    con, cur = connect()
    cur.execute('SELECT count(*) FROM players;')
    player_count = cur.fetchone()[0]
    con.close()
    return player_count


def registerPlayer(name):
    """Adds a player to the tournament database.
  
    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)
  
    Args:
      name: the player's full name (need not be unique).
    """
    con, cur = connect()
    cur.execute('INSERT INTO players (name) VALUES (%s);', (name,))
    con.commit()
    con.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list is the player in first place, or a player
    tied for first place if there is currently a tie. Also sorted by OMW in
    case of a tie.

    Returns:
      A list of tuples, each of which contains (id, name, matches, wins, byes, omw):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        matches: the number of matches the player has played
        wins: the number of matches the player has won
        byes: the number of matches won as a 'bye'. Should be 1 or 0.
        omw: Total wins by players they have played against. (Opponent Match Wins).
    """
    con, cur = connect()
    cur.execute('SELECT * FROM player_standings')
    winner_list = cur.fetchall()
    con.close()
    return winner_list


def reportMatch(winner, loser=None):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost, or None for 'bye'
    """
    con, cur = connect()
    cur.execute('INSERT INTO matches (id, round) VALUES (DEFAULT, 1) RETURNING id')
    match_id = cur.fetchone()[0]
    cur.execute('INSERT INTO results (match_id, player_id, winner) VALUES (%s, %s, %s)', 
                (match_id, winner, True))
    if loser != None:
        cur.execute('INSERT INTO results (match_id, player_id, winner) VALUES (%s, %s, %s)', 
                    (match_id, loser, False))
    con.commit()
    con.close()
    


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.
  
    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings. Last player in groups of odd number of
    players is swapped with second to last if player already has a bye.
  
    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id or None
        name2: the second player's name or None
    """
    con, cur = connect()
    # Get list of registered players ordered by wins.
    players_ranklist = playerStandings()
    # Organize in to pairings and return list.
    ret_list = []
    for a, b in itertools.izip_longest(players_ranklist[::2], players_ranklist[1::2]):
        if b:
            ret_list.append((a[0], a[1], b[0], b[1]))
        else:
            # Give last player a bye.
            # Swap last two players if last already has a bye.
            if a[4] == 1:
                c0, c1, d0, d1 = ret_list[-1]
                ret_list[-1] = (c0, c1, a[0], a[1])
                ret_list.append((d0, d1, None, None))
            else:
                ret_list.append((a[0], a[1], None, None))
    return ret_list
    con.close()

    
    
