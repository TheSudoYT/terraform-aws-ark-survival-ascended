# Start From Backup

## Related Ark Arguments

?

## Notes on Saves
- Character profile data .arkprofil
- Map data .ark
- Tribe profiles .arktributetrive

## Driver
Players want to use existing save data and migrate to AWS or have lost their server, but have backups and want to restore from the backup files.

## Outcome
The ability for users to start an Ark server with existing save data

## Deliverables
- A Mechanism for users to inform Terraform on the location of existing save data
- Supported save data locations determined and supported

## Flow
- Start server :white-check-mark:
- Make backups :white-check-mark: ( shipped to s3)
- Server explodes
- Start new server
- Place backups on new erver 
- Start new server
