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
mongo --port 27001 --eval 'var rst=rs.initiate();sleep(5000); rs.add(rst.me.replace("27001","27002"));sleep(1000);rs.add(rst.me.replace("27001","27003"));sleep(1000); printjson(rs.status());'

# Run mongo replica sets rs2
mongod --replSet rs2 --port=28001 --dbpath=/data/db/rs2/db-001  --logpath=/var/log/mongodb/mongodb-rs2-001.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5 
mongod --replSet rs2 --port=28002 --dbpath=/data/db/rs2/db-002  --logpath=/var/log/mongodb/mongodb-rs2-002.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5
mongod --replSet rs2 --port=28003 --dbpath=/data/db/rs2/db-003  --logpath=/var/log/mongodb/mongodb-rs2-003.log --fork  --noprealloc --smallfiles --nojournal --oplogSize=5
mongo --port 28001 --eval 'var rst=rs.initiate();sleep(5000); rs.add(rst.me.replace("28001","28002"));sleep(1000);rs.add(rst.me.replace("28001","28003"));sleep(1000); printjson(rs.status());'


# Create some Config Servers
mongod --configsvr --port 26001 --dbpath /data/db/cfg/db-001 --fork --noprealloc --smallfiles --nojournal   
mongod --configsvr --port 26002 --dbpath /data/db/cfg/db-001 --fork --noprealloc --smallfiles --nojournal
mongod --configsvr --port 26003 --dbpath /data/db/cfg/db-001 --fork --noprealloc --smallfiles --nojournal 

#Create a Router
mongos --port 27017 --configdb localhost:26001, localhost:26002, localhost:26003 --fork

#Initialize the Shard
mongo --port 27017 --eval 'sh.addShard("rs1/localhost:27001");sh.addShard("rs1/localhost:28001");sleep(2000);sh.status();'

# Run mongo as the running process, this is required to keep the docker process running
mongo

