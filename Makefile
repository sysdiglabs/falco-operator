IMAGE = sysdiglabs/falco-operator
# Use same version than helm chart
PREVIOUS_VERSION = $(shell ls -d deploy/olm-catalog/falco-operator/*/ -t | head -n1 | cut -d"/" -f4)
VERSION = 1.4.0
CERTIFIED_IMAGE = registry.connect.redhat.com/sysdig/falco-operator

CERTIFIED_FALCO_IMAGE = docker.io/falcosecurity/falco
FALCO_VERSION = 0.25.0

.PHONY: build bundle.yaml

build: update-chart
	operator-sdk build $(IMAGE):$(VERSION)

update-chart:
	rm -fr helm-charts/falco
	helm repo add falcosecurity https://falcosecurity.github.io/charts
	helm fetch falcosecurity/falco --version $(VERSION) --untar --untardir helm-charts/

push:
	docker push $(IMAGE):$(VERSION)

bundle.yaml:
	cat deploy/crds/falco.org_falcos_crd.yaml > bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/service_account.yaml >> bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/role_binding.yaml >> bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/operator.yaml >> bundle.yaml
	sed -i 's|REPLACE_IMAGE|docker.io/$(IMAGE):$(VERSION)|g' bundle.yaml

e2e: bundle.yaml
	oc apply -f bundle.yaml
	oc apply -f deploy/crds/falco.org_v1_falco_cr.yaml

e2e-clean: bundle.yaml
	oc delete -f deploy/crds/falco.org_v1_falco_cr.yaml
	oc delete -f bundle.yaml

package-redhat:
	cp deploy/crds/falco.org_falcos_crd.yaml redhat-certification/falco.crd.yaml
	cp redhat-certification/falco-operator.vX.X.X.clusterserviceversion.yaml redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml
	\
	sed -i 's|REPLACE_VERSION|${VERSION}|g' redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_IMAGE|${CERTIFIED_IMAGE}|g' redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_FALCO_IMAGE|${CERTIFIED_FALCO_IMAGE}|g' redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_FALCO_VERSION|${FALCO_VERSION}|g' redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_VERSION|${VERSION}|g' redhat-certification/falco-operator.package.yaml
	\
	zip -j redhat-certification-metadata-${VERSION}.zip \
		redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml \
		redhat-certification/falco.crd.yaml \
		redhat-certification/falco-operator.package.yaml
	\
	rm	redhat-certification/falco.crd.yaml \
		redhat-certification/falco-operator.v${VERSION}.clusterserviceversion.yaml
	\
	git checkout redhat-certification
