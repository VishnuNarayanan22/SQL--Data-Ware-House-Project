/*
  Create Database and Schemas.

Script Purpose:
This script creates a new database named 'DataWarehouse after checking if it already exists.
If the database exists, it is dropped and recreated.
Additionally, the script sets up three schemas within the database: 'bronze, silver', and 'gold".

WARNING:
Running this script will drop the entire DataWarehouse' database if it exists. All data in the database will be permanently deleted.
Proceed with caution and ensure you have proper backups before running this script.
*/
  
Use master;
go

--Drop and ReCreate Database 'DataWareHouse'
if exists (select 1 from sys.databases where name = 'DataWareHouse')
Begin 
     alter DATABASE DataWareHouse set single_user with rollback immediate;
     Drop DATABASE DataWareHouse;
end;
--create database 'DataWareHouse'
create database DataWareHouse;

use DataWareHouse;

--Create Schema
create schema Bronze;
go
create schema Silver;
go
create schema Gold;
go
