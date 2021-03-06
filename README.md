This project contains the code used to exercise the concepts learned at the ]Docker and Kubernetes: The Complete Guide](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/learn/v4/content).

# The Dockerfiles

# Dockerfile.dev
docker-cli always look for a Dockerfile by default but we can specify a file using **-f** parameter.

The **Dockerfile.dev** will be used to run the stack:

*  npm run start
*  npm run test
*  npm run build

# Dockerfile

The **Dockerfile** will be used for production only and uses Multi-Step Docker Builds. Firstly it gets the node-alpine image, install the dependencies and run the build on the second phase. The s

The final result will be only the nginx with the build done by the previous step. The node_modules and src will not be copied.

# Tips & Comments on docker-cli and docker-compose commands
## docker attach

This command attaches to the primary process `stdin`, `stdout` and `stderr`.

## docker run -it <CONTAINER_ID> npm run test

This command runs the test phase, replace the default command, and attach our terminal to the container (`stdin`, `stdout` and `stderr`.), allowing us to interact with the test suite.

Keep in mind that running the `npm run test` as a service/container does not allow us to interact with the test suite because when you run `docker attach` or `docker run -it <CONTAINER_ID> sh`, we are attaching our terminal to the main process that is `npm` and not the test suite that is a subprocess of `npm`.

We could to execute the tests not as a service/container and in fact with `docker exec -it <CONTAINER_ID> npm run test` and with this approach we could manipulate the test suite because we would attach our terminal to the test suite.

## docker-compose and volume mapping
The command `COPY ./ ./` inside the **Dockerfile.dev** could be ommited because the docker-compose.yml is mapping the pwd/current folder into the container, so no need for copying instruction.
Despite that, we need to keep in mind that we are using docker-compose but for some reason, but we could stop to use that or alternatively we might decide to use this docker file for production, so in either case you would definitely still need to have this copy instruction right here. Even it is not needed for dev env, keep it as a reminder.

### Bookmarking on docker-compose or docker run -v

When mapping volumes, when we do not specify the `:`, we are putting a **bookmark** and saying to do not replace that volume inside the container.
For example, the sintax `.:/app` says to replace the current directory into /app directory inside the container.

## docker-compose policies
The restart policy is applied per service/container. The ones avaiable are:

| Policy | Definition | Additional comments |
|---|---|---|
|"no"|Never attempt to restart if container stops or crashes.|Has to be specified with quotes as 'no' because no is interpreted as boolean FALSE|
|always|For any reason, attemp to restart||
|on-failure|Only restarts if container stops with an error code|If 0 is passed, it will not be restart cause 0 is fine: <ul><li>0 - exited and everything is OK</li><li>1, 2, 3 etc - exited because something went wrong</li></ul>|
|unless-stopped|Restart unless we forcibly stop it.||

## docker-compose.yml definitions

On `web` service, the `build` step could specify a `.` as its value but it would look for a file called **Dockerfile**. Since we want to execute that with the **Dockerfile.dev** file, we need to replace the `build: .` per a complex object where we specify the context and the file name.

```yml
...
services: 
    web:
        build: 
            context: .
            dockerfile: Dockerfile.dev
...
```

## Some docker-compose and docker comparisions

|docker-compose command|docker command|Comment|
|---|---|---|
|docker-compose build|docker build .|Only builds the images, not starting the container.|
|docker-compose up -d|docker run -d myimage|Builds the images if the images do not exist and starts the containers.<br/>**If the Dockerfile is changed, the images are NOT reconstructured.**|
|docker-compose up --build|docker build . & docker run myimage|On docker-compose, forces the build even when not needed.<br/>On docker, it will use the cache as needed.|
|docker-compose up --no-build|Skips the image build process.||
|docker-compose down||Stop and remove all containers created|
|docker-compose stop||Stop docker containers related to the services specified|
|docker-compose ps|~= docker ps|On docker-compose world, only on folder that has the **docker-compose.yml** file since it will focus on the services/containers specified.|

# Using Multi-Step Docker Builds
Any single block can have only one FROM statement.

## nginx on Dockerfile - Second Phase

The default command of nginx image is to start the nginx, so no need for that putting a `CMD`.

# Travis-CI

## Account and Link
Create your account on [Travis CI](https://travis-ci.org) and after that, link to your GitHub account.

After making this link, turn on the integration with the repository you needed. The repository shoulf be a public one.

## Config file
After the link between your Travis Account and GitHub repository, you need the specify a config file for Travis, **.travis.yml**.

## Deploy
**Travis-CI** comes pre-configured to deploy your application to a handfull of different providers (Azuze, AWS, Digital Ocean etc).

*  elasticbeanstalk - provider for AWS Elastic Beanstalk

A S3 bucket is created automatically when you setup your application and environment on AWS console.
This S3 bucket is reused for all different elastic beanstalk environments you have created. When creating the environment, it is not common to have the "bucket_path" (the folder that represents your application with app name).

## Commiting on Branch

Commiting on a branch and creating a merge request to master will drive us into a two checks dispatched by **Travis-CI**: 

*  1st - The fact that we just pushed some code up to GitHub
*  2nd - Kind of fate merging our code into the master branch and then running our tests

So one set of tests right here was to say that the code was pushed by itself is valid and that was pushed merge to master is valid as well.

After seeing both of them as succeeded, we can merge the pull request, and as soon as we merge this **Travis-CI** will run again our tests, for the 3rd time (1st for feature branch, 2nd for pull request and 3rd for master), and then, after it because it is a change that was issued to the master branch, it is going to automatically attempt to deploy our application over to **Beanstalk**.
 
# AWS Elastic Beanstalk

We setup an automatic deploy over AWS (it could be Azure, Digital Ocean etc).

**AWS Elastic Beanstalk** is easiest way to get started with production docker instances. Is most appropriate when you are running exactly one container at a time. We can start up multiple copies of the same container but at the end of the day, is the easiest way to run one single container.

Automatically scales for us when needs more resources.

## Port exposition
The exposition of ports are different. We need to put the `EXPOSE` sintax inside the **Dockerfile**.
In most environments the `EXPOSE` is really supposed to be communication between developers to let them know that this container is supposed to need a port mapping on port that is configured on `EXPOSE`.
By the default, on our machines, it does not anything for us automatically.

For Elastic Beanstalk, it is different, it will look for `EXPOSE` and map them, automatically.

## Build Still Failing?

Seção 7, aula 93
If you still see a failed deployment, try the following two steps:

Fix One:
The `npm install` command frequently times out on the `t2.micro` instance that we are using.  An easy fix is to bump up the instance type that Elastic Beanstalk is using to a `t2.small`.
Note that a `t2.small` is outside of the free tier, so you will pay a tiny bit of money (likely less than one dollar if you leave it running for a few hours) for this instance.  Don't forget to close it down!  Directions for this are a few videos ahead in the lecture titled **Environment Cleanup**.

Fix Two:
Try editing the 'COPY' line of your Dockerfile like so:

`COPY package*.json ./`

Sometimes AWS has a tough time with the `'.'` folder designation and prefers the long form `./`.