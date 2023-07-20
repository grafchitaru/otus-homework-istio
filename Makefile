up: init infra web

init: start namespaces helm

helm: helm-jaeger helm-monitoring helm-kiali helm-istio

start:
	minikube start --driver virtualbox --cpus=2 --cni=flannel --kubernetes-version="v1.19.0" --driver=docker

namespaces:
	kubectl apply -f ./kubernetes/namespaces.yaml

helm-jaeger:
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
	helm repo update
	helm install --version "2.19.0" -n jaeger-operator -f jaeger/operator-values.yaml jaeger-operator jaegertracing/jaeger-operator

helm-monitoring:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add stable https://charts.helm.sh/stable
	helm repo update
	helm install --version "13.7.2" -n monitoring -f prometheus/operator-values.yaml prometheus prometheus-community/kube-prometheus-stack

helm-istio:
	istioctl operator init --watchedNamespaces istio-system --operatorNamespace istio-operator
	istioctl install --set profile=default

helm-kiali:
	helm repo add kiali https://kiali.org/helm-charts
	helm repo update
	helm install --version "1.33.1" -n kiali-operator -f kiali/operator-values.yaml kiali-operator kiali/kiali-operator

infra:
	kubectl apply -f jaeger/jaeger.yaml
	kubectl apply -f prometheus/monitoring-nodeport.yaml
	kubectl apply -f istio/istio.yaml
	kubectl apply -f istio/defaults.yaml
	kubectl apply -f kiali/kiali.yaml
	kubectl label namespace default istio-injection=enabled

web:
	kubectl apply -f ./kubernetes/webapp.yaml
	minikube service -n istio-system istio-ingressgateway

k:
	minikube service -n kiali kiali-nodeport

i:
	minikube service -n istio-system istio-ingressgateway