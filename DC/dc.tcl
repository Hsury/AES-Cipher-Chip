. /eda/synopsys/syn_vH-2013.03/libraries/syn /eda/synopsys/syn_vH-2013.03/minpower/syn /eda/synopsys/syn_vH-2013.03/dw/syn_ver /eda/synopsys/syn_vH-2013.03/dw/sim_ver /home/ichip/project/chip/ref/db
* /home/ichip/project/chip/ref/db/io/SP013W_V1p0_max.db /home/ichip/project/chip/ref/db/sc/slow_1v08c125.db
/home/ichip/project/chip/ref/db/io/SP013W_V1p0_max.db /home/ichip/project/chip/ref/db/sc/slow_1v08c125.db
/home/ichip/project/chip/ref/db/sc/smic13g.sdb

read_file -format verilog {/home/ichip/Desktop/DC_Final/aes.v /home/ichip/Desktop/DC_Final/aes_core.v /home/ichip/Desktop/DC_Final/aes_decipher_block.v /home/ichip/Desktop/DC_Final/aes_encipher_block.v /home/ichip/Desktop/DC_Final/aes_inv_sbox.v /home/ichip/Desktop/DC_Final/aes_key_mem.v /home/ichip/Desktop/DC_Final/aes_sbox.v /home/ichip/Desktop/DC_Final/display.v}
link
uniquify
set_dont_use slow_1v08c125/CLK*
set_operating_conditions -library slow_1v08c125 slow_1v08c125
set_wire_load_model -name ForQA -library slow_1v08c125
set_load 3.000000 [get_ports "KEY_LEN"]
set_load 3.000000 [get_ports "SEG_0"]
set_load 3.000000 [get_ports "SEG_1"]
set_load 3.000000 [get_ports "SEG_2"]
set_load 3.000000 [get_ports "SEG_3"]
set_load 3.000000 [get_ports "SEG_4"]
set_load 3.000000 [get_ports "SEG_5"]
set_load 3.000000 [get_ports "XOUT"]
set_load 3.000000 [get_ports "SEG_6"]
set_load 3.000000 [get_ports "DATA_0"]
set_load 3.000000 [get_ports "POS_0"]
set_load 3.000000 [get_ports "DATA_1"]
set_load 3.000000 [get_ports "POS_1"]
set_load 3.000000 [get_ports "ENC_DEC"]
set_load 3.000000 [get_ports "DATA_2"]
set_load 3.000000 [get_ports "DATA_3"]
set_load 3.000000 [get_ports "DATA_4"]
set_load 3.000000 [get_ports "PHASE_0"]
set_load 3.000000 [get_ports "DATA_5"]
set_load 3.000000 [get_ports "PHASE_1"]
set_load 3.000000 [get_ports "DATA_6"]
set_load 3.000000 [get_ports "PHASE_2"]
set_load 3.000000 [get_ports "DATA_7"]
set_load 3.000000 [get_ports "FLAG"]
set_input_transition 0.5 [all_inputs]
create_clock -name "XIN" -period 10 -waveform { 0.000 5.000  }  { XIN  }
set_dont_touch_network  [ find clock XIN ]
set_input_delay -clock XIN  -max -rise 2 "DATA_1 DATA_2 DATA_3 DATA_4 DATA_5 DATA_6 DATA_7 XIN RST CLK DATA_0"
set_input_delay -clock XIN -max -fall 2 "DATA_1 DATA_2 DATA_3 DATA_4 DATA_5 DATA_6 DATA_7 XIN RST CLK DATA_0"
set_input_delay -clock XIN -min -rise 0 "DATA_1 DATA_2 DATA_3 DATA_4 DATA_5 DATA_6 DATA_7 XIN RST CLK DATA_0"
set_input_delay -clock XIN  -min -fall 0 "DATA_1 DATA_2 DATA_3 DATA_4 DATA_5 DATA_6 DATA_7 XIN RST CLK DATA_0"
set_output_delay -clock XIN  -max -rise 2 "FLAG KEY_LEN SEG_0 SEG_1 SEG_2 SEG_3 SEG_4 SEG_5 XOUT SEG_6 DATA_0 POS_0 DATA_1 POS_1 ENC_DEC DATA_2 DATA_3 DATA_4 PHASE_0 DATA_5 PHASE_1 DATA_6 PHASE_2 DATA_7"
set_output_delay -clock XIN -max -fall 2 "FLAG KEY_LEN SEG_0 SEG_1 SEG_2 SEG_3 SEG_4 SEG_5 XOUT SEG_6 DATA_0 POS_0 DATA_1 POS_1 ENC_DEC DATA_2 DATA_3 DATA_4 PHASE_0 DATA_5 PHASE_1 DATA_6 PHASE_2 DATA_7"
set_output_delay -clock XIN -min -rise 0 "FLAG KEY_LEN SEG_0 SEG_1 SEG_2 SEG_3 SEG_4 SEG_5 XOUT SEG_6 DATA_0 POS_0 DATA_1 POS_1 ENC_DEC DATA_2 DATA_3 DATA_4 PHASE_0 DATA_5 PHASE_1 DATA_6 PHASE_2 DATA_7"
set_output_delay -clock XIN  -min -fall 0 "FLAG KEY_LEN SEG_0 SEG_1 SEG_2 SEG_3 SEG_4 SEG_5 XOUT SEG_6 DATA_0 POS_0 DATA_1 POS_1 ENC_DEC DATA_2 DATA_3 DATA_4 PHASE_0 DATA_5 PHASE_1 DATA_6 PHASE_2 DATA_7"
set_max_area 0
compile -exact_map
report_timing -nworst 10
write -hierarchy -format verilog -output /home/ichip/Desktop/DC_Final/rtl.v
write_sdf rtl.sdf
write_sdc rtl.sdc
