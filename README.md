# Just a test website with a simple service

* This could serve as a boilerplate for other new services
* Relies on 'resweave` which is not Open-source
* I stole some infrastructure from agilitree/monolithic-roots for this
  that I think could be merged into resweaved or added to a rw-extensions project?

# How to access it from k8s

* First, know that this uses docker-k8s, not actual k8s
* Build the container and then run the deployment
  * `./build/build.sh service -d`
  * `./deploy/deploy.sh`
* Access it via `http://localhost:32754`

## Notes about Ngnix (which is also required)
* install this after starting docker-k8s
* follow instructions here:
  https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-manifests/
  * don't bother with AWS or GCS/Azure instructions
* Find the port by querying the svc in the nginx namespace
  * `kubectl get ns` will get you the namespace
  * `kubectl describe svc nginx-ingress --namespace=nginx-ingress`
  And you can use other `kubectl` commands to find other things
* __NOTE__: This only works for http, setting up https would require additional auth related configuraiton
  which I'm not going to do for now.
  