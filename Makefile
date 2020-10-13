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

.PHONY: deploy

deploy:
	yq w --inplace ./deploy/kubernetes-1.17/hostpath/csi-hostpath-plugin.yaml \
		--doc 2 'spec.template.metadata.labels.update' "prefix-$$RANDOM" && \
	kubectl apply -f ./deploy/kubernetes-1.17/hostpath/

include release-tools/build.make
