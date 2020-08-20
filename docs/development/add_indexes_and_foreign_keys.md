# Add Indexes and Foreign Keys to Aquarium

Please use these instructions to add indexes and foreign keys to your Aquarium database.  

We suggest you back up your database before you proceeding.  Be aware that adding foreign keys requires removing any orphan records in the database, so you risk losing data that if you do not back up your database before you begin.

---

## Getting Started - Backing up your Database

1. To make a database dump run the following:

    ```bash
    MYSQL_USER=<username>
    MYSQL_PASSWORD=<password>
    docker-compose up -d
    docker-compose exec db mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD production > production_dump.sql
    docker-compose down -v
    ```
    *Be sure to use the values of `MYSQL_USER` and `MYSQL_PASSWORD` from `.env`*

    Your database will be backed up on `production_dump.sql`


## Add Indexes and Foreign Keys


1. **Stop** Aquarium

   ```bash
   docker-compose down
   ```

2. **Run** the following script to remove orphan records

    ```bash
    ...
    ```

   *TODO: Add this.*

3. **Run** database migration file

    ```bash
    docker-compose up -d
    docker-compose exec app RAILS_ENV=production rake db:migrate
    docker-compose down -v
    ```

   *TODO: Review this. This did not work for me.*

4. **Restart** Aquarium

   ```bash
   docker-compose up
   ```
