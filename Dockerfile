##### DONT NOT EDIT ME. THIS FILE IS GENERATED. EDIT Dockerfile.Template #####

#Last Updated: ${TODAY}

#from: ubuntu:latest
FROM ubuntu:latest

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr vim curl

#-------------------------------------------------------

# install az cli
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
# bug with installing pgp key - fix @ https://github.com/Microsoft/vscode/issues/27970
RUN AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
   && apt-get update && apt-get install -y azure-cli

#-------------------------------------------------------

# Install AWS CLI
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y tzdata \
    && echo "Etc/UTC" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y awscli

#-------------------------------------------------------

# Add Python, git and ansible 
RUN apt-get install -y python git ansible

#-------------------------------------------------------

# install gcloud sdk & cli
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y 
    
#-------------------------------------------------------

# install kubectl
RUN apt-get install -y kubectl

#-------------------------------------------------------

# CleanUp
RUN rm -rf /var/lib/apt/lists/*

# take Terraform from their "latest" image - IMAGE: hashicorp/terraform:light 
COPY --from=hashicorp/terraform:light /bin/terraform /bin/terraform

# Add EBRD Proxy Setup Environment variables
COPY ebrd_proxy.sh /ebrd-proxy.sh

RUN echo 'PS1="\u@DOCKER-JMP \d \\t >"' >> /root/.bashrc && echo 'PS1="\u@DOCKER-JMP \d \\t >"' >> /etc/bash.bashrc

