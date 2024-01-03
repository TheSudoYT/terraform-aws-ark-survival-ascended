# Test using custom GameUserSettings.ini and Game.ini using S3 Objects when Creating Ark Server

- Create S3 bucket
- Upload TestGameUserSettings.ini and TestGame.ini to that S3 bucket
- Download .ini files to Ark server during installation
- Start ark server with custom .ini files
- Validate custom .ini files in use and ark is accessible

## Testing requirements
- Terraform >=v1.6.0