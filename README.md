# Jump Server Container

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

## Ever-Green Policy

The image is rebuilt every day at 4am, picking up the latest in all the tools above. 
