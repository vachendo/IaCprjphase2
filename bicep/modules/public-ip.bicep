// Parameters
param location string
param publicIPAddressName string

// Resources

// Public IP address for the Application Gateway
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static' // Changed from 'Dynamic' to 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

// Outputs
output publicIPForAppGW string = publicIPAddress.properties.ipAddress
