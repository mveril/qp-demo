#!/bin/bash

# Add a timeout to a existing container
DockerTimeout() {
 docker events -f event=start -f type=container -f container=$1 | head -n 0
 timeout $2 docker wait $1>/dev/null
 if [ $? -eq 124 ] ; then
   docker kill $1> /dev/null
   return 1
 else
   return 0
 fi
}

# Create an interactive docker container for an image and echo it's ID (use docker start command to start the container)
DockerCreate() {
  docker create -h qp-demo -l demo --network=demo-net --rm -it $1
}
DockerGetNextID() {
  docker ps -aq -f ancestor="$1" -f "label=demo" -f status=created --no-trunc | tail -n 1
}

# Count the number of container for a specific image
DockerCountCont() {
  docker ps -f ancestor="$1" -f "label=demo" -q | wc -l
}
# Selected image
image=qp2
# Time limit for the container in the format of the timeout command
timeout=10m
# Number of container that running at the same time
contlimit=4
allocated=false
printwaitmessage=true
allowRun=true

cont=$(DockerCreate $image)
trap "docker rm $cont" EXIT INT TERM
echo "Your ID is : $cont"
# Until a container is started
until $allocated
do
  # If the limit is reached
  if [ $(DockerCountCont $image) -ge $contlimit ] ; then
    allowRun=false
    # Get the next container in the queue
    nextcont=$(DockerGetNextID $image)
    # print the message only one time
    if $printwaitmessage ; then
      echo Maximum number of sessions reached. Please wait for allocation...
    fi
    printwaitmessage=false
    # Wait the die of a container
    docker events -f event=die -f event=destroy -f type=container -f image=$image -f "label=demo" | head -n 0
    if [ "$nextcont" == "$cont" ]; then
      allowRun=true
    fi
    # Sleep because is's needed by docker for a good count of containers
  else
    if $allowRun ; then
      allocated=true
      # If there it's permited by the container number limit allocate a container and get it's ID
      echo -e "Session allocated."
      # Count the number of container available
      aval=$(expr $(expr $contlimit - $(DockerCountCont $image) - 1))
      [[ "$aval" -lt 0 ]] && aval=0
      # Show it to the user
      echo "There are $aval sessions left available"
      if [ $# -eq 0 ]  || [ "$1" != "unlimited" ] ; then
        # Apply a timout only if the argument ulimited is not given to the script
        DockerTimeout $cont $timeout &
      fi
      # start the container in interactive mode and attach it to the terminal
      trap "docker kill $cont" EXIT INT TERM
      docker start -a -i $cont
      trap - EXIT INT TERM 
    fi
  fi
done
