# cf-terraforming-import-tfstate

Generate a Terraform tfstate from existing Cloudflare infrastructure. Assume we have an existing zone on Cloudflare with DNS records and firewall rules configured. We want to start managing this zone in Terraform, but we don’t want to have to define all of our configuration by hand.

# 🚀 Javascript full-stack 🚀

https://github.com/coding-to-music/cf-terraforming-import-tfstate

From https://blog.cloudflare.com/cloudflares-partnership-with-hashicorp-and-bootstrapping-terraform-with-cf-terraforming/

https://github.com/cloudflare/cf-terraforming

https://github.com/cloudflare/terraform-provider-cloudflare

https://developers.cloudflare.com/terraform/installing

https://learn.hashicorp.com/tutorials/terraform/github-oauth?in=terraform/cloud

https://developers.cloudflare.com/cloudflare-one/identity/idp-integration/github

https://www.terraform.io/cloud-docs/vcs/github

https://docs.github.com/en/developers/apps/building-github-apps/authenticating-with-github-apps#generating-a-private-key

## Environment Values

```java
# Need to run this export to run the terraform apply

export CLOUDFLARE_API_TOKEN=from dashboard
```

## Errors and messages

Steps to reproduce:

Following instructions in this tutorial:

https://developers.cloudflare.com/cloudflare-one/identity/idp-integration/github

copy terraform.tfvars-example to terraform.tfvars

set variable values in terraform.tfvars

```java
aws_region         = "us-east-1"
site_domain        = "mydomain.com"
staging_domain     = "staging.mydomain.com"
argo_subdomain     = "argo.mydomain.com"
cloudflare_account_id = "< from dash.cloudflare -->domain-->overview-->right-side >"
zone_id = "< from dash.cloudflare -->domain-->overview-->right-side >"

GITHUB_CLIENT_ID="< from github settings->apps >"
GITHUB_SECRET="< from github settings->apps >"
```

```java
export CLOUDFLARE_API_TOKEN=from dashboard

terraform init
terraform plan
terraform apply -auto-approve
```

Here is the provider that is showing the error, line 59 of cloudflare.tf

```java
# oauth
resource "cloudflare_access_identity_provider" "github_oauth" {
  # zone_id = data.cloudflare_zones.domain.zones[0].id
  account_id = var.cloudflare_account_id
  name       = "GitHub OAuth"
  type       = "github"
  config {
    client_id     = var.GITHUB_CLIENT_ID
    client_secret = var.GITHUB_SECRET
  }
}
```

Error output:

```java
Terraform will perform the following actions:

  # cloudflare_access_identity_provider.github_oauth will be created
  + resource "cloudflare_access_identity_provider" "github_oauth" {
      + account_id = "****************"
      + id         = (known after apply)
      + name       = "GitHub OAuth"
      + type       = "github"

      + config {
          + client_id     = "****************"
          + client_secret = "**********************************"
          + redirect_url  = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
cloudflare_access_identity_provider.github_oauth: Creating...
╷
│ Error: error creating Access Identity Provider for ID "": Authentication error (10000)
│
│   with cloudflare_access_identity_provider.github_oauth,
│   on cloudflare.tf line 59, in resource "cloudflare_access_identity_provider" "github_oauth":
│   59: resource "cloudflare_access_identity_provider" "github_oauth" {
```

## GitHub

```java
git init
git add .
git remote remove origin
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:coding-to-music/cf-terraforming-import-tfstate.git
git push -u origin main
```

# How to use the new cf-terraforming

With that, let’s look at the new cf-terraforming in action. For this walkthrough let’s assume we have an existing zone on Cloudflare with DNS records and firewall rules configured. We want to start managing this zone in Terraform, but we don’t want to have to define all of our configuration by hand.

Our goal is to have a ".tf" file with the DNS records resources and firewall rules along with filter resources AND for Terraform to be aware of the equivalent state for those resources. Our inputs are the zone we already have created in Cloudflare, and our tool is the cf-terraforming library. If you are following along at home, you will need terraform installed and at least Go v1.12.x installed.

## Getting the environment setup

Before we can use cf-terraforming or the provider, we need an API token. I’ll briefly go through the steps here, but for a more in-depth walkthrough see the API developer docs. On the Cloudflare dashboard we generate an API token here with the following setup:

```java
Permissions
Zone:DNS:Read
Zone:Firewall Services:Read

Zone Resources:
garrettgalow.party (my zone, but this should be your own)

TTL
Valid until: 2021-03-30 00:00:00Z
```

Note: I set an expiration date on the token so that when I inevitably forget about this token, it will expire and reduce the risk of exposure in the future. This is optional, but it’s a good practice when creating tokens you only need for a short period of time especially if they have edit access.

Image: API Token summary from the Cloudflare Dashboard

Now we set the API Token we created as an environment variable so that both Terraform and cf-terraforming can access it for any commands (and so I don’t have to remove it from code examples).

```java
$export CLOUDFLARE_API_TOKEN=<token_secret>
```

Terraform requires us to have a folder to hold our Terraform configuration and state. For that we create a folder for our use case and create a cloudflare.tf config file with a provider definition for Cloudflare so Terraform knows we will be using the Cloudflare provider.

```java
mkdir terraforming_test
cd terraforming_test
```

```java
cat > cloudflare.tf <<'EOF'
terraform {
    required_providers {
        cloudflare = {
            source = "cloudflare/cloudflare"
        }
    }
}

provider "cloudflare" {
# api_token  = ""  ## Commented out as we are using an environment var
}
EOF
```

Here is the content of our cloudflare.tf file if you would rather copy and paste it into your text editor of choice:

```java
terraform {
    required_providers {
        cloudflare = {
            source = "cloudflare/cloudflare"
        }
    }
}

provider "cloudflare" {
# api_token  = ""  ## Commented out as we are using an environment var
}
```

We call terraform init to ensure Terraform is fully initialized and has the Cloudflare provider installed. At the time of writing this blog post, this is what terraform -v gives me for version info. We recommend that you use the latest versions of both Terraform and the Cloudflare provider.

```java
terraform -v
```

Output

```java
Terraform v0.14.10
+ provider registry.terraform.io/cloudflare/cloudflare v2.19.2

# for me

Terraform v1.2.2
on linux_amd64
+ provider registry.terraform.io/cloudflare/cloudflare v3.16.0
```

## Install cf-terraforming

https://github.com/cloudflare/cf-terraforming

Since not doing Mac OS / Brew, need to download from GitHub Releases

https://github.com/cloudflare/cf-terraforming/releases

```java
wget https://github.com/cloudflare/cf-terraforming/releases/download/v0.7.4/cf-terraforming_0.7.4_linux_amd64.tar.gz
```

```java
sudo mv cf-terraforming_0.7.4_linux_amd64.tar.gz /usr/local/bin

cd /usr/local/bin

```

```java
tar xvf cf-terraforming_0.7.4_linux_amd64.tar.gz
```

### remove the tar file

```java
sudo rm -rf cf-terraforming_0.7.4_linux_amd64.tar.gz

sudo rm -rf README.md LICENSE CHANGELOG.md
```

```java
whereis cf-terraforming
```

Output

```java
cf-terraforming: /usr/local/bin/cf-terraforming
```

Check the version

```java
cf-terraforming --version
```

Output

```java
Error: unknown flag: --version
Usage:
  cf-terraforming [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  generate    Fetch resources from the Cloudflare API and generate the respective Terraform stanzas
  help        Help about any command
  import      Output `terraform import` compatible commands in order to import resources into state
  version     Print the version number of cf-terraforming

Flags:
  -a, --account string                  Use specific account ID for commands
  -c, --config string                   Path to config file (default "/home/tmc/.cf-terraforming.yaml")
  -e, --email string                    API Email address associated with your account
  -h, --help                            help for cf-terraforming
      --hostname string                 Hostname to use to query the API
  -k, --key string                      API Key generated on the 'My Profile' page. See: https://dash.cloudflare.com/profile
      --resource-type string            Which resource you wish to generate
      --terraform-install-path string   Path to the Terraform installation (default ".")
  -t, --token string                    API Token
  -v, --verbose                         Specify verbose output (same as setting log level to debug)
  -z, --zone string                     Limit the export to a single zone ID

Use "cf-terraforming [command] --help" for more information about a command.

ERRO[0000] unknown flag: --version
```

Check the version

```java
cf-terraforming version
```

Output

```java
cf-terraforming v0.7.4
```

## Install Golang (Mac OS / Brew only)

```java
sudo apt  install golang-go
```

And finally we install cf-terraforming with the following command:

```java
# This is for Brew / Mac OS, not Ubuntu

GO111MODULE=on go get -u github.com/cloudflare/cf-terraforming/...
```

Output:

```java
go: finding golang.org/x/net latest
go: finding golang.org/x/sys latest
go: finding golang.org/x/time latest
go: finding golang.org/x/crypto latest
```

If you’re using Homebrew on MacOS, this can be simplified to:

```java
brew tap cloudflare/cloudflare
brew install --cask cloudflare/cloudflare/cf-terraforming
```

## Using cf-terraforming to generate Terraform configuration

We are now ready to start generating a Terraform config. To begin, we run cf-terraforming to generate the first blocks of config for the DNS record resources and append it to the cloudflare.tf file we previously created.

```java
cf-terraforming generate --resource-type cloudflare_record --zone <zone_id> >> cloudflare.tf
```

Breaking this command down:

- generate is the command that will produce a valid HCL config of resources

- --resource-type specifies the Terraform resource name that we want to generate an HCL config for. You can only generate configuration for one resource at a time. In this example we are using cloudflare_record

- --zone specifies the Cloudflare zone ID we wish to fetch all the DNS records for so cf-terraforming can create the appropriate API calls

Example:

```java
cf-terraforming generate --resource-type cloudflare_record --zone 9c2f972575d986b99fa03c7bbfaab414 >> cloudflare.tf
```

Success will return with no output to console. If you want to see the output before adding it to the config file, run the command without >> cloudflare.tf and it will output to console.

Here is the partial output in my case, if it is not appended to the config file:

```java
cf-terraforming generate --resource-type cloudflare_record --zone 9c2f972575d986b99fa03c7bbfaab414
```

```java
resource "cloudflare_record" "terraform_managed_resource_db185030f44e358e1c2162a9ecda7253" {
name = "api"
proxied = true
ttl = 1
type = "A"
value = "x.x.x.x"
zone_id = "9c2f972575d986b99fa03c7bbfaab414"
}
resource "cloudflare_record" "terraform_managed_resource_e908d014ebef5011d5981b3ba961a011" {
...
```

The output resources are given standardized names of “terraform*managed_resource*<resource_id>”. Because the resource id is included in the name, the object names between the config we just exported and the state we will import will always be consistent. This is necessary to ensure Terraform knows which config belongs to which state.

After generating the DNS record resources, we now do the same for both firewall rules and filters.

```java
cf-terraforming generate --resource-type cloudflare_firewall_rule --zone <zone_id> >> cloudflare.tf

cf-terraforming generate --resource-type cloudflare_filter --zone <zone_id> >> cloudflare.tf
```

Example:

```java
cf-terraforming generate --resource-type cloudflare_firewall_rule --zone 9c2f972575d986b99fa03c7bbfaab414 >> cloudflare.tf

cf-terraforming generate --resource-type cloudflare_filter --zone 9c2f972575d986b99fa03c7bbfaab414 >> cloudflare.tf
```

## Using cf-terraforming to import Terraform state

Before we can ask Terraform to verify the config, we need to import the state so that Terraform does not attempt to create new objects but instead reuses the existing objects we already have in Cloudflare.

Similar to what we did with the generate command, we use the import command to generate terraform import commands.

```java
cf-terraforming import --resource-type cloudflare_record --zone <zone_id>
```

Breaking this command down:

- import is the command that will produce a valid terraform import command that we can then run
- --resource-type (same as the generate command) specifies the Terraform resource name that we want to create import commands for. You can only use one resource at a time. In this example we are using cloudflare_record
- --zone (same as the generate command) specifies the Cloudflare zone ID we wish to fetch all the DNS records for so cf-terraforming can populate the commands with the appropriate API calls

And an example with output:

```java
cf-terraforming import --resource-type cloudflare_record --zone 9c2f972575d986b99fa03c7bbfaab414
terraform import cloudflare_record.terraform_managed_resource_db185030f44e358e1c2162a9ecda7253 9c2f972575d986b99fa03c7bbfaab414/db185030f44e358e1c2162a9ecda7253

terraform import cloudflare_record.terraform_managed_resource_e908d014ebef5011d5981b3ba961a011 9c2f972575d986b99fa03c7bbfaab414/e908d014ebef5011d5981b3ba961a011

terraform import cloudflare_record.terraform_managed_resource_3f62e6950a5e0889a14cf5b913e87699 9c2f972575d986b99fa03c7bbfaab414/3f62e6950a5e0889a14cf5b913e87699

terraform import cloudflare_record.terraform_managed_resource_47581f47852ad2ba61df90b15933903d 9c2f972575d986b99fa03c7bbfaab414/47581f47852ad2ba61df90b15933903d$
```

The output of this will be ready to use terraform import commands. Running the generated terraform import command will leverage existing Cloudflare Terraform provider functionality to import the resource state into Terraform’s terraform.tfstate file. This removes the tedium of pulling all the appropriate resource IDs from Cloudflare’s API and then formatting these commands one by one. The order of operations of the config then state is important as Terraform expects there to be configuration in the .tf file for these resources before importing the state.

Note: Be careful when you actually import these resources, though, as from that point on any subsequent Terraform actions like plan or apply will expect this resource to be there. Removing the state is possible but requires manually editing the terraform.tfstate file. Terraform does keep a backup locally in case you make a mistake though.

Now we actually run these terraform import commands to import the state. Below shows what that looks like for a single resource.

```java
terraform import cloudflare_record.terraform_managed_resource_47581f47852ad2ba61df90b15933903d 9c2f972575d986b99fa03c7bbfaab414/47581f47852ad2ba61df90b15933903d

cloudflare_record.terraform_managed_resource_47581f47852ad2ba61df90b15933903d: Importing from ID "9c2f972575d986b99fa03c7bbfaab414/47581f47852ad2ba61df90b15933903d"...

cloudflare_record.terraform_managed_resource_47581f47852ad2ba61df90b15933903d: Import prepared!

Prepared cloudflare_record for import

cloudflare_record.terraform_managed_resource_47581f47852ad2ba61df90b15933903d: Refreshing state... [id=47581f47852ad2ba61df90b15933903d]

Import successful!
```

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
With cloudflare_record imported, now we do the same for the firewall_rules and filters.

```java
cf-terraforming import --resource-type cloudflare_firewall_rule --zone <zone_id>

cf-terraforming import --resource-type cloudflare_filter --zone <zone_id>
```

Shown with output:

```java
cf-terraforming import --resource-type cloudflare_firewall_rule --zone 9c2f972575d986b99fa03c7bbfaab414

terraform import cloudflare_firewall_rule.terraform_managed_resource_0de909f3229341a2b8214737903f2caf 9c2f972575d986b99fa03c7bbfaab414/0de909f3229341a2b8214737903f2caf

terraform import cloudflare_firewall_rule.terraform_managed_resource_0c722eb85e1c47dcac83b5824bad4a7c 9c2f972575d986b99fa03c7bbfaab414/0c722eb85e1c47dcac83b5824bad4a7c

cf-terraforming import --resource-type cloudflare_filter --zone 9c2f972575d986b99fa03c7bbfaab414

terraform import cloudflare_filter.terraform_managed_resource_ee048570bb874972bbb6557f7529e094 9c2f972575d986b99fa03c7bbfaab414/ee048570bb874972bbb6557f7529e094

terraform import cloudflare_filter.terraform_managed_resource_1bb6cd50e2534a64a9ec698fd841ffc5 9c2f972575d986b99fa03c7bbfaab414/1bb6cd50e2534a64a9ec698fd841ffc5
```

As with cloudflare_record, we run these terraform import commands to ensure all the state is successfully imported.

## Verifying everything is correct

Now that we have both the configuration and state in place, we call terraform plan to see if Terraform can verify everything is in place. If all goes well then you will be greeted with the following “nothing to do” message:

- No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.

You now can begin managing these resources in Terraform. If you want to add more resources into Terraform, follow these steps for other resources. You can find which resources are supported in the README. We will add additional resources over time, but if there are specific ones you are looking for, please create GitHub issues or upvote any existing ones.
