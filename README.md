Test-purpose all-in-one mongo cluster

# base image.
FROM mongo:3.2

# run it
docker run -itd -p 27017:27017  --name mongorcluster noteon/mongocluster