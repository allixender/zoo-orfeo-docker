
VERSION=0.3
PROJECT=dynamic-cove-129211
IMAGE=zooorfeo

all: build push

build:
	docker build -t eu.gcr.io/${PROJECT}/${IMAGE}:${VERSION} .

push:
	# gcloud docker --authorize-only
	gcloud docker push eu.gcr.io/${PROJECT}/${IMAGE}:${VERSION}

pull:
	gcloud docker --authorize-only
	gcloud docker pull eu.gcr.io/${PROJECT}/${IMAGE}:${VERSION}

data:
	# gsutil cp gs://smart-server/InsightToolkit-4.7.2.tar.gz .
	# gsutil cp gs://smart-server/OTB-4.2.1.tgz .

clean:
	# InsightToolkit-4.7.2.tar.gz OTB-4.2.1.tgz

.PHONY: all build push pull clean data
