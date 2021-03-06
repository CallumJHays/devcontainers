# devcontainers
Collection of devcontainers for use across multiple personal projects. Mainly Typescript, Python &amp; C/C++

## Usage

1. \[Optional] start apt cache server: `docker-compose up -d`
2. Mix and match stacks for your devcontainer:
```bash
# creates the image python3-node-devcontainer
# from the dockerfiles in the folders: `base > python3 > node`
make python3-node
```

3. Prepare the project-specific Dockerfile & devcontainer:
```Dockerfile
# ./Dockerfile
FROM callumjhays/python3-node-devcontainer

# python deps
COPY dev-requirements.txt .
COPY requirements.txt .
# debian apt-get deps
COPY dev-packages.txt .
COPY packages.txt .
# npm deps
COPY package.json .
COPY package-lock.json .

# install dev-dependencies
RUN apt-get update && \
    xargs -a packages.txt | apt-get install -y && \
    xargs -a dev-packages.txt | apt-get install -y && \
    rm -rf /var/lib/apt/lists/* && \
    npm install && \
    pip install -r requirements.txt -r dev-requirements.txt
```

```jsonc
// ./.devcontainer/devcontainer.json
{
    "dockerFile": "./Dockerfile",
    "remoteUser": "user",
    "workspaceFolder": "/home/user/workspace",
    "workspaceMount": "" // TODO
}
```

4. Develop in your devcontainer: https://code.visualstudio.com/docs/remote/containers


5. Release an optimized production build

```Dockerfile
# ./Dockerfile
FROM project-devcontainer as dev
# OR, just include it all in this one file as a multi-stage build (preferred)

# Create optimized build
RUN npm run build ./optimized

# Test the optimized build
RUN npm run test-build ./optimized

# rebase on lean production image
FROM python3-node-alpine as prod

# install production dependencies
# most apt pkgs are available in apk
RUN xargs -a packages.txt | apk add --update --no-cache

# copy production build from dev image
COPY --from=dev ./optimized .

# launch your application
CMD node app.js & \
    python app.py
```