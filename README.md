# Cloud Services - Red Hat OpenShift AI automation

This Ansible repository will stand up a basic Cloud Services OpenShift Cluster (either ROSA HCP or ARO) and deploy Red Hat OpenShift AI on it.

Along with the cluster itself and RHOAI it will also deploy

  - Authorino
  - Serverless
  - Service Mesh
  - GitOps
  - Pipelines
  - OpenShift Distributed Tracing Platform
  - Kiali
  - OpenShift ElasticSearch (when OCP < v4.15)
  - Node Feature Discovery
    - To discover and utilize hardware features available on cluster nodes
  - Nvidia GPU Graphics Driver
    - to enable GPU acceleration for AI/ML workloads on NVIDIA GPUs


## Installing

This has been tested on Mac OSX, but should also run fine on Linux

**Prerequisites**

- [ROSA cli](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-installing-rosa.html) (if ROSA)
- [AZ](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) cli or [AWS](https://aws.amazon.com/cli/) cli
- Python 3
- [Terraform](https://developer.hashicorp.com/terraform/install) cli
- Organization / Account on [Red Hat Hybrid Cloud Console](https://console.redhat.com)
- Log into
    - aws or azure
    - `rosa login`


**ROSA HCP**

- `make ansible.venv`
- `make ansible.create.hcp`

**ARO**

- `make ansible.venv`
- `make ansible.create.aro`

**RHOAI on an existing cluster**

- `make ansible.venv`
- `make rhoai`


After the Ansible tasks have been sucessfully completed you should see the following output which will guide your next steps

```
ok: [localhost] =>
  msg: |-
    OpenShift info

    To log into the cluster run:

      oc login https://api.XXXX-rhoai.ya62.p3.openshiftapps.com:443 --username "admin" --password 'Passw0rd12345!'

    The Red Hat OpenShift AI url is:

      https://rhods-dashboard-redhat-ods-applications.apps.rosa.XXXXX-rhoai.ya62.p3.openshiftapps.com
```


## Cleanup

**ROSA HCP**

- `make ansible.destroy.hcp`

**ARO**

- `make ansible.destroy.aro`


# Core Workflow Components


## The automation is structured around the following main playbooks:

- `create_cluster.yaml` - Creates the Red Hat OpenShift on AWS cluster
- `install_rhoai.yaml` - Installs RHOAI and its dependencies
- `Create_workshop.yaml` - Calls external roles to install and configure gitops and secrets manager
- `destroy_cluster.yaml` - Tears down the environment


## How the Automation Works

### Environment Selection

The workflow starts by selecting an environment profile from ansible/environment/:

- `rosa_hcp/` - ROSA Hosted Control Plane
- `rosa_classic/` - Traditional ROSA
- `aro/` - Azure Red Hat OpenShift
- `intel/` - Intel GPU optimized configuration

### Cluster Creation Flow

`create_cluster.yaml` workflow:

- Sets up initial state by injecting the role variables into the jinja template that is used to create terraform_config.tf and terraform_outputs.tf
- Determines cluster type (ROSA HCP/Classic/ARO)
  - Classic v HCP is based on an hcp boolean flag that augments the jinja templates
  - ARO is based on the command passed in during the make process
- Executes appropriate cluster role ( `rosa_cluster/` or `aro_cluster/` )
  - Uses the terraform ansible module to create the cluster from the terraform_config.tf file generated prior
- Configures cluster authentication
  - Sets variables with the admin username, password and the cluster api url
- Deploys RHOAI components
- Deploys Workshop external role
  - During the make process your venv is configured with the necessary external ansible collection where the workshop roles live

### Customizing ROSA Cluster Deployment

The default configuration is in `rosa_cluster/defaults/main.yaml`, but you can override these in several ways:

- Create Environment-Specific Variables or use `--extra-vars @/path/to/variablefile` in the ansible-playbook command that occurs in the `ansible/Makefile` with a vars.yaml file in the format below: 

``` yaml
# ansible/environment/custom-env/group_vars/all.yaml
rosa_cluster_tf_vars:
   # change the path to `~/.config/ocm/ocm.json` for linux hosts
  token: "{{ (lookup('ansible.builtin.file', '~/Library/Application\ Support/ocm/ocm.json') | from_json).refresh_token | default('') }}"
  admin_password: ''
  ocp_version: ~
  region: "us-east-2"
  # multi_az: false
  cluster_name: "{{ lookup('env', 'USER') }}-rhoai"
  tags:
    Cost-center: ####
    service-phase: ‘’
    app-code: ‘’
    owner: "{{ lookup('env', 'USER') }}_redhat.com"
    provisioner: Terraform
  bucket_names:
    - "{{ lookup('env', 'USER') }}-cluster-bucket1"
    - "{{ lookup('env', 'USER') }}-cluster-bucket2"
  compute_machine_type: "m5.xlarge"
  #the machine pool for the GPU nodes
  secondary_machine_pool_enabled: true
  secondary_machine_pool_name: "gpu-pool"
  secondary_machine_pool_instance_type: "g5.12xlarge" 
  secondary_machine_pool_replicas: 1
  workers_replicas: 6
  workers_replicas_max: 6
  #hcp flag that determines if the cluster is a hosted control plane or classic
  hcp: "true"
  vpc_cidr: "x.x.x.x/x"
  developer_password: ""
```


### Important Tips

#### GPU Configuration:
- For NVIDIA support: Set `install_rhoai_components_nvidia_gpus: true`
- For Intel Support: Set `install_rhoai_components_intel_gpus: true` for Intel support
- Configure appropriate instance types in `secondary_machine_pool_instance_type`

#### Scaling:
- `workers_replicas` sets initial cluster size
- `workers_replicas_max` sets scaling limit
- `secondary_machine_pool_replicas` controls GPU node count
  
#### Storage:
- S3 buckets are automatically created based on `bucket_names`
- Bucket names must be globally unique
- Default naming uses your username as prefix

#### Authentication:
- OCM token is read from `~/.config/ocm/ocm.json` by default, but can be overridden in your environment variables

*Remember that after cluster creation, the automation will automatically install RHOAI and all required operators. The process typically takes 30-45 minutes for cluster creation and another 15-20 minutes for RHOAI installation.*
