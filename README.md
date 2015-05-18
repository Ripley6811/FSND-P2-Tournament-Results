Tournament Project
==================

### Summary
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
The `reportMatch` function was altered to except `None` or be omitted for *loser*,
this giving the *winner* a 'bye'.

### Instructions
1. **Virtual Machine setup:** 
Follow the instructions [here (on Google docs)](https://docs.google.com/document/d/16IgOm4XprTaKxAa8w02y028oBECOoB1EI1ReddADEeY/pub?embedded=true)
to set up the Vagrant virtual machine used in this project.

2. **Database setup:** 
The `tournament.sql` file contains all the code to set up the **Tournament** database, tables and views.
    ```ssh
    vagrant@vagrant-ubuntu-trusty-32:/vagrant/tournament$ psql
    psql (9.3.6)
    Type "help" for help.
    vagrant=> \i tournament.sql   
    ``` 
3. **Running test suite:** 
Leave the `psql` interface and run tournament_test.py for virtual machine prompt.

    ```ssh
    tournament=> \q
    vagrant@vagrant-ubuntu-trusty-32:/vagrant/tournament$ python tournament_test.py
    1. Old matches can be deleted.
    2. Player records can be deleted.
    3. After deleting, countPlayers() returns zero.
    ...
    ```

### Database Design
**`players`** - Stores player name and database ID.
```
 id | name
----+------
```

**`tournaments`** - Stores tournament id, tournament name and date created.
```
 id | title | created
----+-------+---------
```

**`tournament_register`** - Stores a tournament id and player id combination for
storing who has signed up for particular tournaments.
```
 tournament_id | player_id
---------------+-----------
```

**`matches`** - Stores match id number, tournament id and round number.
```
 id | tournament_id | round
----+---------------+-------
```

**`results`** - Stores the match id, player id and whether they lost or won.
```
 match_id | player_id | winner
----------+-----------+--------
```

**_`match_details`_** - A view showing all information for a particular match.
Relies on `players`, `matches` and `results` tables.
```
 match_id | tournament_id | round | winner_id | winner | loser_id | loser
----------+---------------+-------+-----------+--------+----------+-------
```

**_`player_OMW`_** - A view for calculating each player's OMW (opponent match wins).
Relies on `match_details` view and `results` table.
```
 winner | omw
--------+-----
```

**_`player_standings`_** - A view for showing each player's standings.
Relies on `players`, `results` tables and `match_details`, `player_omw` views.
```
 id  |     name     | matches | wins | byes | omw
-----+--------------+---------+------+------+-----
```



### References
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
    - [How to `zip` lists of unequal length](http://stackoverflow.com/questions/11318977/zipping-unequal-lists-in-python-in-to-a-list-which-does-not-drop-any-element-fro)
- Udacity.com
    - [How to sanitize `INSERT` data](https://www.udacity.com/course/viewer#!/c-ud197-nd/l-3483858580/e-3515398547/m-3515398548)
- Forums.MySQL.com
    - [Using `COALESCE` to create default value](http://forums.mysql.com/read.php?10,138370,138385#msg-138385)
