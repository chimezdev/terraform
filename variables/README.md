# VARIABLES IN TERRAFORM
To define centrally controlled reusable values, variables are employed in terraform. Variables values are saved independently from the deployment configuration as such these values can be read and edited from a single source. Depending on the usage, terraform variables are generally divided into ***input***, ***output*** variables and ***local values***.
Terraform compares these different types as follows:
- Input variables are like function arguments.
- Output values are like function return values.
- Local values are like a function's temporary local variables.

# Input Variable
- used as parameters for terraform module, this way the values can be changed without editing the module source code.
- Defined in a variable block in this format;
```
variable "var_name" {
  type = string
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}
```
see terraform documentation for the various arguments that can be in a variable block

## Variable *type* arg value
the type argument in a variable block can hold the following value types;
- string
- number
- bool
and more complex types such as
- list(<TYPE>)
- set(<TYPE>)
- map(<TYPE>)
- object({<ATTR NAME> = <TYPE>, ... })
- tuple([<TYPE>, ...])

## Variable files
1. variables are defined in a file name in this format: ***variables.tfvars (or <FILENAME>.auto.tfvars)*** and will be automatically applied.
2. To apply a different variable `terraform apply -var-file=another-variable-file.tfvars`
3. If the value of a variable is not specified, terraform will prompt you to enter the variable. This is good during testing.
4. Variables can also be specified via the CLI `terraform apply -var="db_pass=$DB_PASS_ENV_VAR"`. **$DB_PASS_ENV_VAR** represents a very sensitive value passed using environmental variable.

# Local Variables
Just like function's local variables allows you to store expressions for reuse only within that terraform module. It is defined in the following format;
```
    locals {
    extra_tag = "extra-tag"
    }
```

# Output Variables
Similar to return values in programming languages, output variables make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use.
- Delare an output variable in the following format;
```
    output "instance_ip_addr" {
        value = aws_instance.server.private_ip
    }

```
- After `terraform apply` command, the following sample output will be gotten
```
    db_instance_addr = "terraform-20210504182745335900000001.cr2ub9wmsmpg.us-east-1.rds.amazonaws.com"
    instance_ip_addr = "172.31.24.95"
```

# CONFIGURING OUR WEB-APP USING VARIABLES
1. Create a new folder `mkdir variables`
2. cd into the folder and run `touch variables.tf` to create the file.
In this file we will define our variable blocks
The first is the region variable
```
    variable "region" {
    description = "Default region for provider"
    type        = string
    default     = "us-east-1"
    }
```
Note that in the *db_pass* variable definition, we have set *sensitive* attr to **True**. Terraform will hide this value from being outputed.
```
    variable "db_pass" {
    description = "Password for DB"
    type        = string
    sensitive   = true
    }
```
## Storing less sensitive data
- create a new file named *terraform.tfvars*. This is where the less sensitive values for the defined variables will be stored.
- store your variable values here
```
domain      = "devopsdeployed.com"
db_name     = "mydb"
db_user     = "foo"
# db_pass = "foobarbaz" #Do not store this here, we will pass the value using CLI
```
## Create your root module
- create the main.tf file and copy the code to it.
- Instead of hard-coding the values such as *ami*, *instance_type*, we will use the input variables we have defined.
- In the instance resource definition, notice that the *ami* and *instance_type* have been defined using the following lines;
```
ami = var.ami
instance_type = var.instance_type
```
- Also, notice that we have defined a local variable and referenced it in the tag definition
```
    tags = {
        Name = var.instance_name
        ExtraTag = local.extra_tag

    }
```
- Define the remaining resources

## Create Output variable
- create the *outputs.tf* file and create the output variables in it
- use the following format to output the instances ip address making it available for another terraform module
```
    output "terra_inst1_ip_addr" {
        value = aws_instance.terra-inst1.public_ip
    }
```
