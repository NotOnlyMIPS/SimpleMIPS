# Convert binary stream to formatted hex string.
export def bin2hex [
    raw: binary                 # binary stream for conversion
    --length (-l): int = 16     # number of bytes per group
    -e                          # little-endian dump
] {
    let pattern = $'('(')?<group>.{,($length * 2)}(')')'

    $raw | encode hex | str downcase | parse -r $pattern | get group | each {|group|
        if $e {
            $group | parse -r '(?<byte>.{2})' | get byte | reverse | str join
        } else {
            $group
        }
    } | str join "\n"
}
