# For production environment
# Using Multi-Step Docker Builds
# Build Phase and Run Phase
FROM node:10.15-alpine AS builder
WORKDIR '/app'
COPY package.json ./
RUN npm install
COPY ./ ./
RUN npm run build

# Specifying the second phase
# /usr/share/nginx/html is the default content static directory
# The final result will be only the nginx with the build done by the previous step.
# The node_modules and src will not be copied.
FROM nginx

# In most envs, used as a communication between developers but for AWS Elastic Beanstalk,
# it is used to map port automatically.
EXPOSE 80

COPY --from=builder /app/build /usr/share/nginx/html

# The default command of nginx image is to start the nginx, so no need for that
#CMD [""]
