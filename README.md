# hetzner-utils
Setup of a server at Hetzner Online AG

## Usage
To install our standard OS on a dedicated Hetzner server:
* Login to the Hetzner Robot at https://robot.your-server.de/server
* Make sure that the server has a Reverse DNS Name setup with the fully qualified domain name
* Enable the "rescue system" for this server with Linux 64 bit and a working SSH key 
* Reboot the server to actually make it boot into the rescue system
* Connect via SSH and execute the below command
* If everything went well, the server reboots and you can connect via SSH to the new installation

```bash
curl https://raw.githubusercontent.com/fogs/hetzner-utils/master/ubuntu-16.04.sh | bash -i
```
