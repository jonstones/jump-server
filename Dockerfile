FROM ubuntu:latest

#ENV http_proxy "http://ldn3log1.ebrd.com:8888"
#ENV https_proxy "http://ldn3log1.ebrd.com:8888"
#ENV no_proxy "ldn1cvs2.ebrd.com,localhost,docker,docker:2375"

RUN apt-get update && apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr \
    vim curl \
    && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'PS1="\u@DOCKER-JMP \d \\t >"' >> /root/.bashrc

#-------------------------------------------------------
# install az cli
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
# bug with installing pgp key - fix @ https://github.com/Microsoft/vscode/issues/27970
RUN AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
	&& apt-get update && apt-get install azure-cli \
	&& rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------
# Install AWS CLI
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y tzdata \
    && echo "Etc/UTC" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y awscli \
    && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------
# take Terraform from their "latest" image
COPY --from=hashicorp/terraform:light /bin/terraform /bin/terraform

RUN apt-get install python vagrant git openssh ansible 

