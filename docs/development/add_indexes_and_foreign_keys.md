# Add Indexes and Foreign Keys to Aquarium

Please use these instructions to add indexes and foreign keys to your Aquarium database.

We suggest you back up your database before you proceeding. Be aware that adding foreign keys requires removing any orphan records in the database, so you risk losing data if you do not back up your database before you begin.

---

## Getting Started - Backing up your Database

1. To make a database dump run the following:

   ```bash
   MYSQL_USER=<username>
   MYSQL_PASSWORD=<password>
   docker-compose up -d db
   docker-compose exec db mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD production > production_dump.sql
   docker-compose down -v
   ```

   _Be sure to use the values of `MYSQL_USER` and `MYSQL_PASSWORD` from `.env`_

   Your database will be backed up on `production_dump.sql`

## Add Indexes and Foreign Keys

1. **Stop** Aquarium

   ```bash
   docker-compose down -v
   ```

2. **Run** the database migrations

    ```bash
    docker-compose run --rm app rake db:migrate
    ```


3. **Restart** Aquarium

   ```bash
   docker-compose up
   ```
