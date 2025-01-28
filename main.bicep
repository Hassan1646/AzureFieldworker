param keyVaultName string
param clientId string
param clientSecret string
param tenantId string
param subscriptionId string
param location string = resourceGroup().location
param appServicePlanName string = 'fwappserviceplan'
param appServiceName string = 'fwappservice'



// Key Vault account for FW
resource kv 'Microsoft.KeyVault/vaults@2021-04-01' existing = {
  name: keyVaultName
  scope: subscription()
}

// Obtain secrets from the current Key Vault
var clientIdSecret = listSecret('${kv.id}/secrets/${clientId}', '2021-04-01').value
var clientSecretSecret = listSecret('${kv.id}/secrets/${clientSecret}', '2021-04-01').value
var tenantIdSecret = listSecret('${kv.id}/secrets/${tenantId}', '2021-04-01').value
var subscriptionIdSecret = listSecret('${kv.id}/secrets/${subscriptionId}', '2021-04-01').value

// VN for FW
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'fw-dev-vn'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Network security group resource
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'fw-dev-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-http'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'allow-https'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

//app insights for fieldworker
module appInsights 'applicationinsights.bicep' = {
  name: 'fwappinsights'
  params: {
    location: location
  }
}

// msdefender
//module msDefender 'msdefender.bicep' = {
  //name: 'fwmsdefdeployment'
 // scope: resourceGroup()
  //params: {
  //  location: location
  //}
//}

// Modules for field worker app service
  module appServicePlan 'appserviceplan.bicep' = {
     name: 'appServicePlanDeployment'
   }

   module appService 'appservice.bicep' = {
     name: 'appServiceDeployment'
     params: {
       serverFarmId: appServicePlan.outputs.appServicePlanId
     }
     dependsOn: [
       appServicePlan
     ]
   }


