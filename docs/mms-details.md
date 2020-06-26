## <a id=mms-details></a> More MSS Details

The `hzn mms ...` command provides additional tooling for working with the MMS. Get  help for this command with:

```bash
hzn mms --help
```

A good place to start is with the `hzn mms object new` command, which will genereate an MMS object metadata template as follows. 

```text
{
  "objectID": "",            /* Required: A unique identifier of the object. */
  "objectType": "",          /* Required: The type of the object. */
  "destinationOrgID": "$HZN_ORG_ID", /* Required: The organization ID of the object (an object belongs to exactly one organization). */
  "destinationID": "",       /* The node id (without org prefix) where the object should be placed. */
                             /* If omitted the object is sent to all nodes with the same destinationType. */
                             /* Delete this field when you are using destinationPolicy. */
  "destinationType": "",     /* The pattern in use by nodes that should receive this object. */
                             /* If omitted (and if destinationsList is omitted too) the object is broadcast to all known nodes. */
                             /* Delete this field when you are using policy. */
  "destinationsList": null,  /* The list of destinations as an array of pattern:nodeId pairs that should receive this object. */
                             /* If provided, destinationType and destinationID must be omitted. */
                             /* Delete this field when you are using policy. */
  "destinationPolicy": {     /* The policy specification that should be used to distribute this object. */
                             /* Delete these fields if the target node is using a pattern. */
    "properties": [          /* A list of policy properties that describe the object. */
      {
        "name": "",
        "value": null,
        "type": ""           /* Valid types are string, bool, int, float, list of string (comma separated), version. */
                             /* Type can be omitted if the type is discernable from the value, e.g. unquoted true is boolean. */
      }
    ],
    "constraints": [         /* A list of constraint expressions of the form <property name> <operator> <property value>, separated by boolean operators AND (&&) or OR (||). */
      ""
    ],
    "services": [            /* The service(s) that will use this object. */
      {
        "orgID": "",         /* The org of the service. */
        "serviceName": "",   /* The name of the service. */
        "arch": "",          /* Set to '*' to indcate services of any hardware architecture. */
        "version": ""        /* A version range. */
      }
    ]
  },
  "expiration": "",          /* A timestamp/date indicating when the object expires (it is automatically deleted). The timestamp should be provided in RFC3339 format.  */
  "version": "",             /* Arbitrary string value. The value is not semantically interpreted. The Model Management System does not keep multiple version of an object. */
  "description": "",         /* An arbitrary description. */
  "activationTime": ""       /* A timestamp/date as to when this object should automatically be activated. The timestamp should be provided in RFC3339 format. */
}
```




You can take this template, fill in the fields that are relevant to your use case, and remove all of the "comments" wrapped in `/* ... */`. Then you can pass it to the `hzn mms object publish -m <my-metadata-file` (as your `<my-metadata-file>`).

To publish an object with the MMS, you can use the scripts you used above, or the `hzn mms object publish ...` command. For the latter you need to provide `-t <my-type>` and `-i <my-id>` (passing your own type, `<my-type>`, and ID, `<my-id>`). This command also takes a `-p <my-pattern>` flag that you can use to tell the MMS to deliver this object only to Edge Nodes that are registered with Deployment Pattern `<my-pattern>.



The `hzn mms object list -t <my-type>` can be used to list all the MMS objects of type, `<my-type>`.

To delete a specific object, of type `<my-type>` with ID `<my-id>` you can use, `hzn mms object delete -t <my-type> -i <my-id>`.

To view the current MMS status, use, `hzn mms status`.

## Additional MMS Information

You can browse the [full MMS REST API](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/open-horizon/edge-sync-service/master/swagger.json) .

The ESS REST API (the APIs that an edge service uses) is a small subset of that. The most commonly used ESS REST APIs are:

- `GET /api/v1/objects/{objectType}` - Get metadata for objects of the specified type that have changed, but not yet been acknowledged by this edge service. (There is an optional URL parameter `?received=true` that will cause it to return all objects of this type, regardless of whether they've been acknowledged or not, but this is rarely needed.)
- `GET /api/v1/objects/{objectType}/{objectID}` - Get an object's metadata
- `PUT /api/v1/objects/{objectType}/{objectID}` - Create the metadata (specified in the body) for a new (or updated) object that this service is sending to MMS
- `GET /api/v1/objects/{objectType}/{objectID}/data` - Get the file associated with this object
- `PUT /api/v1/objects/{objectType}/{objectID}/data` - Send this file (specified in the body) to MMS
- `PUT /api/v1/objects/{objectType}/{objectID}/deleted` - Confirm that this service has seen that the object has been deleted
- `PUT /api/v1/objects/{objectType}/{objectID}/received` - Confirm that this service has seen that the object has been changed
