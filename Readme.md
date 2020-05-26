# red/gtk for macOS using docker or vagrant

N.B.: this project is an updated version of `docker-red-gtk` only dedicated to macOS/Catalina user willing to use `red/red:GTK` since 32bits binary is no more considered with this version of macOS.  

## Quick start

### Requirement 

Please, before installing, check that these tools are not yet installed

```{bash}
brew cask install docker # updates are then automatically managed 
brew cask install xquartz
brew install socat
```

### Main use

1. Download [docker-red-init.sh](https://raw.githubusercontent.com/rcqls/red-gtk-macOS/master/Docker/Scripts/docker-red-init.sh)
1. Add it to `.bash_profile` (or similar)
```
if [ -f "<path-docker-red-init-sh>/docker-red-init.sh" ];then . <path-docker-red-init-sh>/docker-red-init.sh; fi
```
1. socat service: to connect DISPLAY inside the container to XQuartz:
	* start socat: `docker-red service start`
	* stop socat: `docker-red service stop`
1. Build docker image(s): `docker-red  build `
1. Run the container: `docker-red`
1. Inside the container: 
	* `/home/user/macHome` corresponds to the Home directory to your macOS.
	* `red` binary (the latest) is installed inside the container.
	* TODO: To update the `red` binary