# Horizon Model Management System (MMS) Example for ML model updates

This example helps you learn how to develop an IBM Edge Application Manager service that uses the Model Management System (MMS) for model updates. You can use the MMS to deploy and update the  machine learning (ML) models that are used by edge services that run on your edge nodes.

This is a simple example of using and updating a Horizon ML edge service.

- [Introduction to the Horizon Model Management System](#introduction)
- [Preconditions for Using the ML MMS Example Edge Service](docs/preconditions.md)
- [Using the ML MMS Example with deployment policy](docs/using-image-mms-policy.md)
- [More MMS Details](docs/mms-details.md)


## <a id=introduction></a> Introduction

The Horizon Model Management System (MMS) enables you to have independent lifecycles for your code and your data. While Horizon Services, Patterns, and Policies enable you to manage the lifecycles of your code components, the MMS performs an analogous service for your ML models and other data files.  This can be useful for remotely updating the configuration of your edge services on the ground. It can also enable you to continuously train and update your ML models in powerful central data centers, then dynamically push new versions of the models to your small edge machines in the field. The MMS enables you to manage the lifecycle of ML models and data files on your edge node, remotely and independently from your code updates. In general, the MMS provides capabilities for you to securely send any data file to and from your edge nodes.

This document will walk you through the process of using the Model Management System to send a ML model file to your edge nodes. It also shows how your nodes can detect the arrival of a new version of the ML model, and then consume the contents of that file.



See more examples at: [Horizon Examples](https://github.com/open-horizon/examples/)
