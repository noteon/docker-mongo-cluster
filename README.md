#
# MongoDB Dockerfile
#
# https://github.com/dockerfile/mongodb
#

# Pull base image.
FROM mongo:3.2

# Define mountable directories.
VOLUME ["/data/db"]

# Define working directory.
WORKDIR /

# Expose ports for each Mongo replica set instance
EXPOSE 27017
EXPOSE 27018
EXPOSE 27019

# Copy required files over to container
COPY conf/ /conf/
COPY start.sh /start.sh

# Run start shell when container launches
CMD ["sh", "start.sh"]
