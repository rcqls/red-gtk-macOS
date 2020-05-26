## TODO: mode build start stop without run --rm
## more adequate for running script without starting each time the container

function docker-red {
	compile_args=""		# --args for red-compile
	compile_root=""		# --root for red-compile
	distrib="ubuntu-i386"	# linux distrib of container
	container=""		# container name (default is rcqls/red-gtk-$distrib)
	ifs=""				# to specifiy specific network interface(s)
	debug="false"		# to echo output
	build_folder=""		# build folder containing Dockerfile
	build_opts=""		# build options
	# cmd declaration
	cmd=""	
	
	# get options 
	while true 
	do 
		cmd=$1
		case $cmd in
			-h|--help)
				docker-red-help
				return
			;;
			--echo)
				debug="true"
				shift
				;;
			--root) # --root for red-compile 
				shift
				compile_root="$1"
				shift
			;;
			-D|--D|--dist|--distr|--distrib) # distrib container
				shift
				distrib="$1"
				case $distrib in
					# aliases
					ub)
						distrib="ubuntu"
						;;
					disco)
						distrib="ubuntu-disco"
						;;
					u86|ub86)
						distrib="ubuntu-i386"
						;;
					disco86)
						distrib="ubuntu-disco-i386"
						;;
					cosmic86)
						distrib="ubuntu-cosmic-i386"
						;;
					deb86|efl86)
						distrib="debian-sid-efl-i386"
						;;
					ar|archlinux)
						distrib="arch"
						;;
					m8|ma86)
						distrib="manjaro-i386"
						;;
					ce|cent)
						distrib="centos"
						;;
					c86|ce86|cent86)
						distrib="centos-i386"
						;;
					al|alp|al86|alp86) #already i386
						distrib="alpine"
						;;
				esac
				shift
				;;
			--build-dir|--build-folder)
				shift
				build_folder=$1
				if [ "$build_folder" = "local" ]; then build_folder="$HOME/Github/docker-red-gtk/Distribs"; fi
				shift
				;;
			--build-opt|--build-opts)
				shift
				build_opts=$1
				if [ "$build_opts" = "force" ]; then build_opts="--no-cache"; fi
				shift
				;;
			--cont|--container) # or directly the name of the container
				shift
				container=$1
				shift
				;;
			--ifs) # to choose the address to connect DISPLAY
				shift
				ifs="$1"
				shift
				;;
			-*) # argument for red-compile
				compile_args="$compile_args $1"
				case $2 in
					-*) # Nothing to do
					;;
					*)
						if [ "$2" != "" ] && [ "$2" != "compile" ];then
							shift 
							compile_args="$compile_args $1"
						fi
					;;
				esac
				shift
			;;
			*) # cmd is then a command
				if [ "$cmd" = "" ];then cmd="bash"; fi
				break
			;;
		esac
	done

	if [ "$debug" = "true" ]; then 
		echo "<cmd=$cmd|root=$compile_root|args=$compile_args|build_folder=$build_folder>"
	fi

	if [ "$container" = "" ]; then container="rcqls/red-gtk-${distrib}"; fi

	case $cmd in
	bash|repl|exec|run|compile|ls)
		ifaddr=""

		if [ "$ifs" = "" ]; then
			ifs="docker0 eno0 eno1 eno2 eth0 eth1 eth2" # docker0 is for linux
		fi

		for if in $ifs;do
			case $OSTYPE in
				darwin*)
					ifaddr="host.docker.internal" # macOS ONLY! # OLD $(ipconfig getifaddr ${if})
				;;
				linux*)
					ifaddr=$(/sbin/ip -o -4 addr list ${if} > /dev/null 2>&1 | awk '{print $4}' | cut -d/ -f1)
				;;
			esac

			if [ "$ifaddr" != "" ];then 
				break
			fi
		done

		if [ "$ifaddr" = "" ];then
			echo "Error in docker-red: no IP address!"
			exit
		fi

		# if compile_args non-empty bash becomes compile
		if [ "$compile_root$compile_args" != "" ];then cmd="compile"; fi

		echo "docker-red $cmd inside container $container connected to DISPLAY ${ifaddr}:0"
		docker_run="docker run --rm  -ti -v ~/:/home/user/macHome  -v /tmp:/tmp -e DISPLAY=${ifaddr}:0 ${container}"
		if [ "$debug" = "true" ];then echo "run $cmd command: ${docker_run}"; fi
		
		redbin_host="${HOME}/RedGTK/bin"
		redbin_guest="/home/user/macHome/RedGTK/bin"

		docker_repl="console-gtk"
		if [ -f "$redbin_host/console-view" ]; then docker_repl="$redbin_guest/console-view"; fi

		case $cmd in 
			bash) 
				eval $docker_run
				;;
			repl)
				eval "$docker_run $docker_repl"
				;;
			ls)
				eval "$docker_run ls $redbin_guest"
				;;
			exec|run)
				shift
				filename=$1
				if [ -f "${redbin_host}/$filename" ];then
					run="$docker_run  ${redbin_guest}/$*"
					if [ "$debug" = "true" ];then echo "run1: $run"; fi 
					eval "$run"
				else 
					if [ -f "${HOME}/$filename" ];then
						if [ "${filename##*.}" = "red" ];then
							run="$docker_run $docker_repl $*"
							if [ "$debug" = "true" ];then echo "run2: $run"; fi 
							eval "$run"
						else
							run="$docker_run  $*"
							if [ "$debug" = "true" ];then echo "run3: $run"; fi 
							eval "$run"
						fi
					else 
						echo "Binary file ${HOME}/$filename does not exist..."
					fi
				fi
				;;
			compile)
				shift
				if [ "$compile_args" = "" ]; then compile_args="-r"; fi
				if [ "$compile_root" = "" ]; then compile_root="/home/user/red/red"; fi 
				eval "$docker_run /bin/bash -e /home/user/red/red/red-compile --root $compile_root --args \"$compile_args\" --mv $*" 
				;;
		esac
		;;
	
	build)

		if [ "$build_folder" = "" ]; then build_folder="https://github.com/rcqls/red-gtk-macOS.git#:Docker/Distribs"; fi

		case $distrib in
		ubuntu)
			build_folder="${build_folder}/Ubuntu"
			;;
		ubuntu-disco)
			build_folder="${build_folder}/Ubuntu-disco"
			distrib="ubuntu-disco"
			;;
		ubuntu-i386)
			build_folder="${build_folder}/Ubuntu-i386"
			distrib="ubuntu-i386"
			;;
		ubuntu-disco-i386)
			build_folder="${build_folder}/Ubuntu-disco-i386"
			distrib="ubuntu-disco-i386"
			;;
		ubuntu-cosmic-i386)
			build_folder="${build_folder}/Ubuntu-cosmic-i386"
			distrib="ubuntu-cosmic-i386"
			;;
		debian-sid-efl-i386)
			build_folder="${build_folder}/Debian-sid-efl-i386"
			distrib="debian-sid-efl-i386"
			;;
		arch)
			build_folder="${build_folder}/Archlinux"
			distrib="arch"
			;;
		manjaro-i386)
			build_folder="${build_folder}/Manjaro-i386"
			distrib="manjaro-i386"
			;;
		centos)
			build_folder="${build_folder}/Centos"
			distrib="centos"
			;;
		centos-i386)
			build_folder="${build_folder}/Centos-i386"
			distrib="centos-i386"
			;;
		alpine)
			build_folder="${build_folder}/Alpine"
			distrib="alpine"
			;;
		esac
		
		echo "Docker red: building image $container from $build_folder..."

		docker build -t $container $build_opts $build_folder
		;;
	service|services)
		shift
		cmd=$1
		case $cmd in
			start)
				case $OSTYPE in
				darwin*)
					echo "Docker-red: starting socat service"
					open -a Xquartz
					socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" > /dev/null 2>&1 &
					;;
				esac
				mkdir -p $HOME/RedGTK/bin
				if ! [ -d $HOME/RedGTK/red ]; then
					curdir=$pwd
					cd $HOME/RedGTK
					git clone -b GTK https://github.com/red/red.git 
					cd $curdir
				fi
				;;
			stop)
				case $OSTYPE in
				darwin*)
					echo "Docker-red: trying to stop socat service"
					pkill socat
					;;
				esac
				;;
		esac
		;;
	esac

}

docker-red-help() {
	cat <<- EOF
	usage: docker-red [--root <>] [--dist ubuntu|arch|centos] [-c] [-r] [-u] [exec|run|repl|compile]
	EOF
}