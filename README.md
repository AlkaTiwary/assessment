# assessment
1.Deploying a Web Application on Kubernetes:
docker build -t alkatiwary/sys:0.1 .(to build)
docker push alkatiwary/sys:0.1(to push into the repository)
docker run -d -p 8761:80 alkatiwary/sys:0.1(to run along with port mapping)
kubectl apply -f deployment.yaml(to apply deployment file)
kubectl get pods(to get running status of the pods)
kubectl apply -f service.yaml(to apply service file)
minikube service mimi-service1(to start the service file)
2.Deploying AWS Infrastructure with Terraform:
terraform init
terraform plan
terraform apply

 
