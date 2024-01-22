# Just Some Notes

## EFS?!?!

## Current Compute
- EC2

Pros
- Simple

Cons
- Not flexible
- Updating a terraform module input that adjusts the user_data script that builds the ark configuration requires manual termination and recreation of the server.

## Desired Compute
- ASG

### Driver

The ark configuration is built during the first creation of the server when inputs are interpolated into the user_data template. To update the inputs users have to manually ssh and update. This creates an inconsistent state with the terraform configuration unless the user also updates the terraform configuration. Do no want to require users to update terraform code, such as adjusting Tameing speed rate, then force them to manually terminate the server and rerun the terraform apply to recreate it. 

### Goal

1. Users want to update an Ark setting in the .ini so they make the input change in Terraform
2. Users terraform apply
3. ASG Launch config/user_data template updates
4. ASG triggers recreation of the server
5. Recreation downloads most up-to-date save data.

### Challenges

- Recreating the server every time takes approx 15 - 20 minutes due to user_data downloading ark.
- - This can be avoided by providing a custom AMI with ark preinstalled, but this requires users to initially create an AMI. Scope creep and can be potentially off putting to users.
- No mechanism to force ark to save before destroy
- No mechanism to start the new server with an existing save - planned feature

### Pros
- Provides flexibility. Updating a terraform module input that adjusts the user_data script that builds the ark configuration triggers an auto rebuild of the server. 
- Immutable compute layer

### Cons
- More complex
- Increased risk to users in form of unintended scaling up ( $$$$ )
- Potential loss of data
