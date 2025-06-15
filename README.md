### Postgres flexible server

-Postgres flexible server has been created in a resource group with private vnet access only and with dedicated managed subnet  
-the db needs to be initialized with an user. This requires VM and Bastion, unless risking exposed ssh port in VM. You can create the VM in adjacent subnet and install psql tool there. Because db is private vnet only, it cannot be accessed outside vnet, without the VM. Use bastion if private VM is to  
be used. The Bastion is the tool to connect private resources from VM without exposing ports.  No private endpoints are required, only peered vnets and link to private dns zone  

- sudo apt update & sudo apt install postgresql-client -y  
- psql -h your_db.postgres.database.azure.com -p 5432 -U your_user your_db_in_postgres
- \du, shows your current users  
- CREATE USER your_user WITH PASSWORD 'your_password';  
- GRANT USAGE ON SCHEMA your_schema TO your_user;  
- GRANT CREATE ON SCHEMA your_schema TO your_user;  
- the VM and Bastion can be destroyed afterwards.
- notice that DATABASE_URL, is fetched from kv and is in form of postgres://user:password@my_db.postgres.database.azure.com:5432/db.  
it would be better to fetch this on runtime from kv.
- Once the db is initialized with appropriate user and database url set, you can launch the app
