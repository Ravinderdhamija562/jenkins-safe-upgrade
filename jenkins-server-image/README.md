# Jenkins Server image

This folder consists of the required files to build the Jenkins server image. It installs all the plugins in the image itself.
It also tests the jenkins with test configuration and credentials before uploading the image to artifactory.

- [Jenkins Server image](#jenkins-server-image)
  - [Build Jenkins server image](#build-jenkins-server-image)

## Build Jenkins server image

1. Update jenkins base version in ./Dockerfile
2. Update plugins.txt by fetching the latest compatible version of the plugin.

   ```bash
   cd scripts
   python3 fetch-plugins-compatible-version.py ../jenkins-server-image/plugins.txt 2.516.1 | awk '{print $1}'
   ```

3. Update the plugins.txt with the output captured from above command.
4. Push the changes to github repo and create the PR with the changes
5. PR creation will trigger a workflow called `jenkins-eks-test-ep-jenkins-master-image.yml` which will build the image with the changes and test it by running the jenkins server with the new image in the test environment.
   Once the jenkins is up, status can be checked in [Jenkins Test jobs](https://npe-cisystem-test.company.io/view/UpgradeTestJobs/)
6. It will send the notification to #secondary-alerts slack with test job status