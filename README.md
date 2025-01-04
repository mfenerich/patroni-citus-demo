# Patroni and Citus on Kubernetes

This project demonstrates the deployment of Patroni with Citus on Kubernetes using Kind (Kubernetes in Docker).

## Prerequisites

- [Docker](https://www.docker.com/)
- [Kind](https://kind.sigs.k8s.io/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/mfenerich/patroni-citus-demo.gi
   cd patroni-citus-demo
   ```

2. **Create a Kind Cluster**

   ```bash
   kind create cluster --name patroni-citus-demo
   ```

3. **Build and Load Docker Image**

   Build the Docker image using the provided `Dockerfile`:

   ```bash
   docker build -f Dockerfile -t patroni-citus-k8s .
   ```

   Load the image into the Kind cluster:

   ```bash
   kind load docker-image patroni-citus-k8s --name patroni-citus-demo
   ```

4. **Deploy on Kubernetes**

   Apply the Kubernetes configuration:

   ```bash
   kubectl apply -f citus_k8s.yaml
   ```

5. **Verify Deployment**

   Check the stateful sets:

   ```bash
   kubectl get sts
   ```

   Check the pods and their roles:

   ```bash
   kubectl get pods -l cluster-name=citusdemo -L role
   ```

## Files

- **Dockerfile**: Defines the container for running Patroni and Citus.
- **citus_k8s.yaml**: Kubernetes manifest for deploying the project.
- **entrypoint.sh**: Entrypoint script for the container.