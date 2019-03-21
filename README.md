# Jump Server Container - 
[![pipeline status](https://gitlab.com/js-devops/sysadmin/jump-server/badges/master/pipeline.svg)](https://gitlab.com/js-devops/sysadmin/jump-server/commits/master)

This is a container image that I use as a base image to work from.

## Whats in it?

The current base image is ubuntu:latest, and it has the following installed:

* aws cli ( aws )
* azure cli ( az )
* terraform

coming soon:

* ansible
* vagrant
* gcp cli
* kubernetes cli?
* git

## Ever-Green Policy

The image is rebuilt every day at 4am, picking up the latest in all the tools above. 
