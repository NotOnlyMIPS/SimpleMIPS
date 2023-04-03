let root = ($env.FILE_PWD | path join)
let IPs = (ls $root | where type == dir | get name)
for ip in $IPs {
    ls $ip | where name !~ .xci | each { echo $in.name } | flatten
}
