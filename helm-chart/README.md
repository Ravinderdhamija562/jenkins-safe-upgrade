# Jenkins

It contains the setup details of jenkins which are running in kubernetes cluster

## Add helm repo and check available version

```console
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm search repo jenkins -l
```

## Check current installed helm chart version, jenkins version

```console
helm ls -n <namespace>
```

in above output `CHART` denotes helm chart version while `APP VERSION` denotes jenkins version

## Check all values used to install jenkins helm chart

```console
helm get all jenkins -n <namespace>
```

## Install Chart

```console
helm upgrade --install [RELEASE_NAME] jenkins/jenkins -f <overriding values.yaml file> --version <jenkins_version>
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).
To see all configurable options with detailed comments, visit the chart's [values.yaml](https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/values.yaml), or run these configuration commands:

```console
# Helm 3
$ helm show values jenkins/jenkins
```

For a summary of all configurable options, see [VALUES_SUMMARY.md](https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md).

## Upgrade Runbook

https://docs.google.com/document/d/1nGrAwweYxSCLudVGYOhoVDYYeGN-GMyUG_VtnWKfISY/edit?usp=sharing
