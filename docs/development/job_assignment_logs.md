# Add Job Assignment Tables to Aquarium

Please use these instructions to add the job assignment tables to your Aquarium database.

We suggest you back up your database before you proceeding.

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
    *Be sure to use the values of `MYSQL_USER` and `MYSQL_PASSWORD` from `.env`*

    Your database will be backed up on `production_dump.sql`


## Add Job Assignment Tables


1. **Stop** Aquarium

   ```bash
   docker-compose down -v
   ```

2. **Run** the following database migration file to add the tables

    ```bash
    docker-compose run --rm app rake db:migrate VERSION=20200910000000
    ```

3. **Restart** Aquarium

    ```bash
    docker-compose up
    ```
