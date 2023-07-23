#!/usr/bin/nu

use mips-testlib.nu *

def generate-start [
    srcDir: string = '.'
    buildDir: string = 'build'
    --exclude (-e): list = []
] {
    let placeholder = '#define START_INST_TEST_PLACEHOLDER'
    let srcIn = (open $'($srcDir)/start.S.in' | split row $placeholder)

    let inst_test = (get-all-testcases $srcDir | filter {|e| not ($e.target in $exclude)} | generate-inst-asm)

    [$srcIn.0, $inst_test, $srcIn.1] | str join | save -f $'($buildDir)/start.S'
}

def install-source [
    srcDir: string = '.'
    buildDir: string = 'build'
    --exclude (-e): list = []
] {
    let buildSrcDir = $'($buildDir)/.src'
    if not ($buildSrcDir | path exists) {
        mkdir $buildSrcDir
    }

    # install top sources
    cp $'($srcDir)/*.S' $buildSrcDir

    # install target inst
    let testcases = (get-all-testcases $srcDir | filter {|e| not ($e.target in $exclude)})
    for target in ($testcases.target | uniq) {
        let dir = $'($buildSrcDir)/($target)'
        if not ($dir | path exists) {
            mkdir $dir
        }
        cp $'($srcDir)/($target)/test/*.S' $dir
    }

    # generate start.S
    generate-start $srcDir $buildSrcDir --exclude $exclude
}

def compile [
    srcDir: string = '.'
    buildDir: string = 'build'
] {
    let objDir = $'($buildDir)/.obj'
    if not ($objDir | path exists) {
        mkdir $objDir
    }

    def get-flags [...flag: string] {
        let CFLAGS = {
            general: [
                '-fverbose-asm'
                '-nostdinc'
                '-nostdlib'
                '-mips1'
                '-mno-abicalls'
                '-g'
                '-O'
            ]
            header: [
                '-D_KERNEL'
            ]
            linkfmt: [
                '-Umips'
                '-U_MAIN'
                '-D_LOADER'
                '-DMEMSTART=0x80000000'
                '-DMEMSIZE=0x04000'
            ]
        }

        $flag | each {|$e| $CFLAGS | get $e | str join ' ' } | str join ' '
    }

    def compile-object [options: string] {
        let argv = ($options | split row (char newline) | filter {|e| not ($e | is-empty) } | str trim | str join ' ')
        nu -c $'mipsel-linux-gcc ($argv)'
    }

    # compile testcases
    let testcases = (get-all-testcases $srcDir)
    $testcases | par-each {|obj|
        let source = $'($buildDir)/.src/($obj.target)/($obj.testcase).S'
        if ($source | path exists) {
            compile-object $'
                -c ($source)
                -o ($objDir)/($obj.testcase).obj
                -I($srcDir)/($obj.target) -I($srcDir)/include
                (get-flags general header)
            '
        }
    }

    # compile start.S
    compile-object $'
        -c ($buildDir)/.src/start.S
        -o ($objDir)/start.obj
        -I($srcDir)/include
        (get-flags general header)
        -DTEST_NUM=($testcases | length)
    '

    # compile bin.lds.S
    compile-object $'
        -E -P ($buildDir)/.src/bin.lds.S
        -o ($objDir)/bin.lds
        -I($srcDir)/include
        (get-flags general header linkfmt)
    '

    # link main.elf
    cd $objDir
    mipsel-linux-ar -cr libtestcase.a n*.obj
    mipsel-linux-ld -g -T bin.lds -o main.elf start.obj -L. -ltestcase
}

def main [
    buildDir: string = 'build'
    --exclude (-e): string = ''
] {
    let srcDir = ($env.FILE_PWD | path dirname)

    if ($buildDir | path exists) {
        rm -rf $buildDir
    }
    mkdir $buildDir

    let BINSRC = $'($buildDir)/.obj/main.elf'

    install-source $srcDir $buildDir --exclude ($exclude | split row ',')

    compile $srcDir $buildDir

    mipsel-linux-objcopy -O binary -j .text $BINSRC $'($buildDir)/text.bin'
    mipsel-linux-objcopy -O binary -j .data $BINSRC $'($buildDir)/data.bin'
    mipsel-linux-objdump -z -d -j .text $BINSRC | save -f $'($buildDir)/text.bin.d'

    extract-coe $'($buildDir)/text.bin' $'($buildDir)/inst_ram'
    extract-coe $'($buildDir)/data.bin' $'($buildDir)/data_ram'
}
