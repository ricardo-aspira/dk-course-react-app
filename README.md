# The Dockerfiles

# Dockerfile.dev
docker-cli always look for a Dockerfile by default but we can specify a file using **-f** parameter.

The Dockerfile.dev will be used to run the stack:

*  npm run start
*  npm run test
*  npm run build

# Tips & Comments on docker-cli and docker-compose commands
## docker attach

This command attaches to the primary process `stdin`, `stdout` and `stderr`.

## docker run -it <CONTAINER_ID> npm run test

This command runs the test phase, replace the default command, and attach our terminal to the container (`stdin`, `stdout` and `stderr`.), allowing us to interac with the test suite.

Keep in mind that running the `npm run test` as a container does not allow us to interact with the test suite because when you run `docker attach` or `docker run -it <CONTAINER_ID> sh`, we are attaching our terminal to the main process that is `npm` and not the test suite that is a subprocess of `npm`.

## docker-compose and volume mapping
The command `COPY ./ ./` inside the **Dockerfile.dev** could be ommited because the docker-compose.yml is mapping the pwd/current folder into the container, so no need for copying instruction.
Despite that, we need to keep in mind that we are using docker-compose but for some reason, but we could stop to use that or alternatively we might decide to use this docker file for production, so in either case you would definitely still need to have this copy instruction right here. Even it is not needed for dev env, keep it as a reminder.

## docker-compose policies
The restart policy is applied per service/container. The ones avaiable are:

| Policy | Definition | Additional comments |
|---|---|---|
|"no"|Never attempt to restart if container stops or crashes.|Has to be specified with quotes as 'no' because no is interpreted as boolean FALSE|
|always|For any reason, attemp to restart||
|on-failure|Only restarts if container stops with an error code|If 0 is passed, it will not be restart cause 0 is fine:
*  0 - exited and everything is OK
*  1, 2, 3 etc - exited because something went wrong|
|unless-stopped|Restart unless we forcibly stop it.||

# web / build . -> will look for the Dockerfile to run the build,
# but since we do not have the Dockerfile, we have the Dockerfile.dev
# we need to replace "build: ." with the sintax below

## Some 

# docker-compose build = docker build .
#    The one only builds the images, does not start the container.
# docker-compose up -d = docker run -d myimage
#    This one builds the images if the images do not exist and starts the containers.
#    If the Dockerfile is changed, the images are NOT reconstructured.
# docker-compose up --build = docker build . & docker run myimage
#    This one forces the build even when not needed.
# docker-compose up --no-build
#    This one skips the image build process
# docker-compose down = docker stop and remove all containers created
# docker-compose stop = docker stop services
# docker-compose ps ~= docker ps
#    For the docker-compose.yml in the folder where the file exists

# restart policies per service/container
# "no" - never attempt to restart if container stops or crashes
#        has to be specified with quotes as 'no' because no is interpreted as boolean FALSE
# always - for any reason, attemp to restart
# on-failure - only restart if container stops with an error code
#              if 0 is passed, it will not be restart cause 0 is fine
#              0 - exited and everything is OK
#              1, 2, 3 etc - exited because something went wrong
# unless-stopped - restart unless we forcibly stop it

# In the volumes, when you do not specify the :, you are putting a bookmark and saying
# to do not replace that volume inside the container.
# The .:/app says to replace the current directory into /app directory inside the container.

# We could to execute the tests not as a service/container and in fact with 
# "docker exec -it <CONTAINER_ID> npm run test" so in that way, we could manipulate the
# test suite because we would attach our terminal to the test suite.
# As a service, we cannot attach to that process because npm is the default command,
# so the npm starts other process to run the test and the "docker attach <CONTAINER_ID>""
# would be able to attach the terminal to npm process only, not to the test suite




# Using Multi-Step Docker Builds
Any single block can have only one FROM statement.

## nginx on Dockerfile - Second Phase

The default command of nginx image is to start the nginx, so no need for that putting a `CMD`.