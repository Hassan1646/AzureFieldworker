// fw app service plan
 resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
     name: 'fwappserviceplan'
     location: resourceGroup().location
     sku: {
       name: 'S1'
       tier: 'Standard'
     }
   }

   output appServicePlanId string = appServicePlan.id