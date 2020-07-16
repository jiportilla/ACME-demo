# Creating Your Own Hello World Edge Service

Follow the steps in this page to create your first simple Horizon edge service.

## Preconditions for Developing Your Own Service

1. If you have not already done so, complete the steps in these sections:

  - [Preconditions for Using the Hello World Example Edge Service](README.md#preconditions)
  - [Using the Hello World Example Edge Service with Deployment Pattern](README.md#using-helloworld-pattern)

2. If you are using macOS as your development host, configure Docker to store credentials in `~/.docker`:

  - Open the Docker **Preferences** dialog
  - Uncheck **Securely store Docker logins in macOS keychain**

3. If you do not already have a docker ID, obtain one at https://hub.docker.com/ . Log in to Docker Hub using your Docker Hub ID:

  ```bash
  export DOCKER_HUB_ID="<dockerhubid>"
  echo "<dockerhubpassword>" | docker login -u $DOCKER_HUB_ID --password-stdin
  ```

  Output example:

  ```bash
  WARNING! Your password will be stored unencrypted in /home/pi/.docker/config.json.
  Configure a credential helper to remove this warning. See
  https://docs.docker.com/engine/reference/commandline/login/#credentials-store

  Login Succeeded
  ```

4. Create a cryptographic signing key pair. This enables you to sign services when publishing them to the exchange. **This step only needs to be done once.**

  ```bash
  hzn key create "<x509-org>" "<x509-cn>"
  ```

  where `<x509-org>` is your company name, and `<x509-cn>` is typically set to your email address.

5. Install `git` and `jq`:

  On **Linux**:

  ```bash
  sudo apt install -y git jq
  ```

  On **macOS**:

  ```bash
  brew install git jq
  ```

## <a id=build-publish-your-hw> Building and Publishing Your Own Hello World Example Edge Service

1. `cd` to the directory in which you want to create your new service and then run this command to create the files for a simple edge service and associated Horizon metadata files:

  ```bash
  hzn dev service new -s myhelloworld -i "$DOCKER_HUB_ID/myhelloworld"
  ```

  Notice that some project variables are defined in `horizon/hzn.json` and referenced in other files, for example `horizon/service.definition.json`.

2. Edit `service.sh` and change something simple, for example change "Hello" to "Hey there"

  Note: This service is a shell script for brevity, but you can write your service in any language.

3. Build the service docker image:

  ```bash
  make
  ```

4. Test the service by running it the simulated agent environment:

  ```bash
  hzn dev service start -S
  ```

5. Check that the container is running:

  ```bash
  sudo docker ps
  ```

6. Display the environment variables Horizon passes into your service container:

  ```bash
  sudo docker inspect $(sudo docker ps -q --filter name=myhelloworld) | jq '.[0].Config.Env'
  ```

7. See your helloworld service output:

   on **Linux**:

   ```bash
   sudo tail -f /var/log/syslog | grep myhelloworld[[]
   ```

   on **Mac**:

   ```bash
   sudo docker logs -f $(sudo docker ps -q --filter name=myhelloworld)
   ```

8. Stop the service:

  ```bash
  hzn dev service stop
  ```

9. Instruct Horizon to push your docker image to your registry and publish your service in the Horizon Exchange:

  ```bash
  hzn exchange service publish -f horizon/service.definition.json
  hzn exchange service list
  ```

## Publishing Policy Files For Your Hello World Example Edge Service

1. Get the required deployment, service, and node policy files to to deploy your new `helloworld` service to you edge node:
  ```bash
  wget https://raw.githubusercontent.com/open-horizon/examples/master/edge/services/helloworld/policy/node.policy.json
  wget https://raw.githubusercontent.com/open-horizon/examples/master/edge/services/helloworld/policy/service.policy.json
  wget https://raw.githubusercontent.com/open-horizon/examples/master/edge/services/helloworld/policy/deployment.policy.json
  ```
2. Set the required environment variables:
  ```bash
  eval $(hzn util configconv -f horizon/hzn.json)
  export ARCH=$(hzn architecture)
  ```

2. Publish and view your service policy in the Horizon Exchange:
  ```bash
  hzn exchange service addpolicy -f service.policy.json ${HZN_ORG_ID}/${SERVICE_NAME}_${SERVICE_VERSION}_${ARCH}
  hzn exchange service listpolicy ${HZN_ORG_ID}/${SERVICE_NAME}_${SERVICE_VERSION}_${ARCH}
  ```

3. Publish and view your deployment policy in the Horizon Exchange:
  ```bash
  hzn exchange deployment addpolicy -f deployment.policy.json ${HZN_ORG_ID}/policy-${SERVICE_NAME}_${SERVICE_VERSION}
  hzn exchange deployment listpolicy ${HZN_ORG_ID}/policy-${SERVICE_NAME}_${SERVICE_VERSION}
  ```

4. Register your edge device with the node policy:
  ```bash
  hzn register --policy node.policy.json
  ```
  
5. The edge device will make an agreement with one of the Horizon agreement bots (this typically takes about 15 seconds). Repeatedly query the agreements of this device until the `agreement_finalized_time` and `agreement_execution_start_time` fields are filled in:

  ```bash
  hzn agreement list
  ```

6. After the agreement is made, list the docker container edge service that has been started as a result:

  ```bash
  sudo docker ps
  ```

7. See the myhelloworld service output:

  ``` bash
  hzn service log -f myhelloworld
  ```

8. Unregister your edge device (which will also stop the myhelloworld service):

  ```bash
  hzn unregister -f
  ```
  
## Publishing A Pattern For Your Hello World Example Edge Service

1. Publish and view your edge node deployment pattern in the Horizon Exchange:

  ```bash
  hzn exchange pattern publish -f horizon/pattern.json
  hzn exchange pattern list
  ```

2. Register your edge node with Horizon to use your deployment pattern:

  ```bash
  hzn register -p pattern-myhelloworld-$(hzn architecture)
  ```

3. The edge device will make an agreement with one of the Horizon agreement bots (this typically takes about 15 seconds). Repeatedly query the agreements of this device until the `agreement_finalized_time` and `agreement_execution_start_time` fields are filled in:

  ```bash
  hzn agreement list
  ```

4. After the agreement is made, list the docker container edge service that has been started as a result:

  ```bash
  sudo docker ps
  ```

5. See the myhelloworld service output:

``` bash
hzn service log -f myhelloworld
```

6. Unregister your edge node (which will also stop the myhelloworld service):

  ```bash
  hzn unregister -f
  ```
