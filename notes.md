service Identity {
  rpc GetPluginInfo(GetPluginInfoRequest)
    returns (GetPluginInfoResponse) {}
    - contains a `manifest` map containing arbitrary info

  rpc GetPluginCapabilities(GetPluginCapabilitiesRequest)
    returns (GetPluginCapabilitiesResponse) {}

  rpc Probe (ProbeRequest)
    returns (ProbeResponse) {}
    - verify that plugin is in a healthy and ready state.
    - we could verify that all baggaeclaim servers are responding here ?
}

service Controller {
  rpc CreateVolume (CreateVolumeRequest)
    returns (CreateVolumeResponse) {}
    - unclear if we want this. Is called if `CREATE_DELETE_VOLUME` and
      `CLONE_VOLUME` capabilities are specified. Right now we're thinking we'll
      want `CLONE_VOLUME` but it's not clear that we want
      `CREATE_DELETE_VOLUME` as well

  rpc DeleteVolume (DeleteVolumeRequest)
    returns (DeleteVolumeResponse) {}

  rpc ControllerPublishVolume (ControllerPublishVolumeRequest)
    returns (ControllerPublishVolumeResponse) {}
    - perform the work necessary for making the volume available on the given
      node. Only called when `PUBLISH_UNPUBLISH_VOLUME` is specified
    - use this for streaming volumes between nodes? Can we directly reach out
      to nodes? We do get a `node_id` which comes from `NodeGetInfo`. Not sure
      how this mapping works or what format `node_id` can be in
    - how do we map node_id to a node and then talk to a service (baggaeclaim) on that node?
      - node_id comes from NodeGetInfo, part of the Node Service
    - nested in the response is a `Volume` object which gives the `volume_id` chose by the SP

  rpc ControllerUnpublishVolume (ControllerUnpublishVolumeRequest)
    returns (ControllerUnpublishVolumeResponse) {}

  rpc ValidateVolumeCapabilities (ValidateVolumeCapabilitiesRequest)
    returns (ValidateVolumeCapabilitiesResponse) {}

  rpc ListVolumes (ListVolumesRequest)
    returns (ListVolumesResponse) {}
    - ideally the controller should reach out to each baggaeclaim node and ask
      for its volumes. All responses should be combined into one list
    - within the context of this call we are not give a list of nodes where baggaeclaim is running...

  rpc GetCapacity (GetCapacityRequest)
    returns (GetCapacityResponse) {}

  rpc ControllerGetCapabilities (ControllerGetCapabilitiesRequest)
    returns (ControllerGetCapabilitiesResponse) {}

  rpc CreateSnapshot (CreateSnapshotRequest)
    returns (CreateSnapshotResponse) {}

  rpc DeleteSnapshot (DeleteSnapshotRequest)
    returns (DeleteSnapshotResponse) {}

  rpc ListSnapshots (ListSnapshotsRequest)
    returns (ListSnapshotsResponse) {}

  rpc ControllerExpandVolume (ControllerExpandVolumeRequest)
    returns (ControllerExpandVolumeResponse) {}

  rpc ControllerGetVolume (ControllerGetVolumeRequest)
    returns (ControllerGetVolumeResponse) {
        option (alpha_method) = true;
    }
    - alpha feature, simply returns metadata about the volume requested
}

service Node {
  rpc NodeStageVolume (NodeStageVolumeRequest)
    returns (NodeStageVolumeResponse) {}
    - gets a volume object that can contain a `volume_context` that is tied to
      a `volume_id`. Could specify which baggaeclaim server the volume_id is
      located on in here maybe?

  rpc NodeUnstageVolume (NodeUnstageVolumeRequest)
    returns (NodeUnstageVolumeResponse) {}

  rpc NodePublishVolume (NodePublishVolumeRequest)
    returns (NodePublishVolumeResponse) {}

  rpc NodeUnpublishVolume (NodeUnpublishVolumeRequest)
    returns (NodeUnpublishVolumeResponse) {}

  rpc NodeGetVolumeStats (NodeGetVolumeStatsRequest)
    returns (NodeGetVolumeStatsResponse) {}


  rpc NodeExpandVolume(NodeExpandVolumeRequest)
    returns (NodeExpandVolumeResponse) {}


  rpc NodeGetCapabilities (NodeGetCapabilitiesRequest)
    returns (NodeGetCapabilitiesResponse) {}

  rpc NodeGetInfo (NodeGetInfoRequest)
    returns (NodeGetInfoResponse) {}
    - can we return information in here that would allow the Controller or
      other Nodes running baggaeclaim to reach out to the current node
}

---

Task with single output. One cluster. One k8s node. Single namespce. Not thinking about security.
create PV -> create PVC -> Create Pod
- what gets called when we create a PV?
- what gets called when we create a PVC?
- what gets called when we create a pod? (NodeStageVolume (opional), NodePublishVolume)

Task with single input from previous step. One cluster. One k8s node. Single namespce. Not thinking about security.
create PV based on previous PV (use volumeAttributes) -> create PVC -> Create Pod
- 
