# Add Simple Flask App to Azure via Azure Container Services and Azure Container Registry (ACA)

This repo walks you through the steps to deploy a simple hello world flask app (NoDB) to [Azure Container Services (ACS)](https://learn.microsoft.com/en-us/azure/container-apps/overview) using the Azure Developer CLI.

## System Prerequisites

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Docker](https://docs.docker.com/install/)

## QuickStart
### [OPTIONAL] Step -1: Ensure your container builds locally
    `docker build -t YOURNAME:YOURTAG .`
    `docker run -p EXTERNALPORT:INTERNALPORT YOURNAME:YOURTAG`

### [OPTIONAL] Step 0: Set environment variables
   1. `RESOURCE_GROUP="MYRESOURCEGROUP"`
   2. `LOCATION="westus"` # Change to your preferred
   3. `ENVIRONMENT="MY-ENVIRONMENT"`
   4. `API_NAME="MY-API-NAME"`
   5. `UNQIUE_CHARACTERS="MY-UNIQUE-CHARACTERS"`
### Step 1: Create Container Registry
   `$ACR_NAME="acaprojectname"+$UNIQUE` # must be all lowercase
### Step 2: Create A Resource Group
   `az group create --name $RESOURCE_GROUP --location $LOCATION`

### Step 3: Create a Container Registry
   `az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true`

### Step 4: Build Your Container
    `docker build -t $ACR_NAME.azurecr.io/$API_NAME . --platform linux/amd64`

### Step 5: Login into the Azure Container Registry
    `az acr login --name $ACR_NAME`


### Step 6: Push your container to the Azure Container Registry
    `docker push $ACR_NAME.azurecr.io/$API_NAME`
### Step 7: Create an ACA Environment
   `az containerapp env create --resource-group $RESOURCE_GROUP --name $ENVIRONMENT --location $LOCATION`

### Step 6: Deploy Your Container to the Container App
   ```bash
   az containerapp create \
   --resource-group $RESOURCE_GROUP \
   --name $API_NAME \
   --environment $ENVIRONMENT \
   --image $ACR_NAME.azurecr.io/$API_NAME \
   --target-port INTERNALPORT \
   --ingress 'external' \
   --registry-server "$ACR_NAME.azurecr.io"
    ```

## Known Issues

### My Projet is not in the `src` folder
You can modify the path in your Dockerfile to point to your project folder. For example, if your project is in the `app` folder, you can change the `WORKDIR /src` to `WORKDIR /app` and the `COPY` to `COPY . /app`

### The application path is not `app.py`
You can modify the path in your Dockerfile to point to your app.py file. For example, if your app.py file is in  `src` folder, you can modify the Dockerfile to look like this:

    COPY src .
    CMD ["python", "app.py"]

### The application is not running on port 5000
You can modify the FLASK_PORT in your Dockerfile to point to your app.py file. For example, if your app.py file is running on port 8000, you can modify the Dockerfile to look like this:


### Learn More
Visit 