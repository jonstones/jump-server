FROM ubuntu:latest

ENV http_proxy "http://ldn3log1.ebrd.com:8888"
ENV https_proxy "http://ldn3log1.ebrd.com:8888"
ENV no_proxy "ldn1cvs2.ebrd.com,localhost,docker,docker:2375"

RUN apt-get update && apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr \
    vi \
    && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'PS1="\u@DOCKER-JMP \d \t >"' >> /etc/profile

#-------------------------------------------------------
# install az cli
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
RUN apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr \
    && AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
     --keyserver packages.microsoft.com \
     --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF \
	 && apt-get update && apt-get install azure-cli

#-------------------------------------------------------
