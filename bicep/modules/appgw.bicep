// Parameters
param location string
param virtualNetworkName string
param agSubnetName string
param applicationGatewayName string
param publicIPAddressName string
param appServiceAppHostNamesBlue array
param appServiceAppHostNamesGreen array
param hasGreen bool

// Application Gateway resource
resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, agSubnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIP'
        properties: {
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIPAddressName)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'httpPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'blueBackendPool'
        properties: {
          backendAddresses: [
            { fqdn: 'prjwebsiteblue.azurewebsites.net' }
          ]
        }
      }
      {
        name: 'greenBackendPool'
        properties: {
          backendAddresses: [
            { fqdn: 'prjwebsitegreen.azurewebsites.net' }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'httpPort')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, hasGreen ? 'greenBackendPool' : 'blueBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'httpSetting')
          }
        }
      }
    ]
  }
}

// Outputs (in case you want to retrieve any details from the Application Gateway in the future)
output appGatewayId string = applicationGateway.id
