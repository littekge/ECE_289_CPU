ENTRY(main)

MEMORY
{
    /*
        program counter (PC) is initally set to 0x1000
    */
    rom (rx): ORIGIN = 0x1000, LENGTH = 0x1000

    ram (rw): ORIGIN = 0x2000, LENGTH = 0x1000
}

SECTIONS
{
    .text : {
        /*
            entry point is expected to be the first function here
            --> we are assuming there's only a single function in the .text.boot segment and by convention that is "_start"
        */
        KEEP(*(.text.boot))

        /*
            all other code follows
        */
        . = ALIGN(4);
        *(.text)
        
    } > rom

    .rodata : { *(.rodata*) } > rom

    .bss : { *(.bss*) } > ram
}

