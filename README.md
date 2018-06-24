# Simple network monitor

### Requirements
- Server1 : Mongodb
- Server2 : Http/apache under Centos7
- Nethogs
- Iptraf
- Ruby
- Server3: RoR

### Setup
- Initialize mongo in your **Server1**
###
- Clone proyect in your Centos7 **Server2**
- Add mongo credentials in `.env` file
- Install requirements for ruby `ruby requirements.rb`
- Run script network_logs.rb `ruby network_logs.rb`
###
- Clone proyect in your **Server3** (only for RoR API)
- Move to dir `api_rails`
- Add mongo credentials in `.env` file
- Execute `bundle install` and `rails s` 
---
### Setup Docker environment
- **Server1 Mongo**
###
- Pull mongo image `docker pull mongo`
- Create container :
- `docker run -d --name=mongo -e MONGO_INITDB_ROOT_USERNAME=mongoadmin -e MONGO_INITDB_ROOT_PASSWORD=secret -p 27017:27017 mongo`
###
- Authenticate mongoadmin inside container : 
- `docker exec -ti mongo bash`
- `mongo -u mongoadmin -p secret --authenticationDatabase admin`
###
- Create bd : `use db_logs`
- Create user for mongo : `db.createUser({user: "user_logs", pwd: "pass123",roles: ["readWrite"]})`
---
- **Server 2 Centos7**
- Build image
- `docker build -t centos-http .`
###
- Create container
- `docker run -d --name=ruby_centos --link=mongo:mongo -p 80:80 -e MONGO_HOST=mongo -e MONGO_DB=db_logs -e PASSWD_MONGO=pass123 -e USER_MONGO=user_logs centos-http`
###
- Execute script **network_logs.rb**
- `docker exec -ti ruby_centos bash`
- `ruby /usr/src/app/network_logs.rb`
- **NOTE** : logs depend traficc in your system to generate.
---
- **Server3 RoR API**
- Move to `api_rails` dir
- Build image
- `docker build -t api_mongo .`
###
- Create container
- `docker run -d --name=api_rails_mongo -p 3000:3000 --link=mongo:mongo -e DB_NAME_MONGO=db_logs -e DB_USER_MONGO=user_logs -e DB_PASSWD_MONGO=pass123 -e HOST_MONGO=mongo api_mongo`
---
**Example response API**
###
<img src="https://i.imgur.com/IoluYrS.png" />

