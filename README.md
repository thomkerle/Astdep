# Astdep

Stands for Azure Stack Terraform Deployment (Create Once, Destroy Never)

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

## Documentation

You will find useful to see the Wiki pages to see how the repository code can be used:
https://github.com/thomkerle/Astdep/wiki

You should probably start with the [Gettting started page](https://github.com/thomkerle/Astdep/wiki/Getting-started)

## Contributing

in discussion...

## Changelog

in development
- 04-09-2020 Formulation of concept - write some WIKI articles - nothing to run yet 
- 05-06-2020 Checked in code for /examples - not yet implemented dynamic data requests - should run (only examples)


## Donations

[![](https://www.paypalobjects.com/en_US/CH/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6JTJWCRCSKS8G)

https://paypal.me/thomkerle








