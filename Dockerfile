# Build the manager binary
FROM quay.io/operator-framework/helm-operator:v1.0.1

LABEL name="falco-operator"
LABEL summary="The Falco Project is an open source runtime security tool."
LABEL description="Falco parses Linux system calls from the kernel at runtime, and asserts the stream against a powerful rules engine. If a rule is violated a Falco alert is triggered."
LABEL vendor="Falco"

COPY LICENSE /licenses/

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}
