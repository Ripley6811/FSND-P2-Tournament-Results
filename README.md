Tournament Project
==================

### Instructions
1. **Virtual Machine setup:** 
Follow the instructions [here (on Google docs)](https://docs.google.com/document/d/16IgOm4XprTaKxAa8w02y028oBECOoB1EI1ReddADEeY/pub?embedded=true)
to set up the Vagrant virtual machine used in this project.

2. **Database setup:** 
The `tournament.sql` file contains all the code to set up the **Tournament** database, tables and views.

```vagrant@vagrant-ubuntu-trusty-32:/vagrant/tournament$ psql
    psql (9.3.6)
    Type "help" for help.
    vagrant=> \i tournament.sql   ``` 

3. **Running test suite:** Leave the `psql` interface and run tournament_test.py for virtual machine prompt.
```vagrant@vagrant-ubuntu-trusty-32:/vagrant/tournament$ python tournament_test.py```





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
- Udacity.com
    - [How to sanitize `INSERT` data](https://www.udacity.com/course/viewer#!/c-ud197-nd/l-3483858580/e-3515398547/m-3515398548)
- Forums.MySQL.com
    - [Using `COALESCE` to create default value](http://forums.mysql.com/read.php?10,138370,138385#msg-138385)
