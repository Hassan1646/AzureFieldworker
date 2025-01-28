// ms defender for fw
param location string

resource msDefender 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'VirtualMachines'
  location: location
  properties: {
    pricingTier: 'Standard'
  }
}