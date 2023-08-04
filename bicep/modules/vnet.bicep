// Parameters
param location string
param virtualNetworkName string
param virtualNetworkPrefix string
param agSubnetName string
param subnetPrefix string = '10.0.1.0/24' // default subnet prefix

// Resources

// Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [
      {
        name: agSubnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

// Outputs
output vnetId string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
