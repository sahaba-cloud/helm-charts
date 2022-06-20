CHART ?= demo-devops
DIR = ./charts/${CHART}

VER = $(shell yq eval '.version' ${DIR}/Chart.yaml)
TGZ = ./${CHART}-${VER}.tgz


# ----------------------------------------
.PHONY: init
init:
	helm plugin install https://github.com/hypnoglow/helm-s3.git
	helm repo add easi s3://easi-helm-charts-jp/charts

.PHONY: echo
echo:
	@echo ${TGZ}


# ----------------------------------------
.PHONY: debug create package push
debug:
	helm template --debug ${CHART} ${DIR}

create:
	cd ./chart && helm create ${CHART}

package:
	helm package ${DIR}

push-ft:
	AWS_PROFILE=ft-luotao helm s3 push ${TGZ} fantuan

push-ip:
	AWS_PROFILE=ug-isabella helm s3 push ${TGZ} ip

push: push-ip


# ----------------------------------------
install:
	helm upgrade --install ${CHART} ./chart/${CHART} --kube-context jp -n testing --set "easi.runenv=testing"

uninstall:
	helm uninstall ${CHART} --kube-context jp -n testing

install-prod:
	helm upgrade --install ${CHART} ./chart/${CHART} --kube-context au -n production --set "easi.runenv=production"

uninstall-prod:
	helm uninstall ${CHART} --kube-context au -n production

.PHONY: all
all:
	CHART=admin-api make package push
	CHART=cashier-api make package push
	CHART=merchant-api make package push
	CHART=payment-account make package push
	CHART=payment-api make package push
	CHART=payment-service make package push
	CHART=payment-web make package push
	CHART=data-redash make package push
