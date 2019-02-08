# WebSphere Liberty Helm Chart

## Travis builds

Travis build are kicked off during commits to branches (master or another) and PR creations.  They can be viewed in this link: https://travis.ibm.com/WASCloudPrivate/helm-chart-websphere-liberty

You can then use the generated helm repository to test your changes: http://icpbuild.rtp.raleigh.ibm.com:31532/WASCloudPrivate/helm-chart-websphere-liberty/


## Working with helm locally

### Install CLI
When working with helm charts you'll need to install the helm CLI.  To do so, follow the instructions in here: https://github.com/kubernetes/helm.  That page also has more information about helm, tiller and helpful links, so it's a good site to have bookmarked.

*Note*:  One issue I ran into was that tiller was at version 2.4 and the latest helm was at version 2.6.  This is likely because the ICp version I was running with did not support a tiller version higher than 2.4, so even when I ran `helm init --upgrade` I still got errors about the client and server not being compatible.  To get past this issue I downloaded the 2.4 helm binary, which was compatible with my 2.4 tiller version.  Example of the message you will see if you hit this:  `Error: incompatible versions client[v2.6.0] server[v2.4.1]`

### Packaging your helm chart

This page is very good for explaining the required `chart` structure: https://docs.helm.sh/developing_charts/

After you have the helm chart structure done, simply run `helm package mychart`, where `mychart` is the folder that holds your helm chart files.  This will create a compressed `tgz` file.  

### Installing your helm chart

Before you add your helm chart into a repository you probably want to install it to make sure it's doing what you expected.   Follow the instructions from this blog's step 3 (https://developer.ibm.com/recipes/tutorials/running-istio-on-ibm-cloud-private/#r_step3) and 4 (https://developer.ibm.com/recipes/tutorials/running-istio-on-ibm-cloud-private/#r_step4) to install kubectl and configure it to push into ICp.

After that you can simply install your packaged chart (from the previous step) using the `helm install` command, such as `helm install mychart.tgz`.  

### Add your helm chart to a repository

A helm repository holds a number of packaged helm chart plus a single index.yaml that lists them all.  There are various ways of deploying a chart repository, described in https://docs.helm.sh/developing_charts/#the-chart-repository-guide  (Note: the GitHub pages approach did not work for me).

At some point we'll probably setup an automatic toolchain to pickup charts from this GitHub repository and deploy into a Liberty application serving as our chart repo in Bluemix, but for iteratively and individual development we'll use `helm serve`, which you already have installed! 

All you have to do is put the packaged helm chart into a folder (ie: /charts) and then run this command:  `helm serve --repo-path ./charts --address myhost:myport`

In the example above you must change `myhost` and `myport` into values that match your computer and the port you want to expose (ie: arthur.can.ibm.com:7654).

Helm will create an index.yaml for you and serve on that address.  You can pre-test this by typing in your browser `http://myhost:myport/index.yaml` and you should see the generated index.yaml.  Note that this web server will stop working when you exit the command - so leave it open until you're done your testing.  

### Add new helm repositories into ICp

After you setup your helm repository simply follow the first 3 screenshots from this link (https://developer.ibm.com/recipes/tutorials/running-istio-on-ibm-cloud-private/#r_step6), but use your served address instead, which will be `http://myhost:myport` (values from previous step)

Now your helm chart from the helm repository should be available in the App Center!
