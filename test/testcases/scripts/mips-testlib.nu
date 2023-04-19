use binutils.nu bin2hex

# get all instruction testcases under the given root
export def get-all-testcases [root: string = '.'] {
    let targets = (ls $root | where type == dir | get name | filter {|dir| $'($dir)/test' | path exists})
    let testcases = ($targets | each {|dir| ls $'($dir)/test' | where name =~ .S | get name } | flatten)

    let sep = (char path_sep)
    let sep = if $sep == '\' { '\\' } else { $sep }
    let pattern = $'('(?<target>.+)')($sep)test($sep)('(?<testcase>n[0-9]+_.+)')\.[sS]$'
    $testcases | parse -r $pattern | each {|e| $e | update target {|e| $e.target | path basename}}
}

# generate start.S from start.S.in
export def generate-inst-asm [] {
    let body = ($in | get testcase | each {|e| $"\tjal ($e)_test\n\tnop" } | str join "\n")
    $"inst_test:\n($body)"
}

# extract vivado .coe file from binary source
export def extract-coe [
    binpath: string         # path to binary source
    output: string          # basename of coe output
    --radix (-r): int = 16  # memory initialization radix
] {
    [
        $'memory_initialization_radix = ($radix);'
        'memory_initialization_vector =',
        (try {
            ^cat $binpath | ^xxd -c 4 -g 32 -e | ^cut -d ' ' -f 2 | into string | str trim
        } catch {
            bin2hex (open $binpath | into binary) -l 4 -e
        })
    ] | str join "\n" | save -f $'($output).coe'
}
