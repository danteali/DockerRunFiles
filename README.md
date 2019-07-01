# `docker run` files
Archive of Docker run commands to start my local services. This repo should get updated automatically whenever I make any changes to these scripts or add any new services.

In theory, I should be able to have my whole server up and running again in minutes if something happens to break, just be running each of these scripts.

I could have set it all up using docker-compose.yaml files (or one big docker-compose.yaml) but I kinda like using `docker run` commands. Admittedly, docker-compose.yaml would have come in handy for some of the nuances in these files (e.g. adding container to multiple networks) but I used workarounds where needed.

Note that there are a lot more services here than I actually use. But I have used them all at some point or another, or I just start them up periodically if needed. It's handy to have these scripts available to quickly spin up a service instead of having to install and configure something.


### 'Secrets'
Within these scripts you'll see code which pulls in *sensitive* variables (usernames, passwords, etc) from separate `.conf` files. I've used this method to make it easier to share these files without sharing my own secret info. This way I can simply push the files to the repo while excluding the `.conf` files. 

You can simply replace the variables in the scripts with your actual values or you can create your own `.conf` file (in the same directory as the script) containing the relevant variables (make sure to leave an empty line at the end)...

```
EMAIL_ADDRESS=joe_bloggs@email.com
USERNAME=jbloggs
PASSWORD=supersecretpassword

```

### Traefik
A lot of these services are configured to use the Traefik reverse proxy to enable access from the WAN using a domain name which I own. I only expose the ones I know I'll need to access. The services are typically exposed via `https://subdomain.my_domain.com` which makes it nice and easy to access when at work/travelling/etc. Traefik is also configured to automatically set up a Let's Encrypt SSL cert for any proxied address.

Alternatively I could leave all of my services unexposed and access the services using a VPN into my network. But I'm not always on a machine which has the ability to start a VPN session (e.g. work computer). It's a balance of convenience and security. All exposed containers have their own built in authentication or, if not, they have a username/password set up through Traefik. In addition, we also run `fail2ban` (the repo contains script for this container too) which will ban any IP addresses attempting to access my services with more than 3 incorrect login attempts.

I've included my traefik.toml file here for reference. It gets mounted in Traefik container and configures Let's Encrypt, Traefik dashboard access, etc. It will have changed since I uploaded this but I'm not going to keep it up to date as it would mean sanitising it each time. But it's worth looking at since it also shows how to set up reverse proxy access for other services which are not running in docker (e.g. Webmin), or are running elsewhere on your LAN, or how to reverse proxy some docker containers which mysteriously can't be configured properly using the usual docker labels (e.g. pihole).

And by using pihole (the docker run command is in this repo) we can edit the pihole hosts file to redirect any LAN devices trying to reach these proxied addresses so that the traffic resolves straight to the host server instead of exiting the network. So we can therefore still use our nice friendly URLs internally too (and have proper https certs working which has always been a pain when trying to set up local domain resolution).

### Misc Notes

* There is a montoring script [here](https://github.com/danteali/DockerRunFiles/tree/master/monitoring/crontab_monitor) which can be added to crontab to monitor docker containers in case they go down. A different version with clearer comments is available in my [other repo here](https://github.com/danteali/docker_cron_monitor). You should probably use the one from the other repo as the one in this repo has had some additional customisation and is probably no longer as easy to understand. 
