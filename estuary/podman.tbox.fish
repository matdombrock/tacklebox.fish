set runtime ""
# Check if we have docker installed
if type -q docker
    set runtime docker
else if type -q podman
    set runtime podman
end
# If we have neither, exit
if test -z "$runtime"
    echo "No container runtime (docker or podman) found."
    return
end

# Container management
add_cmd container "list containers" "$runtime container ls"
add_cmd container "list all containers" "$runtime container ls -a"
add_cmd container "start container" "$runtime container start {#}"
add_cmd container "stop container" "$runtime container stop {#}"
add_cmd container "restart container" "$runtime container restart {#}"
add_cmd container "view container logs" "$runtime container logs {#}"
add_cmd container "execute command in running container" "$runtime container exec -it {#} {#}"
add_cmd container "remove container" "$runtime container rm {#}"
add_cmd container "remove all stopped containers" "$runtime container prune"
add_cmd container "commit container to image" "$runtime commit {#} {#}"
add_cmd container "copy files to/from container" "$runtime cp {#}:{#} {#}"

# Image management
add_cmd image "list images" "$runtime image ls"
add_cmd image "pull image from registry" "$runtime image pull {#}"
add_cmd image "build image from Dockerfile" "$runtime build -t {#} {#}"
add_cmd image "run a new container" "$runtime run -it --rm {#} {#}"
add_cmd image "remove image" "$runtime image rm {#}"
add_cmd image "remove all unused images" "$runtime image prune -a"
add_cmd image "remove all dangling images" "$runtime image prune"
add_cmd image "save image to tar" "$runtime save -o {#}.tar {#}"
add_cmd image "load image from tar" "$runtime load -i {#}.tar"
add_cmd image "tag image" "$runtime tag {#} {#}"

# Volume management
add_cmd volume "list volumes" "$runtime volume ls"
add_cmd volume "remove volume" "$runtime volume rm {#}"
add_cmd volume "remove all unused volumes" "$runtime volume prune"

# Network management
add_cmd network "list networks" "$runtime network ls"
add_cmd network "create network" "$runtime network create {#}"
add_cmd network "remove network" "$runtime network rm {#}"

# System operations
add_cmd system "remove all system data" "$runtime system prune -a"
add_cmd system "show container stats" "$runtime stats"
add_cmd system "show disk usage" "$runtime system df"
add_cmd system "show events" "$runtime events"
add_cmd system "show top containers" "$runtime top"

# Info/inspection
add_cmd info "inspect container or image" "$runtime inspect {#}"
add_cmd info "show system info" "$runtime info"
add_cmd info "show version info" "$runtime --version"
# End of podman.tbox.fish
