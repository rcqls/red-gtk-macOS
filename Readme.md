# red/gtk for macOS using docker or vagrant

N.B.: this project is an updated version of `docker-red-gtk` only dedicated to macOS/Catalina user willing to use `red/red:GTK` since 32bits binary is no more considered with this version of macOS.

## Requirement 

Please, before installing, check that these tools are not yet installed

```{bash}
# git is supposed to be installed
brew cask install docker # updates are then automatically managed 
brew cask install xquartz
brew install socat
```

## Quick start

1. Download [docker-red-init.sh](https://raw.githubusercontent.com/rcqls/red-gtk-macOS/master/Docker/Scripts/docker-red-init.sh)
1. Add it to `.bash_profile` (or similar)
```
if [ -f "<path-docker-red-init-sh>/docker-red-init.sh" ];then . <path-docker-red-init-sh>/docker-red-init.sh; fi
```
1. socat service: to connect DISPLAY inside the container to XQuartz:
	* Start the service:  `docker-red service start`
	* Just wait few seconds until you should see a bash window that you can close only if you prefer to open another (less basic) terminal of your choice.
	* This step additionnally creates `~/RedGTK` folder with subfolder `red` (containing the `red/red:GTK branch` from the source repository of [`red`](https://github.com/red/red.git)) and subfolder `bin` where you can install executables inside the container.
1. Build docker image: `docker-red  build `
1. Run the container: `docker-red`
1. Inside the container: 
	* `/home/user/macHome` corresponds to the Home directory to your macOS.
	* On your macOS, everything in `~/RedGTK/bin` is in the `$PATH` inside the container.
	* `red` binary (the latest) is installed inside the container, so just play inside the container as you usually do in a terminal on your macOS.
	* TODO: Add command to easily update the `red` binary to `red-latest` (but since `~/RedGTK/bin` is in the `$PATH` inside the container you should guess how to update it manually).