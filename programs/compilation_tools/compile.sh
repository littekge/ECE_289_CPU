#! /usr/bin/bash
cd ../
/opt/riscv/bin/riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -T compilation_tools/memory_map.ld -o $1.rv32.elf $1.c
/opt/riscv/bin/riscv64-unknown-elf-objdump -D $1.rv32.elf
/opt/riscv/bin/riscv64-unknown-elf-objcopy -O ihex $1.rv32.elf ../memory/program.hex
rm $1.rv32.elf
