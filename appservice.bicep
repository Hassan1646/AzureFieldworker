// app service for field worker
  param serverFarmId string

   resource appService 'Microsoft.Web/sites@2021-02-01' = {
     name: 'fwapplicationsservice'
     location: resourceGroup().location
     properties: {
       serverFarmId: serverFarmId
     }
   }