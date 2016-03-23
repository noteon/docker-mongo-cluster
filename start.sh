#!/bin/bash

# Create database directories
mkdir -p /data/db/rs1/db-001
mkdir -p /data/db/rs1/db-002
mkdir -p /data/db/rs1/db-003

mkdir -p /data/db/rs2/db-001
mkdir -p /data/db/rs2/db-002
mkdir -p /data/db/rs2/db-003

mkdir -p /data/db/cfg/db-001
mkdir -p /data/db/cfg/db-002
mkdir -p /data/db/cfg/db-003

# Run mongo replica sets rs1
mongod --replSet rs1 --port=27001 --dbpath=/data/db/rs1/db-001  --logpath=/var/log/mongodb/mongodb-rs1-001.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5 
mongod --replSet rs1 --port=27002 --dbpath=/data/db/rs1/db-002  --logpath=/var/log/mongodb/mongodb-rs1-002.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5
mongod --replSet rs1 --port=27003 --dbpath=/data/db/rs1/db-003  --logpath=/var/log/mongodb/mongodb-rs1-003.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5
mongo --port 27001 --eval 'rs.initiate({  
    _id : "rs1",  
     members : [  
         {_id : 0, host : "127.0.01:27001"},  
         {_id : 1, host : "127.0.01:27002"},  
         {_id : 2, host : "127.0.01:27003"}, 
     ] 
}); sleep(5000); printjson(rs.status());'

# Run mongo replica sets rs2
mongod --replSet rs2 --port=28001 --dbpath=/data/db/rs2/db-001  --logpath=/var/log/mongodb/mongodb-rs2-001.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5 
mongod --replSet rs2 --port=28002 --dbpath=/data/db/rs2/db-002  --logpath=/var/log/mongodb/mongodb-rs2-002.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5
mongod --replSet rs2 --port=28003 --dbpath=/data/db/rs2/db-003  --logpath=/var/log/mongodb/mongodb-rs2-003.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5
mongo --port 28001 --eval 'rs.initiate({  
    _id : "rs2",  
     members : [  
         {_id : 0, host : "127.0.01:28001"},  
         {_id : 1, host : "127.0.01:28002"},  
         {_id : 2, host : "127.0.01:28003"}, 
     ] 
}); sleep(5000);  printjson(rs.status());'

# Create some Config Servers
mongod --configsvr --port 26001 --dbpath /data/db/cfg/db-001 --logpath=/var/log/mongodb/mongodb-cfg1-001.log --fork --noprealloc --smallfiles
mongod --configsvr --port 26002 --dbpath /data/db/cfg/db-002 --logpath=/var/log/mongodb/mongodb-cfg1-002.log --fork --noprealloc --smallfiles
mongod --configsvr --port 26003 --dbpath /data/db/cfg/db-003 --logpath=/var/log/mongodb/mongodb-cfg1-003.log --fork --noprealloc --smallfiles 

#Create a Router
mongos --configdb 127.0.0.1:26001,127.0.0.1:26002,127.0.0.1:26003 --fork --logpath=/var/log/mongodb/mongodb-router.log 

#Initialize the Shard
mongo --eval 'sh.addShard("rs1/127.0.0.1:27001");sh.addShard("rs2/127.0.0.1:28001");printjson(sh.status());'

# Run mongo as the running process, this is required to keep the docker process running
mongo


