FROM alpine:3.9

# ENV KUBECTL_VERSION 1.15.0
# ENV KUBECTL_URI https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV PATH="/:${PATH}"
ADD kubectlv15.0 /kubectl
RUN echo https://mirrors.ustc.edu.cn/alpine/v3.9/main > /etc/apk/repositories && \
	  echo https://mirrors.ustc.edu.cn/alpine/v3.9/community >> /etc/apk/repositories; \
    apk update && \
    apk add --update \
    bash \
    easy-rsa \
    git \
    openssh-client \
    curl \
    ca-certificates \
    jq \
    python \
    py-yaml \
    py2-pip \
    libstdc++ \
    gpgme \
    libressl-dev \
    make \
    g++ \
    && \
  git clone https://github.com/AGWA/git-crypt.git && \
  make --directory git-crypt && \
  make --directory git-crypt install && \
  rm -rf git-crypt && \
  apk del libressl-dev make g++ && \
  rm -rf /var/cache/apk/* && \
  pip install ijson awscli && \
  adduser -h /backup -D backup && \
  # curl -SL ${KUBECTL_URI} -o kubectl &&\
  chmod +x /kubectl 

COPY entrypoint.sh /
USER backup
ENTRYPOINT ["/entrypoint.sh"]