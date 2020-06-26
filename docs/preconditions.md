## <a id=preconditions></a> Preconditions for Using the MMS Example for ML model updates

If you haven't done so already, you must complete these steps before proceeding with the MMS example for ML model updates

1. Install (or gain access to) the IBM Edge Application Manager (IEAM) infrastructure (Horizon Exchange and Agbot).

2. Install the Horizon agent on your edge device and configure it to point to your Horizon Exchange. See [Preparing an edge device](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.0/devices/installing/adding_devices.html) for details.

3. Set your Exchange organization variable:

```bash
export HZN_ORG_ID="<your-cluster-name>"
```

4. Create a cloud API key that is associated with your Horizon instance, set your Exchange user credentials, and verify them:

```bash
export HZN_EXCHANGE_USER_AUTH="iamapikey:<your-API-key>"

hzn exchange user list
```

5. Choose an ID and token for your edge node, create it, and verify it:

```bash
export HZN_EXCHANGE_NODE_AUTH="<choose-any-node-id>:<choose-any-node-token>"

hzn exchange node create -n $HZN_EXCHANGE_NODE_AUTH

hzn exchange node confirm
```

6. Create a cryptographic signing key pair. This enables you to sign services when publishing them to the exchange.

```bash
hzn key create "<companyname>" "<youremailaddress>"
```
__Note__: You only need to do this step one time.

7. Install Docker and create a [Docker Hub](https://hub.docker.com/) ID. This is required because the instructions in this section include publishing your service container image to Docker Hub.

- Log in to Docker Hub using your Docker Hub ID:
```bash
export DOCKER_HUB_ID="<dockerhubid>"
echo "<dockerhubpassword>" | docker login -u $DOCKER_HUB_ID --password-stdin
```

8. Install a few development tools:

	On __linux__

```bash
sudo apt install -y git jq make
```
## Building and Publishing the MMS Example for ML model updates

1. Clone this git repository:

```bash
cd ~   # or wherever you want
git clone https://github.com/jiportilla/img-MMS.git
cd ~/img-MMS/
```

2. Set the values in `horizon/hzn/json` to your liking. These variables are used in the service and MMS metadata `object.json` files. They are also used in some of the commands in this procedure. After editing `horizon/hzn.json`, set the variables in your environment:

```bash
export ARCH=$(hzn architecture)
eval $(hzn util configconv -f horizon/hzn.json)
```

3. Build the docker image:

```bash
make build
```

For example, when using the default values provided in this demo [hnz.json](https://raw.githubusercontent.com/jiportilla/img-MMS/master/horizon/hzn.json) configuration file:

```bash
docker build -t iportilla/image.demo-mms_amd64:1.0.0 -f ./Dockerfile.amd64 .
```

3. You are now ready to publish your edge service, so that it can be deployed to real edge nodes. Instruct Horizon to push your docker image to your registry and publish your service in the Horizon Exchange:

```bash
hzn exchange service publish -f horizon/service.definition.json
hzn exchange service list
```

See [preparing to create an edge service](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.0/devices/developing/service_containers.html) for additional details.

## Using this Example Edge Service with Deployment Policy

The Horizon Policy mechanism offers an alternative to using Deployment Patterns. Policies provide much finer control over the deployment placement of edge services. Policies also provide a greater separation of concerns, allowing Edge Nodes owners, Service code developers, and Business owners to each independently articulate their own Policies. There are three types of Horizon Policies:

1. Node Policy (provided at registration time by the node owner)

2. Service Policy (may be applied to a published Service in the Exchange)

3. Business Policy (which approximately corresponds to a Deployment Pattern)

### Node Policy

- As an alternative to specifying a Deployment Pattern when you register your Edge Node, you may register with a Node Policy.


1. Below is the file provided in `horizon/node_policy.json` with this example:

```json
{
  "properties": [
    {
      "name": "sensor",
      "value": "camera"
    },
    {
      "name": "location",
      "value": "storage"
    }
  ],
  "constraints": []
}
```

- It provides values for two `properties` (`sensor` and `location`), that will affect which service(s) get deployed to this edge node, and states no `constraints` .

The node registration step will be completed in the next section.


### Service Policy

Like the other two Policy types, Service Policy contains a set of `properties` and a set of `constraints`. The `properties` of a Service Policy could state characteristics of the Service code that Node Policy authors or Business Policy authors may find relevant. The `constraints` of a Service Policy can be used to restrict where this Service can be run. The Service developer could, for example, assert that this Service requires a particular hardware setup such as CPU/GPU constraints, memory constraints, specific sensors, actuators or other peripheral devices required, etc.


1. Below is the file provided in  `horizon/service_policy.json` with this example:

```json
{
  "properties": [],
  "constraints": [
       "sensor == camera"
  ]
}
```

- Note this simple Service Policy does not provide any `properties`, but it does have a `constraint`. This example `constraint` is one that a Service developer might add, stating that their Service must only run on sensors named `camera`. If you recall the Node Policy we used above, the sensor `property` was set to `camera`, so this Service should be compatible with our Edge Node.

2. If needed, run the following commands to set the environment variables needed by the `service_policy.json` file in your shell:
```bash
export ARCH=$(hzn architecture)
eval $(hzn util configconv -f horizon/hzn.json)
```

3. Optionally, add or replace the service policy in the Horizon Exchange for this Example service:

```bash
make publish-service-policy
```
For example:
```bash
hzn exchange service addpolicy -f horizon/service_policy.json image.demo-mms_1.0.0_amd64

```

4. View the pubished service policy attached to `image.demo-mms` edge service:

```bash
hzn exchange service listpolicy image.demo-mms_1.0.0_amd64
```

- Notice that Horizon has again automatically added some additional `properties` to your Policy. These generated property values can be used in `constraints` in Node Policies and Business Policies.

- Now that you have set up the Policy for your Edge Node and the published Service policy is in the exchange, we can move on to the final step of defining a Business Policy to tie them all together and cause software to be automatically deployed on your Edge Node.


### Business Policy

Business Policy (sometimes called Deployment Policy) is what ties together Edge Nodes, Published Services, and the Policies defined for each of those, making it roughly analogous to the Deployment Patterns you have previously worked with.

Business Policy, like the other two Policy types, contains a set of `properties` and a set of `constraints`, but it contains other things as well. For example, it explicitly identifies the Service it will cause to be deployed onto Edge Nodes if negotiation is successful, in addition to configuration variable values, performing the equivalent function to the `-f horizon/userinput.json` clause of a Deployment Pattern `hzn register ...` command. The Business Policy approach for configuration values is more powerful because this operation can be performed centrally (no need to connect directly to the Edge Node).

1. Below is the file provided in  `horizon/business_policy.json` with this example:

```json
{
  "label": "Business policy for $SERVICE_NAME",
  "description": "A super-simple image demo with Horizon MMS updates",
  "service": {
    "name": "$SERVICE_NAME",
    "org": "$HZN_ORG_ID",
    "arch": "$ARCH",
    "serviceVersions": [
      {
        "version": "$SERVICE_VERSION",
        "priority":{}
      }
    ]
  },
  "properties": [],
  "constraints": [
        "location == backyard"
  ],
  "userInput": [
    {
      "serviceOrgid": "$HZN_ORG_ID",
      "serviceUrl": "$SERVICE_NAME",
      "serviceVersionRange": "[0.0.0,INFINITY)",
      "inputs": [
      ]
    }
  ]
}
```

- This simple example of a Business Policy provides one `constraint` (`location`) that is satisfied by one of the `properties` set in the `node_policy.json` file, so this Business Policy should successfully deploy our Example Service onto the Edge Node.

- At the end, the userInput section has the same purpose as the `horizon/userinput.json` files provided for other examples if the given services requires them. In this case the example service defines does not have configuration variables.

2. If needed, run the following commands to set the environment variables needed by the `business_policy.json` file in your shell:
```bash
export ARCH=$(hzn architecture)
eval $(hzn util configconv -f horizon/hzn.json)

optional: eval export $(cat agent-install.cfg)
```

3. Publish this Business Policy to the Exchange to deploy the `image.demo-mms` service to the Edge Node (give it a memorable name):

```bash
make publish-business-policy
```

For example:
```bash
hzn exchange business addpolicy -f horizon/business_policy.json image.demo-mms.bp

```

4. Verify the business policy:

```bash
hzn exchange business listpolicy image.demo-mms.bp
```
- The results should look very similar to your original `business_policy.json` file, except that `owner`, `created`, and `lastUpdated` and a few other fields have been added.

You are now ready to register your node with policy and continue this example.

- [Using the ML MMS Example with deployment policy](using-image-mms-policy.md)

