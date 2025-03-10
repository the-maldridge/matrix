FROM alpine:latest AS ansible
WORKDIR /ansible
COPY requirements.txt .
RUN apk update && apk add python3 bash tini && \
    python3 -m venv venv && \
    ./venv/bin/pip install -r requirements.txt && \
    ./venv/bin/ansible-galaxy collection install void.network

FROM ansible
COPY *.cfg .
COPY *.yml .
COPY inventory inventory
COPY roles roles
COPY group_vars group_vars
COPY host_vars host_vars

ENV ARA_API_CLIENT=http \
    ARA_API_SERVER=http://ara.matrix.michaelwashere.net \
    ANSIBLE_CALLBACK_PLUGINS=/ansible/venv/lib/python3.12/site-packages/ara/plugins/callback \
    ANSIBLE_ACTION_PLUGINS=/ansible/venv/lib/python3.12/site-packages/ara/plugins/action \
    ANSIBLE_LOOKUP_PLUGINS=/ansible/venv/lib/python3.12/site-packages/ara/plugins/lookup
