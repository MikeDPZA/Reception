.PHONY: stop build_run tag_push start_kube helm_deploy kube_port_forward kube_dash run_socat docker_run build

stop:
	docker stop Reception

build_run: build docker_run 

build:
	docker build -t reception .

docker_run:
	docker run -d -ti --rm --name Reception -p 8080:80 reception

tag_push: build
	docker tag reception:latest mikedoops/reception:latest && \
		docker push mikedoops/reception:latest

start_kube:
	minikube start
		docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:host.docker.internal:5000"

kube_port_forward:
	kubectl port-forward --namespace kube-system service/registry 5000:80

run_socat:
	docker run --rm -it --name socat --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:host.docker.internal:5000"

kube_dash:
	minikube dashboard --url

helm_deploy:
	helm upgrade --atomic --install reception ./deploy/chart 		
