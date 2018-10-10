#Constant value for build, run and deployment
image_name=face-emotion-app-1
project_id=nissan-helios-189503
cluster_name=emotion-api-cluster-nginx
num_nodes=1
zone=us-central1-b
port=80
version=v7
updated_version=v8

#Build and run docker image on local
deploy-local:
	#build docker image
	docker build -t gcr.io/${project_id}/${image_name}:${version} .
	#run docker image
	docker run -d --name ${image_name} -p $(port):$(port) gcr.io/${project_id}/${image_name}:${version}

#Build and deploy docker image on kubernetes GCP	
deploy-gcp:
	#Build the container image of face emotion application and tag it for uploading
	docker build -t gcr.io/${project_id}/${image_name}:${version} .
	#Using the gcloud command line tool, install the Kubernetes command-line tool
	#kubectl is used to communicate with Kubernetes, which is the cluster orchestration system of GKE clusters
	gcloud components install kubectl
	#Configure Docker command-line tool to authenticate to Container Registry
	gcloud auth configure-docker
	#Use the Docker command-line tool to upload the image to your Container Registry
	docker push gcr.io/${project_id}/${image_name}:${version}
	#Use gcloud command-line tool set the project id:
	gcloud config set project ${project_id}
	#Use gcloud command-line tool set the zone:
	gcloud config set compute/zone ${zone}
	#Create a one-node kubernetes cluster named emotion-api-cluster-nginx on GCP
	gcloud container ${cluster_name} create face-emotion --num-nodes=${num_nodes}
	#Deploy face emotion application, listening on port 80:
	kubectl run ${image_name} --image=gcr.io/${project_id}/${image_name}:v1 --port 80
	#Expose face emotion application to traffic from the Internet
	kubectl expose deployment ${image_name} --type=LoadBalancer --port $(port) --target-port $(port)

#Deploy a new version of app
update-deploy-new-version:
	#Create an image for the v2 version of face emotion application by building the same source code and tagging it as v2
	docker build -t gcr.io/${project_id}/${image_name}:${updated_version} .
	#Push the image to the Google Container Registry
	gcloud docker -- push gcr.io/${project_id}/${image_name}:${updated_version}
	#Apply a rolling update to the existing deployment with an image update
	kubectl set image deployment/${image_name} ${image_name}=gcr.io/${project_id}/${image_name}:${updated_version}

#Destroy the service and kubernetes cluster from gcp
destroy:
	#Delete the Service and deallocate the Cloud Load Balancer created for face emotion Service
	kubectl delete service ${image_name}
	#Delete the container cluster and the resources that make up the container cluster, 
	#such as the compute instances, disks and network resources
	gcloud container clusters delete ${cluster_name}


	