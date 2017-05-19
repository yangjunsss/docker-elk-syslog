#!/bin/bash
set +e
set -o noglob
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)
underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}
debug() { printf "${white}%s${reset}\n" "$@"
}
info() { printf "${white}➜ %s${reset}\n" "$@"
}
success() { printf "${green}✔ %s${reset}\n" "$@"
}
error() { printf "${red}✖ %s${reset}\n" "$@"
}
warn() { printf "${tan}➜ %s${reset}\n" "$@"
}
bold() { printf "${bold}%s${reset}\n" "$@"
}
note() { printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}
set -e
set +o noglob

function changemode {
  mkdir -p ./elasticsearch/data
  chmod 777 ./elasticsearch/data
}


function stop_instances {
  if [ -n "$(docker-compose -f docker-compose.yml ps -q)" ]
  then
    note "stopping existing instance ..." 
    docker-compose -f docker-compose.yml down -v
  fi
}

function start_instances {
  if [ ! -e "docker-compose.yml" ]
  then
    error "Can't find 'docker-compose.yml'."
    exit 1
  fi
  echo "start 'docker-compose.yml' services."
  docker-compose -f docker-compose.yml up -d
}

function add_hosts {
  if grep -qxF "# Hosts for ELK" /etc/hosts
  then
    sudo sed -i "s/([0-9]+).([0-9]+).([0-9]+).([0-9]+) elasticsearch/127.0.0.1 elasticsearch/g" /etc/hosts
  else
    sudo echo -e "# Hosts for ELK\n127.0.0.1 elasticsearch" >> /etc/hosts
  fi
}

function check_docker {
	if ! docker --version &> /dev/null
	then
		error "Need to install docker(1.10.0+) first and run this script again."
		exit 1
	fi

	# docker has been installed and check its version
	if [[ $(docker --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
	then
		docker_version=${BASH_REMATCH[1]}
		docker_version_part1=${BASH_REMATCH[2]}
		docker_version_part2=${BASH_REMATCH[3]}

		# the version of docker does not meet the requirement
		if [ "$docker_version_part1" -lt 1 ] || ([ "$docker_version_part1" -eq 1 ] && [ "$docker_version_part2" -lt 10 ])
		then
			error "Need to upgrade docker package to 1.10.0+."
			exit 1
		else
			note "docker version: $docker_version"
		fi
	else
		error "Failed to parse docker version."
		exit 1
	fi
}

function check_dockercompose {
	if ! docker-compose --version &> /dev/null
	then
		error "Need to install docker-compose(1.7.1+) by yourself first and run this script again."
		exit 1
	fi

	# docker-compose has been installed, check its version
	if [[ $(docker-compose --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
	then
		docker_compose_version=${BASH_REMATCH[1]}
		docker_compose_version_part1=${BASH_REMATCH[2]}
		docker_compose_version_part2=${BASH_REMATCH[3]}

		# the version of docker-compose does not meet the requirement
		if [ "$docker_compose_version_part1" -lt 1 ] || ([ "$docker_compose_version_part1" -eq 1 ] && [ "$docker_compose_version_part2" -lt 6 ])
		then
			error "Need to upgrade docker-compose package to 1.7.1+."
      exit 1
		else
			note "docker-compose version: $docker_compose_version"
		fi
	else
		error "Failed to parse docker-compose version."
		exit 1
	fi
}


item=1
h2 "[Step $item]: Check environment ..."; let item+=1
check_docker
check_dockercompose

h2 "[Step $item]: Stop existing instance ..."; let item+=1
stop_instances

h2 "[Step $item]: Preparing environment ...";  let item+=1
changemode
add_hosts

h2 "[Step $item]: Start instance ..."; let item+=1
start_instances

success $"----ELK has been installed and started successfully.----"
exit 0