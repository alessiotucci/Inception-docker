# inception-42-just-docker-

![image](https://github.com/alessiotucci/inception-42-just-docker-/assets/116757689/917ed324-aa10-4d6a-a838-6c7373acbb5c)


You also have to write your own Dockerfiles, one per service. The Dockerfiles must
be called in your docker-compose.yml by your Makefile.
It means you have to build yourself the Docker images of your project. It is then for-
bidden to pull ready-made Docker images, as well as using services such as DockerHub
