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

add_cmd "list (ls)" "list containers" "$runtime container ls"
add_cmd "list (ls)" "list all containers" "$runtime container ls -a"
add_cmd "list (ls)" "list images" "$runtime image ls"
add_cmd "list (ls)" "list volumes" "$runtime volume ls"

add_cmd "delete (rm)" "remove container" "$runtime container rm {#}"
add_cmd "delete (rm)" "remove image" "$runtime image rm {#}"
add_cmd "delete (rm)" "remove all unused images" "$runtime image prune -a"
add_cmd "delete (rm)" "remove all dangling images" "$runtime image prune"
add_cmd "delete (rm)" "remove all unused volumes" "$runtime volume prune"
