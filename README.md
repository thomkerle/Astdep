# Astdep


## Goal
The goal of this project is to provide code that can be used with Azure DevOps using one or more pipelines to deploy infrastructure to Azure Stack. In contrast to the usual Terraform approach, to parameterize and then deploy the resource templates, in this project the variables are used as an approach for dynamic configuration of the Terraform resource templates, with the aim of not having to use recurring templates again.

## How to reach this goal
To achieve this goal, Terraform is used in such a way that new templates are generated dynamically, depending on the content of the variables required for deployment. If, for example, several virtual machines are to be created in a deployment step, these variable definitions are saved as a map in a list. Terraform then creates the templates for the VMs itself depending on the number of elements in the list and then uses Terraform Init and Apply again from Terraform to iteratively deploy all of the templates created in this way as code.

Limitations:
- Terraform cannot generate any useful status files under this use case

Workaround:
- Therefore, once resources have been created that are to be removed, they must be removed manually in the Azure Stack Portal

## Using Astdep for infrastructure deployment

Basic Requirements:
- Azure Stack Enviroment to deploy Infrastructure
- MSDN Subscription or some aequivalent to use Azure DevOps (former Visual Studio Online)








