#!/bin/bash

# This cleans everything - our other commands do the same thing but peicemeal.
# Remove all unused containers, networks, images (both dangling and unreferenced), and optionally,
# volumes.
#docker system prune -a

# Removes all stopped containers.
docker container prune

# Remove all dangling images. 
# If -a is specified, will also remove all images not referenced by any container.
docker image prune -a
# Old version to remove dangling images
#   docker rmi $(docker images --filter dangling=true -q) #test comment

# Remove all unused local volumes. Unused local volumes are those which are not referenced by any
# containers
docker volume prune
# Old version to remove dangling volumes
#   docker volume rm $(docker volume ls -f dangling=true -q)

# Remove unused networks
docker network prune



