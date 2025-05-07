transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_buffer_1 {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_buffer_1/ascii_buffer_1.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_buffer_2 {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_buffer_2/ascii_buffer_2.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_master {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_master/ascii_master.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_rom {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_rom/Char_ROM.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/vga_driver.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/vga_controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/double_buffer.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/clock_divider.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/vga_controller/ascii_master_controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/Processor.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/memory {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/memory/system_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/debug.v}
vlog -vlog01compat -work work +incdir+C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU {C:/Users/littekge/Desktop/ECE_289/ECE_289_CPU/ALU.v}

