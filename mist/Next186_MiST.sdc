#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 13.1.4 Build 182 03/12/2014 SJ Full Version
#
#************************************************************

# Copyright (C) 1991-2014 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

set sdram_clk "${topmodule}dcm_system|altpll_component|auto_generated|pll1|clk[0]"
set mem_clk   "${topmodule}dcm_system|altpll_component|auto_generated|pll1|clk[1]"
set sys_clk   "${topmodule}dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[0]"

set snd_clk   "${topmodule}dcm_system|altpll_component|auto_generated|pll1|clk[2]"
set uart_clk  "${topmodule}dcm_misc|altpll_component|auto_generated|pll1|clk[1]"
set mpu_clk   "${topmodule}dcm_misc|altpll_component|auto_generated|pll1|clk[2]"

set cpu_clk   "${topmodule}dcm_system|altpll_component|auto_generated|pll1|clk[2]"
set dsp_clk   "${topmodule}dcm_system|altpll_component|auto_generated|pll1|clk[3]"

# Clock groups
set_clock_groups -asynchronous -group [get_clocks {spiclk}] -group [get_clocks ${topmodule}dcm_system|altpll_component|auto_generated|pll1|clk[*]]
set_clock_groups -asynchronous -group [get_clocks {spiclk}] -group [get_clocks ${topmodule}dcm_cpu_inst|altpll_component|auto_generated|pll1|clk[*]]
set_clock_groups -asynchronous -group [get_clocks $cpu_clk] -group [get_clocks $sys_clk]

set_multicycle_path -from [get_registers ${topmodule}sys_inst|CPUUnit|cpu|*] -setup -start 2
set_multicycle_path -from [get_registers ${topmodule}sys_inst|CPUUnit|cpu|*] -hold -start 1
set_multicycle_path -from [get_registers ${topmodule}sys_inst|CPUUnit|cpu|*] -to [get_registers ${topmodule}sys_inst|seg_mapper|*addr*] -setup -start 1
set_multicycle_path -from [get_registers ${topmodule}sys_inst|CPUUnit|cpu|*] -to [get_registers ${topmodule}sys_inst|seg_mapper|*addr*] -hold -start 0

set_multicycle_path -from [get_registers ${topmodule}fake286_r2] -setup -start 2
set_multicycle_path -from [get_registers ${topmodule}fake286_r2] -hold -start 1

# Some relaxed constrain to the VGA pins. The signals should arrive together, the delay is not really important.
set_output_delay -clock [get_clocks $sys_clk] -max 0 [get_ports ${VGA_OUT}]
set_output_delay -clock [get_clocks $sys_clk] -min -5 [get_ports ${VGA_OUT}]

# SDRAM delays
set_input_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -max 6.4 [get_ports ${RAM_IN}]
set_input_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -min 3.5 [get_ports ${RAM_IN}]

set_output_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -max 1.5 [get_ports ${RAM_OUT}]
set_output_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -min -0.8 [get_ports ${RAM_OUT}]

set_multicycle_path -from [get_clocks $sdram_clk] -to [get_clocks $mem_clk] -setup 2
# set_multicycle_path -from [get_clocks {dcm_system|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {dcm_system|altpll_component|auto_generated|pll1|clk[1]}] -setup -end 2

set_clock_groups -asynchronous -group [get_clocks $mpu_clk]  -group [get_clocks $cpu_clk]
set_clock_groups -asynchronous -group [get_clocks $uart_clk] -group [get_clocks $cpu_clk]
set_clock_groups -asynchronous -group [get_clocks $cpu_clk]  -group [get_clocks $mem_clk]
set_clock_groups -asynchronous -group [get_clocks $dsp_clk]  -group [get_clocks $mem_clk]

set_false_path -to [get_ports ${FALSE_OUT}]
set_false_path -from [get_ports ${FALSE_IN}]
