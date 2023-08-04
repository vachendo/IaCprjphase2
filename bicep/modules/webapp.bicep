// Parameters
param location string
param appServiceAppName string
param appServicePlanName string
param numOfWebservers int
param containerImageBlue string
param containerImageGreen string
param containerWebsitePort string

// Resources

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'P'
    capacity: numOfWebservers
  }
  kind: 'linux'
  properties: {
    reserved: true // for Linux
  }
}

// Blue WebApp
resource appServiceBlue 'Microsoft.Web/sites@2021-01-01' = {
  name: '${appServiceAppName}Blue'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: containerImageBlue
        }
        {
          name: 'WEBSITES_PORT'
          value: containerWebsitePort
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// Green WebApp
resource appServiceGreen 'Microsoft.Web/sites@2021-01-01' = {
  name: '${appServiceAppName}Green'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: containerImageGreen
        }
        {
          name: 'WEBSITES_PORT'
          value: containerWebsitePort
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// Outputs
output appServiceAppHostNamesBlue array = [appServiceBlue.properties.defaultHostName]
output appServiceAppHostNamesGreen array = [appServiceGreen.properties.defaultHostName]
