$app = ""
$provider = ""
$region = ""
$env = ""

write-output "Create base terraform templates"
@("main.tf", "data.tf", "outputs.tf") | % { new-item -Type File $_ }

if(!(get-item -path "providers.tf")) {
    write-output "Create providers file"
    new-item -type file "providers.tf" -value @"
    provider "$($provider)" {
        region = var.region
    }
"@
}

if(!(get-item -path "variables.tf")) {
    write-output "Create variables file"
    new-item -type file "variables.tf" -value @"
    variable "region" {
      description = "the region to create resources in"
      type  = string
      default = "$($region)"
    }
"@
}

if(!(get-item -path "locals.tf")) {
    write-output "Create locals file"
    new-item -type file "locals.tf" -value @"
    locals {
        tags = {
        environment = "$($environment)"
        application = "$($application)"
        }
    }
"@
}

if(!(get-item -path "backend.tf")) {
    write-output "Create backend file"
    new-item -type file "backend.tf" -value @'
    terraform {
    }
'@
}

write-output "Create default terraform variable file"
mkdir -p tfvars && new-item -type file "tfvars/main.tfvars"

write-output "Create terraform prehook"
mkdir "hooks"

new-item -type file "hooks/pre-commit.ps1" -value @'
    $base_path = pwd
    $processed_paths = @()

    $diff = git diff --name-only
    $diff | % {
        $changed_path = split-path $_
    
        if($changed_path -notin $processed_paths) {
            cd $base_path/$changed_path && terraform fmt -recursive && `
            terraform init -backend=false && terraform validate

            $processed_paths += $changed_path
        }
    }
'@