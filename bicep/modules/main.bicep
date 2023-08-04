@description('Azure region into which the resources should be deployed')
param location string = 'canadacentral'

@description('The container images of the website')
param containerImage string = 'supervin/cpsy206dockerlab:v1'
param containerImageBlue string = containerImage
param containerImageGreen string = containerImageBlue

@description('The name of the App Service app')
param appServiceAppName string = 'PrjWebsite'
var appServicePlanName = '${appServiceAppName}ServicePlan'
var numOfWebservers = 2
var containerWebsitePort = '8080'

module webApp 'webapp.bicep' = {
  name: 'PrjWebsite'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    numOfWebservers: numOfWebservers
    containerImageBlue: containerImageBlue
    containerImageGreen: containerImageGreen
    containerWebsitePort: containerWebsitePort
  }
}

@description('The default host names of the App Service app')
output appServiceAppHostNamesBlue array = webApp.outputs.appServiceAppHostNamesBlue
output appServiceAppHostNamesGreen array = webApp.outputs.appServiceAppHostNamesGreen

// Deploy a publicIPAddress for the application gateway frontend
var publicIPAddressName = 'PrjWebsitePublicIP'

module publicIP 'public-ip.bicep' = {
  name: 'iacPrjAppGWIPv4'
  params: {
    location: location
    publicIPAddressName: publicIPAddressName
  }
}

@description('The public IPv4 address created')
output publicIPForAppGW string = publicIP.outputs.publicIPForAppGW

// Deploy VNET for Application Gateway
var virtualNetworkName = 'iacPrjVNet'
var virtualNetworkPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var agSubnetName = 'iacPrjAGSubnet'

module vnet 'vnet.bicep' = {
  name: 'iacPrjVNET'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkPrefix: virtualNetworkPrefix
    agSubnetName: agSubnetName
    subnetPrefix: subnetPrefix
  }
}

// Deploy Application Gateway
var applicationGatewayName = 'iacPrjAppGW'

module appGW 'appgw.bicep' = {
  name: 'iacPrjAppGW'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    agSubnetName: agSubnetName
    applicationGatewayName: applicationGatewayName
    publicIPAddressName: publicIPAddressName
    appServiceAppHostNamesBlue: webApp.outputs.appServiceAppHostNamesBlue
    appServiceAppHostNamesGreen: webApp.outputs.appServiceAppHostNamesGreen
    hasGreen: (containerImageBlue !~ containerImageGreen)
  }

  dependsOn: [
    webApp
    publicIP
    vnet
  ]
}
