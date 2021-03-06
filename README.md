# `docker run` files
Archive of Docker run commands to start my local services. This repo should get updated automatically whenever I make any changes to these scripts or add any new services.

In theory, I should be able to have my whole server up and running again in minutes if something happens to break, just be running each of these scripts.

I could have set it all up using docker-compose.yaml files (or one big docker-compose.yaml) but I kinda like using `docker run` commands. Admittedly, docker-compose.yaml would have come in handy for some of the nuances in these files (e.g. adding container to multiple networks) but I used workarounds where needed.

Note that there are a lot more services here than I actually have running at any given time. But I have used them all at some point or another, or I just start them up periodically if needed. It's handy to have these scripts available to quickly spin up a service instead of having to install and configure something.

I also have a number of these containers running locally without exposing them to the big bad internet (see notes on Traefik reverse proxy wildcard certificates below to continue to allow https access even if not externally exposed).


### 'Secrets'
Within these scripts you'll see code which pulls in *sensitive* variables (usernames, passwords, etc) from separate `.conf` files. I've used this method to make it easier to share these files without sharing my own secret info. This way I can simply push the files to the repo while excluding the `.conf` files. 

You can simply replace the variables in the scripts with your actual values or you can create your own `.conf` file (in the same directory as the script) containing the relevant variables (make sure to leave an empty line at the end)...

```
EMAIL_ADDRESS=joe_bloggs@email.com
USERNAME=jbloggs
PASSWORD=supersecretpassword

```

### Traefik
*At the time of writing, I am still using Traefik version 1. I will update these scripts to version 2 in coming months as I migrate over.*

A lot of these services are configured to use the Traefik reverse proxy to enable access from the WAN using a domain name which I own. Traefik also allows access to these service on my LAN using the same URL rather than IP:PORT (IP:PORT also works just in case Traefik itself goes down). Importantly Traefik automatically handles the request of SSL certs for any proxied services making it trivial to use https to access everything. 

I only expose the services which I know I'll need to access when away from the LAN. Exposed services are typically accessed on `https://subdomain.my_domain.com` which makes it nice and easy to access when at work/travelling/etc. Traefik is also configured to automatically set up a Let's Encrypt SSL cert for any proxied address.

Alternatively I could leave all of my services unexposed and access the services using a VPN into my network. But I'm not always on a machine which has the ability to start a VPN session (e.g. work computer). It's a balance of convenience and security. All exposed containers have their own built in authentication or, if not, they have a username/password set up through Traefik. In addition, we also run `fail2ban` (the repo contains script for this container too) which will ban any IP addresses attempting to access my services with more than 3 incorrect login attempts.

I've included my traefik.toml configuration file here for reference. It gets mounted in Traefik container and configures Let's Encrypt, Traefik dashboard access, etc. It will have changed since I uploaded this but I'm not going to keep it up to date as it would mean sanitising it each time. But it's worth looking at since it also shows how to set up reverse proxy access for other services which are not running in docker (e.g. Webmin), or are running elsewhere on your LAN, or how to reverse proxy some docker containers which mysteriously can't be configured properly using the usual docker labels (e.g. pihole).



#### External Access
To access your services through Traefik, you need to have a DNS record set up for each service with your hosting provider. The DNS entry needs to point to your WAN IP address. Assuming you have a static IP from your ISP then I find the easiest way to do this is to set up a DNS A record which points directly at your iP address. Then set up CNAME records for each service which point to this A record. You may be fortunate enough to use a hosting provider which allows API access to add/remove DNS records as this enables us to quickly add/remove a services URL from the command line instead of logging into their web GUI. I use NearlyFreeSpeech.net and can use the [Lexicon tool](https://github.com/AnalogJ/lexicon) to configure DNS records in the command line.

If your ISP provided IP changes periodically it will be worth using a dynamic DNS service (e.g. afraid.org) to make sure there is always a URL pointing to your IP address. Then set up CNAME records for each service to point at this dynamic DNS address.

You also need to configure your router/firewall to allow tarffic on ports 443 and 80 to reach your server. Note that all sites will be accessed on https (port 443) but Let's Encrypt uses a challenge/response mechanism to prove you own the URL and it uses http (port 80) for that so it still needs to be accessible.



#### Internal Access
Once our external DNS is set up we can use the same URLs to access the services even if we are on our internal LAN. The SSL certificates will still work too. However by default the traffic would exit our LAN then come back in again. We can keep all traffic local if we can configure DNS resolution to point any LAN devices at our server's IP. We can do this using one of these methods (hint: use #3!):
1. Edit the 'hosts' file on each LAN machine (use Google to find out how to do this as it changes depending on your operating system) so that the machine resolves the URL to the IP of your server. This is really annoying to maintain as each machine needs to have the hosts file updated. 
2. If your router provides DNS for your LAN you can probably edit the hosts file on the router to resolve services centrally. If you are using your router as a DNS server you likely already have a good idea how to configure it to resolve to your proxied addresses, if not then Google it!
3. Use pihole! [the docker run command is in this repo) 

Pihole's main job is an ad blocker for your network. It operates as a local DNS server and blocks common advertising sites. Following pihole config guides (Google it) we end up with all our LAN devices pointing at the pihole for DNS resolution (the DNS nameservers are generally handed out to our devices via DHCP as configured in our router). We can use this to our advantage and edit its hosts file to resolve our proxied URLs. 



#### Unexposed services and HTTPS access
Our service URLs only receive an SSL certificate if they can be reached externally since Let's Encrypt needs to perform it's challenge/response to verify that we own the URL before issuing a certificate. However there is a mechanism to generate a wildcard certificate for our domain (e.g. `*.yourdomain.com`) and configure Traefik to use this for any URLs which do not get their own specifically generated certificate (see traefik.toml [entryPoints.https] section). I followed the guide [here](https://blog.thesparktree.com/generating-intranet-and-private-network-ssl) and used the generated certs in the traefik.toml [entryPoints.https] section. 



### Containers with their own LAN IP
A couple of the containers I use become more useful if they have their own IP address on the LAN (home-assistant, node-red). While not absolutely neccessary I found it useful as it enabled integration with some services to work better (e.g. alexa integration).
To give a docker container its own IP address on the LAN, first we need to create a network interface on the host machine for it. The purpose of this is to allow the host machine to communicate with the container since, by default for security reasons, if a container has it's own LAN IP the host machine is blocked from communicating directly with it. 

You can call the interface whatever you want, but I’m calling this one lan_net-shim:
`sudo ip link add lan_net-shim link enp4s0 type macvlan  mode bridge`

Now we need to configure the interface with our host's own LAN IP address and bring it up:
```
sudo ip addr add 192.168.0.10/32 dev lan_net-shim
sudo ip link set lan_net-shim up
```

Now we need to tell our host to use that interface when communicating with the containers. Decide what IP range you want to reserve for the containers and use it in the following command. For example here we have reserved `192.168.0.224/29` which gives the containers .225 to .231 to use (we don't use the first IP .224 as it's reserved for host <-> container network communication).
`sudo ip route add 192.168.0.224/29 dev lan_net-shim`

We put these commands in a script [here](https://github.com/danteali/DockerRunFiles/blob/master/macvlan/macvlan_docker.cleaned) to be run at host startup by crontab. Just make sure it properly reflects your own IP addresses and ethernet interface. 
Then we need to create a docker network for any containers which get their own IP. Make sure to use the same IP addresses/ranges as used in the host interface above, and also the correct ethernet interface name of your host (get with `ifconfig`): 
```
docker network create \
  -d macvlan \
  --subnet=192.168.0.0/24 \
  --gateway=192.168.0.1 \
  --ip-range=192.168.0.224/29 \
  -o parent=enp4s0 \
  lan_net
```

Then when starting a container use these options to give it it's own IP on the LAN:
```
--network lan_net \
--ip=192.168.0.225 \
```
Also see guide [here](https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/) which helped me.



### aliases
You can make command line interaction with docker a bit easier by adding these aliases to the `.bash_aliases` file in your home directory. You can type these aliases instead of the longer docker commands. You might need to install the JSON parser `jq` as some of these aliases use it to parse/prettify docker json output. Note that one of the aliases is `daliases` which will list all of the other aliases just in case you forget what they are!

Once you update `.bash_aliases` run `source ~/.bash_aliases` to make them work. e.g. type `dps` to list all docker containers running.

```bash
########################
######## DOCKER ########
########################

##list containers
alias dps='docker ps'
##list containers & grep to find string
alias dpsg='docker ps | grep'
##list ALL containers incl stopped
alias dpsa='docker ps -a'
##remove (running) container
alias drm='docker rm -f -v'
##get container ID
alias did='docker inspect --format="{{.Id}}"'
##Get container IP
alias dip='docker inspect --format="{{ .NetworkSettings.IPAddress }}" "$@"'
## Get docker PID
alias dpid='docker inspect --format="{{ .State.Pid }}" "$@"'
##View container logs
alias dlog='docker logs -f'
##list images
alias dim='docker images'

### CLEANUP ###
## remove dangling images
alias drm_i=' docker rmi $(docker images --filter dangling=true -q)' #test comment
##remove stopped containers
alias drm_c='docker rm -v $(docker ps --filter status=exited -q)'
##remove dangling volumes
alias drm_v='docker volume rm $(docker volume ls -f dangling=true -q)'
##prune unused networks
alias drm_net='docker network prune'
##do all cleanup functions above
d_cleanup() { $(drm_i); $(drm_c); $(drm_v); $(drm_net); }

### FUNCTIONS ###
## List container IP address
#dip() { docker inspect -f '{{ json .NetworkSettings.IPAddress }}' $(did $@) | python -mjson.tool ; }
## List container network info
dnet() { docker inspect -f '{{ json .NetworkSettings }}' $(did $@) | python -mjson.tool | jq ; }
## Start sh shell in container
dsh() { docker exec -i -t $@ /bin/sh ; }
## Start bash shell in container
dbash() { docker exec -i -t $@ /bin/bash ; }

##list docker aliases
dalias () {
  tput setaf 6
  echo
  cat ~/.bash_aliases | grep -e 'docker' | grep -e 'alias' | grep -v '##' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort | sed -r 's/^alias //'
  cat ~/.bash_aliases | grep -e 'docker' | grep -e '() { .* }' | grep -v '##' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort | sed -r 's/^alias //'
  tput sgr 0
  echo
}
```



### Misc Notes

* There is a montoring script [here](https://github.com/danteali/DockerRunFiles/tree/master/monitoring/crontab_monitor) which can be added to crontab to monitor docker containers in case they go down. A different version with clearer comments is available in my [other repo here](https://github.com/danteali/docker_cron_monitor). You should probably use the one from the other repo as the one in this repo has had some additional customisation and is probably no longer as easy to understand. 

