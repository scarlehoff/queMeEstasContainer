# Docker image for openvpn

Small docker image for a quick setup of a personal use VPN.

To get all of this up and running:

1. First generate the certificates, keys, etc for your server
2. Create some clients (or do it later, doesn't really matter)
3. Build the docker file
4. Run said docker file

It is necessary to install easy-rsa beforehand!


Ok, the first step is to copy client-common.txt.in into client-common.txt, changing the appropiate variables.
Then we can run the following commands:

```bash
./easy_crypto.sh
./new_client.sh DentArthur
source sh_variables
create_container
run_container
```

The `sh_variables` script contains also two helper functions to build and run the containers.

Note: the client-common.txt basically defines how the client is going to connect to the VPN so it will be different for different servers, change at least line 3 of that file!
