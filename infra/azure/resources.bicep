param imageName string
param name string
param location string = resourceGroup().location

resource containerEnv 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: name
}

resource containerApp 'Microsoft.App/containerapps@2022-03-01' = {
  name: name
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: containerEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 5000
        transport: 'Auto'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: imageName
          name: name
      scale: {
        maxReplicas: 10
        }
      }
    ]
    }
  }
}
