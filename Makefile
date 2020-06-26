# Make targets for building the TF.js example image analysis MMS edge service.

# This imports the variables from horizon/hzn.json. You can ignore these lines, but do not remove them.
-include horizon/.hzn.json.tmp.mk

# Transform the machine arch into some standard values: "arm", "arm64", or "amd64"
SYSTEM_ARCH := $(shell uname -m | sed -e 's/aarch64.*/arm64/' -e 's/x86_64.*/amd64/' -e 's/armv.*/arm/')

# To build for an arch different from the current system, set this env var to one of the values in the comment above
#export ARCH ?= $(SYSTEM_ARCH)

# Default ARCH to the architecture of this machines (as horizon/golang describes it)
export ARCH ?= $(shell hzn architecture)

DOCKER_IMAGE_BASE ?= iportilla/image.demo-mms
SERVICE_NAME ?=image.demo-mms
SERVICE_VERSION ?=1.0.0
PORT_NUM ?=9080
DOCKER_NAME ?=image.demo-mms
OBJECT_TYPE ?=model
OBJECT_ID ?=index.js
BUSINESS_POLICY_NAME ?=$(SERVICE_NAME).bp 


# Configurable parameters passed to serviceTest.sh in "test" target
export MATCH:='DEBUG'
export TIME_OUT:=10


default: all

all: build run

build:
	docker build -t $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .

run:
	@echo "Open your browser and go to http://localhost:9080"
	docker run -d -p=$(PORT_NUM):80 --name=$(DOCKER_NAME) $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION)

  # Run and verify the service
test: build
	hzn dev service start -S
	@echo 'Testing service...'
	./serviceTest.sh $(SERVICE_NAME) $(MATCH) $(TIME_OUT) && \
		{ hzn dev service stop; \
		echo "*** Service test succeeded! ***"; } || \
		{ hzn dev service stop; \
		echo "*** Service test failed! ***"; \
		false; }

  # Publish the service to the Horizon Exchange for the current architecture
publish-service:
	hzn exchange service publish -O -f horizon/service.definition.json

  # Publish the service policy to the Horizon Exchange for the current service
publish-service-policy:
	hzn exchange service addpolicy -f horizon/service_policy.json $(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

  # Publish the business policy to the Horizon Exchange
publish-business-policy:
	hzn exchange business  addpolicy -f horizon/business_policy.json $(BUSINESS_POLICY_NAME)
  
  # Publish the pattern to the Horizon Exchange for the current architecture
publish-pattern:
	hzn exchange pattern publish -f horizon/pattern.json

  # Build the docker image for 3 architectures
build-all-arches:
	ARCH=amd64 $(MAKE) build
	ARCH=arm $(MAKE) build
	ARCH=arm64 $(MAKE) build

  # target to publish new ML model file to mms
publish-mms-object:
	hzn mms object publish -m mms/object.json -f mms/index.js

  # target to list mms object
list-mms-object:
	hzn mms object list -t $(OBJECT_TYPE) -i $(OBJECT_ID) -d

list-model:
	hzn mms object list -t $(OBJECT_TYPE) -i $(OBJECT_ID) -d

list-files:
	sudo ls -Rla /var/horizon/ess-store/sync/local

  # target to delete input.json file in mms
delete-mms-object:
	hzn mms object delete -t $(OBJECT_TYPE) --id $(OBJECT_ID) 

  # register node
register-pattern:
	hzn register -p pattern-image.demo-mms-amd64

register-policy:
	hzn register --policy=horizon/node_policy.json

  # unregiser node
unregister:
	hzn unregister -Df
	
  # Stop and remove a running container
stop:
	docker stop $(DOCKER_NAME); docker rm $(DOCKER_NAME)

# Clean the container
clean:
	-docker rm -f $(DOCKER_NAME) 2> /dev/null || :
