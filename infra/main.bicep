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
param webContainerAppName string = ''

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('The image name for the container')
param containerImageName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {'azd-env-name': environmentName, 'azd-env-abbr': abbrs[environmentName]}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName: '${abbrs.resourcesResourceGroups}${environmentName}'
  tags: tags
  location: location
}

module containerApps './core/host/container-apps.bicep' = {
  name: 'containerApps'
  scope: rg
  params: {
    name: 'app'
    containerAppsEnvironmentName: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    logAnalyticsName: monitoring.outputs.logAnalyticsWorkspaceName
  }
}

module resources './resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    name: name
    location: location
  }
}


module github './github/resources.bicep' = {
  name: 'github'
  scope: rg
  params: {
    imagename: 'ghcr.io/kjaymiller/aca-flask-simple:main'
    name: name
    location: location
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
