# red/gtk for macOS using docker or vagrant

N.B.: this project is a light udated version of `docker-red-gtk` dedicated to macOS/Catalina user willing to use `red/red:GTK` since 32bits binary is no more considered with this version of macOS.  

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
1. socat service: 
	* start socat: `docker-red service start`
	* stop socat: `docker-red service stop`
1. Build docker image(s): `docker-red [--dist ubuntu|arch|centos] build ` (default image built is ubuntu)
1. Tasks:
	* Run the container: `docker-red [--dist ubuntu|arch|centos] [repl]`
	* Compile: `docker-red [--dist ubuntu|arch|centos] [-c -u -r] [--root <red-relative-path> or <red-absolue-path-inside-container>] red-script`
	* Execute: `docker-red [--dist ubuntu|arch|centos] binary`

### Tutorial

In this tutorial, I will assume that `~/Github/red` is the current `red/red:GTK` branch (`git clone -b GTK https://github.com/red/red `) and the host system is macOS.

Notice that the script `red-compile` (which can be improved to be much closer to the official `red` binary, the main difference being that `red` binary does not require `red` source when `red-compile` does).

As a last comment, let us realize that `red/red:GTK` allows us to cross-compile `View` code on `linux`, `macOS` and `windows` from `linux`, `macOS` and `windows` (not tested on `Windows` yet). Thanks `Red Team` to provide this just amazing `red` language. 

#### configuration (for macOS user only)

Assuming that I have forked `rcqls/docker-red-gtk` at `~/Github/docker-red-gtk`, I add to the `~/.bash_profile`:

```{bash}
if [ -f "$HOME/Github/docker-red-gtk/Scripts/docker-red-init.sh" ];then . $HOME/Github/docker-red-gtk/Scripts/docker-red-init.sh; fi
```

Then you can easily build your `rcqls/red-gtk-ubuntu` image by openning a terminal:

```{bash}
## this is made automatically when openning a terminal
. ~/.bash_profile # if terminal already open

## create docker image 
docker-red build

## usual docker command (not necessary but here as a reminder)
docker images # list of image
docker ps # list of container (but no red-gtk container created yet)
```
That's it for preliminary settings to do **once**!

As a complementary note, `docker-red`, as a development tool,  allows us to create other linux distribution docker images: Centos, Archlinux and Alpine (which has a small x11 issue). Alpine is an interesting image since it is the smallest in size (three times smaller than Ubuntu one's). Notice however that for Alpine `rebol-core-278-4-2.tar.gz` is required when `rebol-core-278-4-3.tar.gz` is usually used.

```{bash}
## Do not run if not interested, only useful for testing tools!
docker-red --dist centos build
docker-red --dist arch build
```

#### Quick minimal use case: console inside the container 

Before using `docker-red` to play with the usual console, macOS user has to execute socat `docker-red service start`. When this is done only once (TODO: make this automatically called when `docker-red` first used), we can play inside the linux container:

```{bash}
docker-red
## then inside the container
console # open a red console with `View` activated
## inside the console
view [button "hello"]
```

or directly

```{bash}
docker-red repl
```

#### compilation script inside guest from host

Even if this can be changed later, a `red/red:GTK` branch is cloned inside the container at `home/user/red/red`. If `~/Github/red` (host system) does not exist, `home/user/red/red` is used to compile any red script using `red-compile` bash script. If `~/Github/red` exists in the host system, it is used (instead of `home/user/red/red`) inside the container which is mounted in the guest at `/home/user/work/Github/red`. Folder `~/Github/red` is of course easier to maintain.

```{bash}
## compilation
docker-red compile Github/red/tests/react-test.red
## to see binaries inside ~/.RedGTK which now contains react-test 
docker-red ls 
## to play with the newly creaty react-test
docker-red run react-test 
```
#### compilation of console-view.red

To get the latest console-view and run it
```{bash}
## optionnal: update your ~/Github/red repo (git pull)
docker-red compile Github/red/environment/console/CLI/console-view.red
## once console-view.red compiled it is then called by repl subcommand
docker-red repl
## inside the repl, test it
view [button "hello"]
```

#### cross-compilation 

Even it is completely useless, you can MAGICALLY cross-compile `react-test.red` for macOS (only if it is your OS) from the linux container (I am in love with this feature).

```{bash}
docker-red -t darwin -o console-view-macOS compile Github/red/environment/console/CLI/console-view.red 
## console-view-macOS in your home directory `~/`
./console-view-macOS
## inside the repl
view [button "hello"]
```
The arguments before `compile` subcommand are used for `red-compile` bash script inside container. Here because of `-t darwin`, cross-compilation is activated and
`-o console-view-macOS` option provide the binary in the home directory (not copied inside `~/.RedGTK`).

#### cross-compilation of console-view.red (docker-red not needed)

As a macOS user and when developing and playing with `red/red:GTK` linux branch, I always forgot that I could cross-compile all the linux code from macOS thanks to the magic cross-compilation. For instance, I can compile `react-test.red` for linux without using the linux container.
Here I will use the same bash script [red-compile](https://raw.githubusercontent.com/rcqls/docker-red-gtk/master/Scripts/red-compile)

```{bash}
## red-compile (~/Github/red) is hard linked to ~/bin (which is in my PATH) but you can download it (link above)
red-compile --args "-t linux" Github/red/environment/console/CLI/console-view.red
```

or with the new script [reds](https://raw.githubusercontent.com/rcqls/docker-red-gtk/master/Scripts/reds)
where "reds" stands for **red** from **s**ource) to compile project with **reds** files:

```{bash}
reds -t linux Github/red/environment/console/CLI/console-view.red
```

To test it

```{bash}
docker-red repl
## inside repl
view [button "hello"] 
```

Notice that `reds` (or `red-compile`) can be used instead the usual `red` binary in development mode since `--root` (which defaults to `~/Github/red`) can be specified to compile the red file form thus root folder.

## How `docker-red` works (alternative settings step by step)

This section is mainly provided to describe how the `docker-red` command works.

### setup service

This setup allows any x-application provided by docker containers to launch 

```{bash}
open -a Xquartz
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
```

If you want to stop socat: 

```{bash}
pkill socat
```

### managing image (for macOS and linux user)

1. build image
```{bash}
docker build -t rcqls/red-gtk https://github.com/rcqls/docker-red-gtk.git#:/Distribs/Ubuntu
```
1. use image
```{bash}
## for macOS user (replace interface 'en0' below if necessary with the active one by checking `ifconfig`)
docker run --rm  -ti -v ~/:/home/user/work  -e DISPLAY=$(ipconfig getifaddr en0):0 rcqls/red-gtk

## NOT TESTED: for linux user (replace interface 'eno0' with the active one if necessary by checking `ifconfig`)
docker run --rm  -ti -v ~/:/home/user/work  -e DISPLAY=$(/sbin/ip -o -4 addr list eno0 | awk '{print $4}' | cut -d/ -f1):0 rcqls/red-gtk
```
1. test container
Inside the container,`console` is the compiled binary (when `console-gtk` is the downloaded binary) to test the `red` console with `Needs: 'View` option activated. You could then try:
```{bash}
console-gtk /home/user/red/red/tests/react-test.red
```
or 
```{bash}
console-gtk
```
or if `~/titi/toto.red` is a regular `red` file in the host systemfile
```{bash}
console-gtk titi/toto.red
```
1.  compile red file

	* host file
If `~/titi/toto.red` is a regular `red` file in the host systemfile, you can compile it:
```{bash}
## cd ~/work (if you change of working directory)
red-compile titi/toto.red
```
	* guest file

In the example above, the host systemfile  `~/titi/toto.red` is named in the container (guest systemfile)  `/home/user/work/titi/toto.red` and then be compiled to create `toto` binary
```{bash}
red-compile /home/user/work/titi/toto.red
```
One can also compile with a relative path
```{bash}
## to create the binary inside this folder
cd /home/user/red/red/tests
## compile the red file
red-compile react-view.red
## to execute the binary file
react-view
```
In fact, `red-compile` is just a bash script containing 
```{bash}
redfile="$1"
echo "Rebol[] do/args %/home/user/red/red/red.r \"-r %${redfile}\"" | rebol +q -s
```
This script can be  extended to provide some similar usage provided by the `red` binary provided in the `red` website.

## Some comments

### Note for linux user

`console-gtk` binary can be downloaded directly [here](https://toltex.u-ga.fr/users/RCqls/Red/console-gtk)

### For Windows user

#### docker

To test `red-gtk` with docker, you could try to adapt this using [x11docker](https://github.com/mviereck/x11docker) 

#### Windows Subsystem for Linux (WSL)

However, the best solution is maybe to consider [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

After installation, you have just to follow step by step the installation inside the `Dockerfile`.

#### Vagrant

It is also possible to adapt of this previous docker installation by using [Vagrant](https://www.vagrantup.com) (VagrantFile to automate installation) with Virtual machine (like Virtualbox).