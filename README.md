# Add Simple Flask App to Azure via Azure Container Services and Azure Container Registry (ACA)

This repo walks you through the steps to deploy a simple hello world flask app (NoDB) to [Azure Container Services (ACS)](https://learn.microsoft.com/en-us/azure/container-apps/overview) using the Azure Developer CLI.

## System Prerequisites

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Docker](https://docs.docker.com/install/)

## QuickStart (Deploy this Project) Estimated time: 8 minutes

If you want to deploy this project to Azure, follow these steps:

#### Instructions

`text in code blocks` are commands that you should enter into your terminal.

`<Replace text in Brackets>` (Replace text in all caps) with your own values. Follow the casing and spacing of the example:

* `<camelCase>`
* `<snake_case>`
* `<kebab-case>`
* `<PascalCase>`
* `<MACRO_CASE>`

follow the guidance in the comments `foo # follow these notes`
### [OPTIONAL] Step -1: Ensure your container builds locally
    `docker build -t YOURNAME:YOURTAG .`
    `docker run -p EXTERNALPORT:INTERNALPORT YOURNAME:YOURTAG`

This ensures that your app itself is working and issues will not be caused by syntax or other issues.

### [OPTIONAL] Step 0: Set environment variables

Setting the variables below will make entering commands a little faster and more consistent.

   1. `RESOURCE_GROUP="<my-resource-group>"`
   2. `LOCATION="westus"` # Change to your preferred
   3. `ENVIRONMENT="MY-ENVIRONMENT"`
   4. `API_NAME="MY-API-NAME"`
   5. `UNQIUE_CHARACTERS="MY-UNIQUE-CHARACTERS"` # to ensure a truly unique name
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