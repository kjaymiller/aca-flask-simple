targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param apiContainerAppName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''
param logAnalyticsName string = ''
param resourceGroupName string = ''

param appImageName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {'azd-env-name': environmentName}

@description('Create the Resource Group for the environment.')
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  tags: tags
  location: location
}

module containerApps './core/host/host/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    name: 'app'
    containerAppsEnvironmentName: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${abbrs.appManagedEnvironments}${resourceToken}'
    containerRegistryName: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
}


module monitoring './core/host/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName: '${abbrs.portalDashboards}${resourceToken}'
  }
}
module myapp './azure/app.bicep' = {
  name: 'myapp'
  scope: rg
  params: {
    name: !empty(apiContainerAppName) ? apiContainerAppName : '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    imageName: appImageName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
  }
}

output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output APPLICATIONINSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerApps.outputs.registryName
