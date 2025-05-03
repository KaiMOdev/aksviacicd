# AKS CI/CD Demo

Een eenvoudige demo die een AKS-cluster uitrolt via Terraform en GitHub Actions.

## Instructies

1. Maak een Azure Service Principal:
   az ad sp create-for-rbac --name github-aks-sp --role="Contributor" --scopes="/subscriptions/<subscription-id>" --sdk-auth

2. Voeg de JSON-output toe als GitHub secret: `AZURE_CREDENTIALS`

3. Push deze repo naar GitHub

4. De pipeline wordt automatisch gestart en maakt het AKS-cluster aan.
