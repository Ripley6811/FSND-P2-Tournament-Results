Tournament Project
==================

## Summary
This is a exercise in working with PostgreSQL. All **SQL** code was written by me.
Testing methods in `tournament_test.py` were provided by Udacity for testing SQL
functionality. Testing code was further altered by me to support advanced features
of my database setup. *Standings* output was altered to include whether the player 
received a 'bye' and the player's current *opponent match wins* (OMW). The following
is the table format for `player_standings` table *view* which is ordered by *wins*
then *omw*.
```
 id  |     name     | matches | wins | byes | omw
-----+--------------+---------+------+------+-----
 346 | Dick Solomon |       3 |    3 |    0 |   4
 342 | Bruno Walton |       3 |    2 |    0 |   4
 344 | Cathy Burton |       3 |    2 |    0 |   2
 348 | Alex Murphy  |       3 |    2 |    1 |   0
 343 | Boots O'Neal |       3 |    2 |    1 |   0
 345 | Diane Grant  |       3 |    1 |    1 |   0
 347 | John McClane |       3 |    0 |    0 |   0
(7 rows)
```

The *loser* parameter in the `reportMatch` function was altered to except `None`
or be omitted, thus giving the *winner* a 'bye'.

Old records do not need to be deleted for a new tournament. Use the `newTournament`
method to start recording results for a new tournament. ___SQL views___ are all designed
to access data from the most current tournament.

Methods access the current tournament ID and store this information with `INSERT`
commands.

## Instructions
1. **Virtual Machine setup:** 
Follow the instructions [here (on Google docs)](https://docs.google.com/document/d/16IgOm4XprTaKxAa8w02y028oBECOoB1EI1ReddADEeY/pub?embedded=true)
to set up the Vagrant virtual machine used in this project.

2. **Database setup:** 
The `tournament.sql` file contains all the code to set up the **Tournament** database, tables and views.
Run this file at the postgresql prompt:
    ```ssh
    vagrant@vagrant-ubuntu-trusty-32:/vagrant/tournament$ psql
    psql (9.3.6)
    Type "help" for help.
    vagrant=> \i tournament.sql   
    ``` 
3. **Running the test suite:** 
Leave the `psql` interface and run `tournament_test.py` from virtual machine prompt.

    ```ssh
    tournament=> \q
    vagrant@vagrant-ubuntu-trusty-32:/vagrant/tournament$ python tournament_test.py
    === 1 ===
    1. Old matches can be deleted.
    === 2 ===
    2. Player records can be deleted.
    === 3 ===
    3. After deleting, countPlayers() returns zero.
    ...
    ```

## Files
####`tournament.sql`
SQL code that creates a `tournament` database with tables and views. See next
section for database design.

####`tournament.py`
SQL database interface methods. Methods for deleting and creating tournaments,
players and matches and retreiving data.

####`tournament_test.py`
Test cases for `tournament.py` methods.



## Database Design
#### Tables
**`tournaments`** - Stores tournament ID, tournament title (optional) and date created.
```
 id | title | created
----+-------+---------
```

**`players`** - Stores player name and ID, and tournament ID.
```
 id | name | tournament_id
----+------+---------------
```

**`matches`** - Stores match ID number, tournament ID and round number.
```
 id | tournament_id | round | winner_id | loser_id
----+---------------+-------+-----------+----------
```

#### Views
**_`current_tournament`_** - A view with a single value showing the current
tournament ID.

**_`current_players`_** - A view of the players table only showing current
tournament participants. _Same columns as `players` table minus tournament_id._

**_`current_matches`_** - A view of the results table only showing current
tournament results. _**Similar** columns as `matches` table._
```
 id | round | winner_id | winner_name | loser_id | loser_name
----+-------+-----------+-------------+----------+------------
```

**_`current_player_wins`_** - A view of player ids and total current tournament wins.
```
 player_id | wins
-----------+------
```

**_`current_player_byes`_** - A view of player ids and total current tournament byes.
```
 player_id | byes
-----------+------
```

**_`current_player_wins`_** - A view of player ids and current tournament omw.
```
 player_id | omw
-----------+------
```

**_`player_standings`_** - A view showing each player's standings.
Relies on `players`, `results` tables and `match_details`, `player_omw` views.
```
 id  |     name     | matches | wins | byes | omw
-----+--------------+---------+------+------+-----
```



## References
- PostgreSQL.nabble.com
    - [How to auto enter current date for new record](http://postgresql.nabble.com/Automatic-date-time-td2135132.html)
- PostgreSQL.org
    - [Foreign key use example](http://www.postgresql.org/docs/8.0/static/tutorial-fk.html)
    - [Numeric types](http://www.postgresql.org/docs/9.1/static/datatype-numeric.html)
- StackOverflow.com
    - [Auto incrementing id example](http://stackoverflow.com/questions/7718585/how-to-set-auto-increment-primary-key-in-postgresql)
    - [How `serial` data type works](http://stackoverflow.com/a/18389891/1172891)
    - [How to install `psycopg2`](http://stackoverflow.com/a/24131582/1172891)
    - [Returning auto-generated ID from `INSERT` command](http://stackoverflow.com/a/2944335/1172891)
    - [How to `COUNT` only *true* values](http://stackoverflow.com/a/7258383/1172891)
    - [How to `zip` lists of unequal length in python](http://stackoverflow.com/questions/11318977/zipping-unequal-lists-in-python-in-to-a-list-which-does-not-drop-any-element-fro)
    - [Getting an accurate timestamp auto-entry](http://stackoverflow.com/a/9556581/1172891)
- Udacity.com
    - [How to sanitize `INSERT` data](https://www.udacity.com/course/viewer#!/c-ud197-nd/l-3483858580/e-3515398547/m-3515398548)
- Forums.MySQL.com
    - [Using `COALESCE` to create default value](http://forums.mysql.com/read.php?10,138370,138385#msg-138385)
