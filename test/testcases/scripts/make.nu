use mips-testlib.nu *

def generate-start [
    srcDir: string = '.'
    buildDir: string = 'build'
] {
    let placeholder = '#define START_INST_TEST_PLACEHOLDER'
    let srcIn = (open $'($srcDir)/start.S.in' | split row $placeholder)

    let inst_test = (get-all-testcases $srcDir | generate-inst-asm)

    [$srcIn.0, $inst_test, $srcIn.1] | str join | save -f $'($buildDir)/start.S'
}

def install-source [
    srcDir: string = '.'
    buildDir: string = 'build'
] {
    let buildSrcDir = $'($buildDir)/.src'
    if not ($buildSrcDir | path exists) {
        mkdir $buildSrcDir
    }

    # install top sources
    cp $'($srcDir)/*.S' $buildSrcDir

    # install target inst
    let testcases = (get-all-testcases $srcDir)
    for target in ($testcases.target | uniq) {
        let dir = $'($buildSrcDir)/($target)'
        if not ($dir | path exists) {
            mkdir $dir
        }
        cp $'($srcDir)/($target)/test/*.S' $dir
    }

    # generate start.S
    generate-start $srcDir $buildSrcDir
}

def compile [
    srcDir: string = '.'
    buildDir: string = 'build'
] {
    let objDir = $'($buildDir)/.obj'
    if not ($objDir | path exists) {
        mkdir $objDir
    }

    # = CFLAGS
    # == general
    #
    #   -fno-builtin
    #   -fno-pic
    #   -fverbose-asm
    #   -nostdinc
    #   -nostdlib
    #   -mips1
    #   -mno-abicalls
    #   -g
    #   -O2
    #
    # == asm.h
    #
    #   -D_KERNEL
    #
    # == bin.lds.S
    #
    #   -DMEMSTART=0x80000000
    #   -DMEMSIZE=0x04000

    # compile testcases
    let testcases = (get-all-testcases $srcDir)
    for obj in $testcases {
        let source = $'($buildDir)/.src/($obj.target)/($obj.testcase).S'
        mipsel-linux-gcc -c $source -o $'($objDir)/($obj.testcase).obj' $'-I($srcDir)/($obj.target)' $'-I($srcDir)/include' -fno-builtin -fno-pic -fverbose-asm -nostdinc -nostdlib -mips1 -mno-abicalls -g -O2 -D_KERNEL
    }

    # compile start.S
    mipsel-linux-gcc -c $'($buildDir)/.src/start.S' -o $'($objDir)/start.obj' $'-I($srcDir)/include' -fno-builtin -fno-pic -fverbose-asm -nostdinc -nostdlib -mips1 -mno-abicalls -g -O2 -D_KERNEL $'-DTEST_NUM=($testcases | length)'

    # compile bin.lds.S
    mipsel-linux-gcc -E -P $'($buildDir)/.src/bin.lds.S' -o $'($objDir)/bin.lds' -Umips -D_LOADER -U_MAIN $'-I($srcDir)/include' -fno-builtin -fno-pic -fverbose-asm -nostdinc -nostdlib -mips1 -mno-abicalls -g -O2 -D_KERNEL -DMEMSTART=0x80000000 -DMEMSIZE=0x04000

    # link main.elf
    cd $objDir
    mipsel-linux-ld -g *.obj -T bin.lds -o main.elf
}

def main [buildDir: string = 'build'] {
    let srcDir = ($env.FILE_PWD | path dirname)

    if not ($buildDir | path exists) {
        mkdir $buildDir
    }

    install-source $srcDir $buildDir

    compile $srcDir $buildDir

    let BINSRC = $'($buildDir)/.obj/main.elf'

    mipsel-linux-objcopy -O binary -j .text $BINSRC $'($buildDir)/text.bin'
    mipsel-linux-objcopy -O binary -j .data $BINSRC $'($buildDir)/data.bin'

    extract-coe $'($buildDir)/text.bin' $'($buildDir)/inst_ram'
    extract-coe $'($buildDir)/data.bin' $'($buildDir)/data_ram'
}
