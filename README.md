# SetUp

## Install Postgressql 
```
sudo apt install postgresql postgresql-contrib
```

## start the Postgresql server
```
sudo systemctl start postgresql.service
```
## Create a Database for the project 

Login into the psql shell as a postgres user.
```
sudo -u postgres psql
```
Create a Databse.
```
Create Database IPLDataProject;
```
Exit the psql shell
```
\q
```
### clone the repo
```
git clone git@github.com:shivapittala19/data-project-database.git
```
Make sure to download the sql files,place in the correct path and also check the user postgres has the rights to read the data.
### Run the sql file 

Navigate to a.sql file in the terminal  and run the following command.

```
sudo psql -h 127.0.0.1 -d IPLDataProject -U postgres 5432 -a -q -f a.sql
```