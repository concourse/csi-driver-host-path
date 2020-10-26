# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CMDS=hostpathplugin
all: build

.PHONY: deploy logs

# deploy the modified CSI driver
csi-deploy:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-attacher/release-3.0/deploy/kubernetes/rbac.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-provisioner/release-2.0/deploy/kubernetes/rbac.yaml

	yq w --inplace ./deploy/kubernetes-1.17/hostpath/csi-hostpath-plugin.yaml \
		--doc 2 'spec.template.metadata.labels.update' "prefix-$$RANDOM" && \
	kubectl apply -f ./deploy/kubernetes-1.17/hostpath/

# remove the driver and storage class
csi-cleanup:
	kubectl delete statefulset.apps/csi-hostpathplugin --wait=false ;\
	kubectl delete statefulset.apps/csi-hostpath-provisioner --wait=false ;\
	kubectl delete statefulset.apps/csi-hostpath-attacher --wait=false ;\
	kubectl delete service/csi-hostpathplugin --wait=false ;\
	kubectl delete pvc/csi-data-dir --wait=false ;\
	kubectl delete csidrivers.storage.k8s.io/baggageclaim.concourse-ci.org --wait=false ;\
	kubectl delete sc baggageclaim


logs:
	kubectl logs pod/csi-hostpathplugin-0 -c hostpath | grep concourse

output-poc:
	# create a PVC
	kubectl apply -f ./poc/artifact-output.yaml ;\
	# Create a Pod on node1 that uses and writes to the PVC
	kubectl apply -f ./poc/output-pod.yaml ;\
	# Delete the Pod and see that the PVC and PV is still there

clean-output:
	kubectl delete pod/output ;\
	kubectl delete pvc/artifact-output ;\
	echo "You will need to manually delete the PV associated to the PVC"


input-poc:
	echo "Input POC"
	# Create a PVC that uses the previous PVC as its data source
	kubectl apply -f ./poc/artifact-input.yaml ;\
	# Create Pod thatreads data from the PVC
	kubectl apply -f ./poc/input-pod.yaml

clean-input:
	kubectl delete pod/input ;\
	kubectl delete pvc/artifact-input ;\
	echo "You will need to manually delete the PV associated to the PVC"

# make push will build the app, image, and push the image to docker hub
include release-tools/build.make
