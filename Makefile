IMAGE = qp2
NETWORK = demo-net

default:
	docker build -t $(IMAGE) .

no-cache:
	docker build -t $(IMAGE) --no-cache .

network:
	docker network create -o "com.docker.network.bridge.enable_icc"="false" $(NETWORK)

network-clean:
	docker network rm $(NETWORK)

image-clean:
	docker image rm $(IMAGE)

clean: network-clean image-clean

test:
	docker run -h qp-demo --rm -it $(IMAGE)
