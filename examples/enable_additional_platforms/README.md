# Enabling Crossplay and Choosing Platforms
This is an example of using the `supported_server_platforms` input to define which platforms can connect to your server.

> [!WARNING]
> Always be mindful of using mods with multiple platforms. Some mods are not supported by all platforms. Check your mod details for more information.

> [!WARNING]
> I have only tested this with PC and ALL. I have only tested PS5 connections when configured as ALL.

## Details
`supported_server_platforms` is a list of strings.

## Example Usage
Relevant inputs:

```HCL
  supported_server_platforms = ["All"]
```
