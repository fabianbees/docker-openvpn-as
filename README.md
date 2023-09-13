## ⚠️**IMPORTANT**⚠️
## This project is an unoffical fork of the (now deprecated) linuxserver docker container.

**This project is not associated with linuxserver.io in any way!**


---








## [fabianbees/openvpn-as](https://github.com/fabianbees/docker-openvpn-as)



[Openvpn-as](https://openvpn.net/index.php/access-server/overview.html) is a full featured secure network tunneling VPN software solution that integrates OpenVPN server capabilities, enterprise management capabilities, simplified OpenVPN Connect UI, and OpenVPN Client software packages that accommodate Windows, MAC, Linux, Android, and iOS environments. OpenVPN Access Server supports a wide range of configurations, including secure and granular remote access to internal network and/ or private cloud network resources and applications with fine-grained access control.

[![openvpn-as](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/openvpn-as-banner.png)](https://openvpn.net/index.php/access-server/overview.html)

## Supported Architectures

We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/).

Simply pulling `fabianbees/openvpn-as` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Image | Tag | Build |
|:------------------:|:------------------:|:--------------:|:-----------------:|
| x86-64 | fabianbees/openvpn-as | latest | ![pipeline status](https://gitlab.fabianbees.de/fabianbees/docker-openvpn-as/badges/master/pipeline.svg) |
| arm64 | fabianbees/openvpn-as | latest | ![pipeline status](https://gitlab.fabianbees.de/fabianbees/docker-openvpn-as/badges/master/pipeline.svg) |

## Version Tags

This image provides various versions that are available via tags. `latest` tag usually provides the latest stable version. Others are considered under development and caution must be exercised when using them.

| Tag | Description |
| :----: | --- |
| latest | Stable releases based on ubuntu 22.04 LTS (jammy) |


## Application Setup

The admin interface is available at `https://DOCKER-HOST-IP:943/admin` (assuming bridge mode).

### Default user/password

With 2.10.0 the default user/password has to be changed to meet the new password requirements of openvpn, so the new default login for versions after 2.10.0 are:
```
Since version 2.10.0

user:       admin
password:   passwOrd+2
```

Until version 2.9.6 please use the following as the default login credentials:
```
Until version 2.9.6

user:       admin
password:   password
```


During first login, make sure that the "Authentication" in the webui is set to "Local" instead of "PAM". Then set up the user accounts with their passwords (user accounts created under PAM do not survive container update or recreation).

The "admin" account is a system (PAM) account and after container update or recreation, its password reverts back to the default. It is highly recommended to block this user's access for security reasons:
1) Create another user and set as an admin,
2) Log in as the new user,
3) Delete the "admin" user in the gui,
4) Modify the `as.conf` file under config/etc and replace the line `boot_pam_users.0=admin` with ~~`#boot_pam_users.0=admin`~~ `boot_pam_users.0=kjhvkhv` (this only has to be done once and will survive container recreation)  
* IMPORTANT NOTE: Commenting out the first pam user in as.conf creates issues in 2.7.5. To make it work while still blocking pam user access, uncomment that line and change admin to a random nonexistent user as described above.

To ensure your devices can connect to your VPN properly, goto Configuration -> Network Settings -> and change the "Hostname or IP Address" section to either your domain name or public ip address.

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose ([recommended](https://docs.linuxserver.io/general/docker-compose))

Compatible with docker-compose v2 schemas.

```yaml
---
version: "2.1"
services:
  openvpn-as:
    image: fabianbees/openvpn-as
    container_name: openvpn-as
    cap_add:
      - NET_ADMIN #required!
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
      - INTERFACE=eth0 #optional
    volumes:
      - <path to data>:/config
    ports:
      - 943:943
      - 9443:9443
      - 1194:1194/udp
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=openvpn-as \
  --cap-add=NET_ADMIN `#required!` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Berlin \
  -e INTERFACE=eth0 `#optional` \
  -p 943:943 \
  -p 9443:9443 \
  -p 1194:1194/udp \
  -v <path to data>:/config \
  --restart unless-stopped \
  fabianbees/openvpn-as
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 943` | Admin GUI port. |
| `-p 9443` | TCP port. |
| `-p 1194/udp` | UDP port. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/Berlin` | Specify a timezone to use EG Europe/Berlin. |
| `-e INTERFACE=eth0` | With bridge networking, leave it as eth0 (or don't include at all), if host or macvlan, set it to your host's network interface, found by running `ifconfig` |
| `-v /config` | Where openvpn-as should store configuration files. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


## Support Info

* Shell access whilst the container is running: `docker exec -it openvpn-as /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f openvpn-as`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' openvpn-as`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' fabianbees/openvpn-as`

## Updating Info


Below are the instructions for updating containers:

### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull openvpn-as`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d openvpn-as`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull fabianbees/openvpn-as`
* Stop the running container: `docker stop openvpn-as`
* Delete the container: `docker rm openvpn-as`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (only use if you don't remember the original parameters)

* Pull the latest image at its tag and replace it with the same env variables in one run:

  ```bash
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once openvpn-as
  ```

* You can also remove the old dangling images: `docker image prune`





## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/fabianbees/docker-openvpn-as.git
cd docker-openvpn-as
docker build \
  --no-cache \
  --pull \
  -t yourname/openvpn-as:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`

```bash
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.



## Versions

* **13.09.23:** - Rebase master/latest to jammy.
* **11.07.23:** - Bump to version 2.12.0.
* **01.07.21:** - Rebase master/latest to focal.
* **15.06.20:** - Add fixes for 2.9.0.
* **04.11.20:** - `xenial` tag is deprecated and there will be no further releases for that tag.
* **22.06.20:** - Added Support for persistent Customization Folders.
* **26.03.20:** - Switch to using the openvpn-as repo for packages.
* **29.08.19:** - Update Application Setup instructions in readme to fix 2.7.5 login issue for existing users.
* **27.08.19:** - Add new clients package to install and upgrade process.
* **22.08.19:** - Prevent auto-start of openvpn after first time install, before configuration is completed.
* **25.07.19:** - Create a xenial branch/tag and rebase master/latest to bionic.
* **07.04.19:** - Fix first time config.
* **03.04.19:** - Big rewrite of the install and update logic of openvpn-as to fix breaking changes (should fix updating from 2.6.1 to 2.7.3), added mysql-client for cluster support.
* **14.03.19:** - Update deb package URL.
* **21.02.19:** - Rebase to xenial due to incompatibility issues on some older host OSes.
* **12.02.19:** - Rename github repo to match the docker hub repo and container name.
* **07.02.19:** - Add pipeline logic and multi arch.
* **31.01.19:** - Add port mappings to docker create sample in readme.
* **26.01.19:** - Removed `privileged` and `host` networking requirements, added `cap-add=NET_ADMIN` requirement instead. `INTERFACE` no longer needs to be defined as in bridge mode, it will use the container's eth0 interface by default.
* **19.12.18:** - Bump to version 2.6.1.
* **10.07.18:** - Bump to version 2.5.2.
* **23.03.18:** - Bump to version 2.5.
* **14.12.17:** - Consolidate layers and fix continuation lines.
* **25.10.17:** - Bump to version 2.1.12.
* **18.08.17:** - Switch default authentication method to local, update readme on how to deactivate the admin user.
* **31.07.17:** - Fix updates of existing openvpn-as installs.
* **07.07.17:** - Bump to version 2.1.9.
* **31.10.16:** - Bump to version 2.1.4.
* **14.10.16:** - Add version layer information.
* **13.09.16:** - Rebuild due to push error to hub on last build.
* **10.09.16:** - Add layer badges to README.
* **28.08.16:** - Add badges to README.
* **01.08.16:** - Rebase to xenial.
* **18.09.15:** - Initial Release.
