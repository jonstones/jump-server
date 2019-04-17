FROM ubuntu:latest
MAINTAINER "Jon Stones <jon@jonstones.com>"

RUN apt-get update && apt-get -y upgrade >/dev/null && \
    apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr git vim curl >/dev/null 

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

# Install Python 3.6
RUN apt-get -y install python36 python36-pip && \
    pip3.6 install --upgrade pip && \
    pip3.6 install git+https://github.com/ansible/ansible.git@devel

# Set Python3 as the default interpreter
RUN rm -f /usr/bin/python && \
    ln -s /usr/bin/python3.6 /usr/bin/python

# Install ansible roles
RUN ansible-galaxy install Azure.azure_modules ; \
    pip install --ignore-installed -r ~/.ansible/roles/Azure.azure_modules/files/requirements-azure.txt

#-------------------------------------------------------

# install gcloud sdk & cli
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk
    
#-------------------------------------------------------

# install kubectl
RUN apt-get install -y kubectl

#-------------------------------------------------------

# CleanUp
RUN rm -rf /var/lib/apt/lists/*

# take Terraform from their "latest" image - IMAGE: hashicorp/terraform:light 
COPY --from=hashicorp/terraform:light /bin/terraform /bin/terraform

WORKDIR /root

RUN echo 'PS1="JMP \d \\t \W >"' >> /root/.bashrc && echo 'PS1="JMP \d \\t \W >"' >> /etc/bash.bashrc

#banner!
