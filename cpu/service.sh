#!/bin/bash

# A simple Horizon sample edge service that shows how to use a Model Management System (MMS) file with your service.
# In this case we use a MMS file as a config file for this service that can be updated dynamically. The service has a default
# copy of the config file built into the docker image. Once the service starts up it periodically checks for a new version of
# the config file using the local MMS API (aka ESS) that the Horizon agent provides to services. If an updated config file is
# found, it is loaded into the service and the config parameters applied (in this case who to say hello to).

# Of course, MMS can also hold and deliver inference models, which can be used by services in a similar way.

# The type and name of the MMS file we are using
OBJECT_TYPE=model
OBJECT_ID=index.html
PATH_TO_MODEL=/var/www/localhost/htdocs

# ${HZN_ESS_AUTH} is mounted to this container by the Horizon agent and is a json file with the credentials for authenticating to ESS.
# ESS (Edge Sync Service) is a proxy to MMS that runs in the Horizon agent.
USER=$(cat ${HZN_ESS_AUTH} | jq -r ".id")
PW=$(cat ${HZN_ESS_AUTH} | jq -r ".token")

# Some curl parameters for using the ESS REST API
AUTH="-u ${USER}:${PW}"
# ${HZN_ESS_CERT} is mounted to this container by the Horizon agent and the cert clients use to verify the identity of ESS.
CERT="--cacert ${HZN_ESS_CERT}"
SOCKET="--unix-socket ${HZN_ESS_API_ADDRESS}"
BASEURL='https://localhost/api/v1/objects'

# Save original config file that came from the docker image so we can revert back to it if the MMS file is deleted
#cp $PATH_TO_MODEL/$OBJECT_ID $PATH_TO_MODEL/${OBJECT_ID}.original
cp $PATH_TO_MODEL/index.html $PATH_TO_MODEL/index.html.original

# Repeatedly check to see if an updated config.json was delivered via MMS/ESS, then use the value within it to echo hello
while true; do

    # See if there is a new version of the config.json file
    echo "DEBUG ***: Checking for MMS updates"
    #HTTP_CODE=$(curl -sSLw "%{http_code}" -o objects.meta ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID)  # not using this because it would result in getting the object metadata every call, even if it hasn't been updated
    HTTP_CODE=$(curl -sSLw "%{http_code}" -o objects.meta ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE)  # will only get changes that we haven't acknowledged (see below)
    if [[ "$HTTP_CODE" != '200' && "$HTTP_CODE" != '404' ]]; then echo "Error: HTTP code $HTTP_CODE from: curl -sSLw %{http_code} -o objects.meta ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE"; fi
    echo "DEBUG *** : MMS metadata=$(cat objects.meta)"
    # objects.meta is a json array of all MMS files of OBJECT_TYPE that have been updated. Search for the ID we are interested in
    OBJ_ID=$(jq -r ".[] | select(.objectID == \"$OBJECT_ID\") | .objectID" objects.meta)  # if not found, jq returns 0 exit code, but blank value

    if [[ "$HTTP_CODE" == '200' && "$OBJ_ID" == $OBJECT_ID ]]; then
        echo "DEBUG *** : Received new metadata for $OBJ_ID"

        # Handle the case in which MMS is telling us the config file was deleted
        DELETED=$(jq -r ".[] | select(.objectID == \"$OBJECT_ID\") | .deleted" objects.meta)  # if not found, jq returns 0 exit code, but blank value
        if [[ "$DELETED" == "true" ]]; then
            echo "*** DEBUG *** MMS file $OBJECT_ID was deleted, reverting to original $OBJECT_ID"

            # Acknowledge that we saw that it was deleted, so it won't keep telling us
            HTTP_CODE=$(curl -sSLw "%{http_code}" -X PUT ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID/deleted)
            if [[ "$HTTP_CODE" != '200' && "$HTTP_CODE" != '204' ]]; then echo "Error: HTTP code $HTTP_CODE from: curl -sSLw %{http_code} -X PUT ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID/deleted"; fi

            # Revert back to the original config file from the docker image
            #cp $PATH_TO_MODEL/${OBJECT_ID}.original $PATH_TO_MODEL/$OBJECT_ID
	    #cp $PATH_TO_MODEL/index.html.original $PATH_TO_MODEL/index.html

        else
            echo "*** DEBUG *** Received new/updated $OBJECT_ID from MMS"

            # Read the new file from MMS
            HTTP_CODE=$(curl -sSLw "%{http_code}" -o $OBJECT_ID ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID/data)
            if [[ "$HTTP_CODE" != '200' ]]; then echo "Error: HTTP code $HTTP_CODE from: curl -sSLw %{http_code} -o $OBJECT_ID ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID/data"; fi
            #ls -l $OBJECT_ID

	    # move the new model to htdocs
	    echo "*** DEBUG *** PROCESS: moving new model to ...htdocs/ "
	    cp $OBJECT_ID $PATH_TO_MODEL/index.html

            # Acknowledge that we got the new file, so it won't keep telling us
            HTTP_CODE=$(curl -sSLw "%{http_code}" -X PUT ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID/received)
            if [[ "$HTTP_CODE" != '200' && "$HTTP_CODE" != '204' ]]; then echo "Error: HTTP code $HTTP_CODE from: curl -sSLw %{http_code} -X PUT ${AUTH} ${CERT} $SOCKET $BASEURL/$OBJECT_TYPE/$OBJECT_ID/received"; fi
        fi
    fi

    #sleep 5

done
