# syntax=docker/dockerfile:1-labs
FROM alpine:latest AS ansible
WORKDIR /ansible
RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    apk update && apk add python3 bash tini && \
    python3 -m venv venv && \
    ./venv/bin/pip install -r requirements.txt && \
    ./venv/bin/ansible-galaxy collection install void.network

FROM ansible
ENV ARA_API_CLIENT=http \
    ARA_API_SERVER=http://ara.matrix.michaelwashere.net \
    ANSIBLE_CALLBACK_PLUGINS=/ansible/venv/lib/python3.12/site-packages/ara/plugins/callback \
    ANSIBLE_ACTION_PLUGINS=/ansible/venv/lib/python3.12/site-packages/ara/plugins/action \
    ANSIBLE_LOOKUP_PLUGINS=/ansible/venv/lib/python3.12/site-packages/ara/plugins/lookup
COPY --exclude=*.txt . .

LABEL org.opencontainers.image.title="Ansible Configuration" \
    org.opencontainers.image.description="Complete Ansible configuration for the Matrix" \
    org.opencontainers.image.licenses=Proprietary \
    org.opencontainers.image.vendor="M. Aldridge" \
    org.opencontainers.image.authors="M. Aldridge"
