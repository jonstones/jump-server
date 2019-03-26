##### DONT NOT EDIT ME. THIS FILE IS GENERATED. EDIT Dockerfile.Template #####

#Last Updated: 20190326

#from: ubuntu:latest
FROM ubuntu@sha256:017eef0b616011647b269b5c65826e2e2ebddbe5d1f8c1e56b3599fb14fabec8

RUN apt-get update && apt-get -y upgrade >/dev/null && \
    apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr vim curl >/dev/null 

#-------------------------------------------------------

# install az cli
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
# bug with installing pgp key - fix @ https://github.com/Microsoft/vscode/issues/27970
RUN AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
   && apt-get update && apt-get install -y azure-cli=

#-------------------------------------------------------

# Install AWS CLI
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y tzdata \
    && echo "Etc/UTC" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y awscli=1.14.44-1ubuntu1

#-------------------------------------------------------

# Add Python, git and ansible 
RUN apt-get install -y python git ansible

#-------------------------------------------------------

# install gcloud sdk & cli
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk=239.0.0-0 -y 
    
#-------------------------------------------------------

# install kubectl
RUN apt-get install -y kubectl=1.13.4-00

#-------------------------------------------------------

# CleanUp
RUN rm -rf /var/lib/apt/lists/*

# take Terraform from their "latest" image - IMAGE: hashicorp/terraform:light 
COPY --from=hashicorp/terraform@sha256:330bef7401e02e757e6fa2de69f398fd29fcbfafe2a3b9e8f150486fbcd7915b /bin/terraform /bin/terraform

# Add EBRD Proxy Setup Environment variables
COPY scripts/ebrd_proxy.sh /ebrd-proxy.sh

RUN echo 'PS1="JMP \d \\t >"' >> /root/.bashrc && echo 'PS1="JMP \d \\t >"' >> /etc/bash.bashrc

