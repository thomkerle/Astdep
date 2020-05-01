## Folder overview
Base folder where Azure DevOps Pipelines acts on to generate dynamically Terraform resources.

## Azure DevOps Pipelines
The Pipeline has a name to identify the things if fulfills, for example `PIP-North-Prod-BuildBaseInfra`
(Like the name suggests for the project North in production environment a base infrastructure will be created.)
and an Agent Pool of machines which can do the provisioning.
It's expected to use a Linux pool like `Hosted Ubuntu 16.04`

## Pipeline elements
### Get sources
Repository where the code to deploy is stored. This repository will be downloaded to the provisioning server
### Agent job
Consists of several subtasks
#### Task 1 : Command Line Script
In this task additional files can be downloaded that are not included in the repository.This depends on how the projects 
are organized.
Example:
```
echo ADDING SUBMODULES 

git submodule add https://$(username):$(userpass)@$(url)/$(project)_additional_resources deploy
git submodule add https://$(username):$(userpass)@$(url)/$(project)_additional_variables variables
git submodule add https://$(username):$(userpass)@$(url)/additional_terraform_code terraform

echo  DONE ADDING SUBMODULES

```
Variables here used (`username, userpass, url, project`), can be saved for each pipeline. The variables are evaluated at runtime.
#### Task 2 : Download secure file
In this task a secure file will be used to define how Terraform can have access to create ressources on the target system
```
client_map = {
	arm_endpoint    = "https://url"
	subscription_id = "xxx"
	client_id       = "yyy"
	client_secret   = "zzz"
	tenant_id       = "ttt"
}

backend = {
	storage_account_name ="worldwide unique name for storage account"
	container_name ="tfstatetest|tfstateprod|tfstatestaging"
	key ="random string"
	access_key = "A long access key for storage container"
	endpoint = "url"
}
```
#### Task 3 : Command Line script
Additional tasks - Optional
Here an example how to merge variables to one file from different repository sources:

```
echo  MERGING TERRAFORM VARIABLE FILE WITH SECRET FILE
echo  *************************************************************
ls -la
cat $(Agent.TempDirectory)/SecureFileContent.tfvars >> temp.tfvars
cat $(Build.SourcesDirectory)/live/$(environment)/$(user)/$(project)/vars.tfvars >> temp.tfvars
rm $(Build.SourcesDirectory)/live/$(environment)/$(user)/$(project)/vars.tfvars
mv temp.tfvars $(Build.SourcesDirectory)/live/$(Environment)/$(user)/$(project)/vars.tfvars

echo END OF MERGE
echo ***************************************************************
```
#### Task 5 : Use Terraform
Terraform Installer : Task provided by Microsoft
#### Task 6 : Terraform init
Terraform CLI : Task provided by Microsoft
#### Task 7 : Terraform apply
Terraform CLI : Task provide by Microsoft


