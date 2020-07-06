FROM quay.io/operator-framework/helm-operator:v0.18.2

LABEL name="falco-operator"
LABEL summary="The Falco Project is an open source runtime security tool."
LABEL description="Falco parses Linux system calls from the kernel at runtime, and asserts the stream against a powerful rules engine. If a rule is violated a Falco alert is triggered."
LABEL vendor="Falco"

COPY LICENSE /licenses/

COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts/ ${HOME}/helm-charts/
