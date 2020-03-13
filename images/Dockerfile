FROM gcr.io/spiffe-io/spire-agent:0.9.3

RUN apk add curl vim bash
# Install aws-cli
RUN apk -Uuv add groff less python py-pip
RUN pip install awscli
# Clean
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*
