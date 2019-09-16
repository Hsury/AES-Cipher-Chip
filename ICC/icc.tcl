set link_library "* /home/ichip/Desktop/ICC/db/SP013W_V1p0_low_temp.db /home/ichip/Desktop/ICC/db/SP013W_V1p0_max.db /home/ichip/Desktop/ICC/db/SP013W_V1p0_min.db /home/ichip/Desktop/ICC/db/SP013W_V1p0_typ.db /home/ichip/Desktop/ICC/db/fast_1v32c0.db /home/ichip/Desktop/ICC/db/fast_1v32cm40.db /home/ichip/Desktop/ICC/db/slow_1v08c125.db /home/ichip/Desktop/ICC/db/typical_1v2c25.db"
set target_library "/home/ichip/Desktop/ICC/db/fast_1v32c0.db /home/ichip/Desktop/ICC/db/fast_1v32cm40.db /home/ichip/Desktop/ICC/db/slow_1v08c125.db /home/ichip/Desktop/ICC/db/typical_1v2c25.db"

create_mw_lib  -technology /home/ichip/project/chip/ref/tech/smic13g_8lm.tf -mw_reference_library {/home/ichip/project/chip/ref/mw_lib/sc/smic13g /home/ichip/project/chip/ref/mw_lib/io/SP013W_V1p0_8MT} -bus_naming_style {[%d]}  /home/ichip/Desktop/ICC/mw_lib
open_mw_lib /home/ichip/Desktop/ICC/mw_lib/
read_verilog {/home/ichip/Desktop/ICC/rtl.v}
link
set_tlu_plus_files -max_tluplus /home/ichip/project/chip/ref/TLU+/smic013_8lm_cell_max.tluplus -min_tluplus /home/ichip/project/chip/ref/TLU+/smic013_8lm_cell_min.tluplus -tech2itf_map  /home/ichip/project/chip/ref/TLU+/smiclogic013_rcxt_cell.map
read_sdc  -version Latest "/home/ichip/Desktop/ICC/rtl.sdc"

create_cell {cornerll cornerlr cornerul cornerur} PCORNERW 

create_cell CORE_VDD_PAD PVDD1W
create_cell CORE_VDD_AUX_PAD PVDD1W
create_cell CORE_VSS_PAD PVSS1W

create_cell IO_VDD_PAD PVDD2W
create_cell IO_VSS_PAD PVSS2W

set_pad_physical_constraints -pad_name "cornerul" -side 1
set_pad_physical_constraints -pad_name "cornerur" -side 2
set_pad_physical_constraints -pad_name "cornerlr" -side 3
set_pad_physical_constraints -pad_name "cornerll" -side 4

set_pad_physical_constraints -pad_name "PHASE_0_PAD" -side 1 -order 1
set_pad_physical_constraints -pad_name "PHASE_1_PAD" -side 1 -order 2
set_pad_physical_constraints -pad_name "PHASE_2_PAD" -side 1 -order 3
set_pad_physical_constraints -pad_name "CORE_VDD_AUX_PAD" -side 1 -order 4
set_pad_physical_constraints -pad_name "IO_VDD_PAD" -side 1 -order 5
set_pad_physical_constraints -pad_name "IO_VSS_PAD" -side 1 -order 6
set_pad_physical_constraints -pad_name "CLK_PAD" -side 1 -order 7
set_pad_physical_constraints -pad_name "RST_PAD" -side 1 -order 8

set_pad_physical_constraints -pad_name "DATA_0_PAD" -side 2 -order 1
set_pad_physical_constraints -pad_name "DATA_1_PAD" -side 2 -order 2
set_pad_physical_constraints -pad_name "DATA_2_PAD" -side 2 -order 3
set_pad_physical_constraints -pad_name "DATA_3_PAD" -side 2 -order 4
set_pad_physical_constraints -pad_name "DATA_4_PAD" -side 2 -order 5
set_pad_physical_constraints -pad_name "DATA_5_PAD" -side 2 -order 6
set_pad_physical_constraints -pad_name "DATA_6_PAD" -side 2 -order 7
set_pad_physical_constraints -pad_name "DATA_7_PAD" -side 2 -order 8

set_pad_physical_constraints -pad_name "POS_0_PAD" -side 3 -order 1
set_pad_physical_constraints -pad_name "POS_1_PAD" -side 3 -order 2
set_pad_physical_constraints -pad_name "ENC_DEC_PAD" -side 3 -order 3
set_pad_physical_constraints -pad_name "KEY_LEN_PAD" -side 3 -order 4
set_pad_physical_constraints -pad_name "CORE_VDD_PAD" -side 3 -order 5
set_pad_physical_constraints -pad_name "CORE_VSS_PAD" -side 3 -order 6
set_pad_physical_constraints -pad_name "SCLK_PAD" -side 3 -order 7

set_pad_physical_constraints -pad_name "SEG_0_PAD" -side 4 -order 1
set_pad_physical_constraints -pad_name "SEG_1_PAD" -side 4 -order 2
set_pad_physical_constraints -pad_name "SEG_2_PAD" -side 4 -order 3
set_pad_physical_constraints -pad_name "SEG_3_PAD" -side 4 -order 4
set_pad_physical_constraints -pad_name "SEG_4_PAD" -side 4 -order 5
set_pad_physical_constraints -pad_name "SEG_5_PAD" -side 4 -order 6
set_pad_physical_constraints -pad_name "SEG_6_PAD" -side 4 -order 7
set_pad_physical_constraints -pad_name "FLAG_PAD" -side 4 -order 8

#create_floorplan -core_utilization 0.65 -left_io2core 20 -bottom_io2core 20 -right_io2core 20 -top_io2core 20
create_floorplan -core_utilization 0.67 -left_io2core 25 -bottom_io2core 25 -right_io2core 25 -top_io2core 25

#insert_pad_filler -cell "PFILL50W PFILL20W PFILL10W PFILL5W PFILL2W PFILL1W PFILL01W PFILL001W" -overlap "PFILL001W"
insert_pad_filler -cell "PFILL50W PFILL20W PFILL10W PFILL5W PFILL2W PFILL01W PFILL001W" -overlap "PFILL001W"

derive_pg_connection -power_net VDD -ground_net VSS -create_ports top
derive_pg_connection -power_net VDD  -power_pin VDD  -ground_net VSS  -ground_pin VSS

create_pad_rings

set_fp_rail_constraints -add_layer  -layer METAL5 -direction horizontal -max_strap 14 -min_strap 2 -min_width 2 -max_width 4 -spacing 0.6
set_fp_rail_constraints -add_layer  -layer METAL6 -direction vertical -max_strap 14 -min_strap 2 -min_width 2 -max_width 4 -spacing 0.6
set_fp_rail_constraints  -set_ring -horizontal_ring_layer { METAL3 } -vertical_ring_layer { METAL4 } -ring_max_width 10 -ring_min_width 10 -extend_strap core_ring

synthesize_fp_rail  -nets {VDD VSS} -voltage_supply 1.2 -synthesize_power_plan -power_budget 350 -pad_masters {PVDD1W PVSS1W}

commit_fp_rail


#set_preroute_drc_strategy -min_layer METAL3 -max_layer METAL5
preroute_instances

#preroute_instances  -ignore_macros -ignore_cover_cells -skip_right_side

set_preroute_drc_strategy -min_layer METAL1 -max_layer METAL5
preroute_standard_cells -fill_empty_rows -remove_floating_pieces

analyze_fp_rail  -nets {VDD VSS} -voltage_supply 1.2 -power_budget 250 -pad_masters {PVDD1W PVSS1W}

create_fp_placement -timing_driven -no_hierarchy_gravity

set_pnet_options -complete "METAL5 METAL6"
legalize_fp_placement

report_congestion -grc_based -by_layer -routing_stage global 

route_zrt_global

verify_pg_nets

# report_timing

check_physical_design -stage pre_place_opt
check_physical_constraints

set_separate_process_options -placement false

place_opt -area_recovery -power -congestion -effort high 
psynopt -area_recovery -power

set_clock_tree_options -max_tran  0.4 -clock_trees [all_clocks]
set_clock_tree_options -max_fanout 32 -clock_trees [all_clocks]
set_clock_tree_options -target_skew 0.02

set_operating_conditions -analysis_type bc_wc \
	-max_library slow_1v08c125 -max slow_1v08c125 \
	-min_library fast_1v32cm40 -min fast_1v32cm40

set_ignored_layers -max_routing_layer METAL5
set_ignored_layers -min_routing_layer METAL1

clock_opt
# clock_opt -fix_hold_all_clocks

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect

route_opt -effort "high"
# route_opt -effort "high"

derive_pg_connection -power_net VDD  -power_pin VDD  -ground_net VSS  -ground_pin VSS

verify_drc
verify_lvs

###############################################
# PAUSE HERE (OPTIONAL)
###############################################

# route_zrt_eco -open_net_driven true

report_constraint -all

save_mw_cel -as route_opt_final

close_mw_cel
close_mw_lib

##########Chip Finishing##########

# in new mw_lib_shell

set DATA_DIR results/v0
sh mkdir -p  $DATA_DIR
set from_mw_cel route_opt_final
set from_mw_lib mw_lib

sh rm -rf  $DATA_DIR/mw_lib 
#create_mw_lib $DATA_DIR/mw_lib -open -technology /home/ichip/project/chip/ref/tech/smic13g_8lm.tf \
#	-mw_reference_library {/home/ichip/project/chip/ref/mw_lib/sc/smic13g /home/ichip/project/chip/ref/mw_lib/io/SP013W_V1p0_8MT}
create_mw_lib -open -technology /home/ichip/project/chip/ref/tech/smic13g_8lm.tf -mw_reference_library "/home/ichip/project/chip/ref/mw_lib/sc/smic13g /home/ichip/project/chip/ref/mw_lib/io/SP013W_V1p0_8MT" $DATA_DIR/mw_lib

copy_mw_cel -from_lib $from_mw_lib -to_lib $DATA_DIR/mw_lib -from $from_mw_cel -to aes

list_mw_cels
set_tlu_plus_files -max_tluplus /home/ichip/project/chip/ref/TLU+/smic013_8lm_cell_max.tluplus -min_tluplus /home/ichip/project/chip/ref/TLU+/smic013_8lm_cell_min.tluplus -tech2itf_map  /home/ichip/project/chip/ref/TLU+/smiclogic013_rcxt_cell.map
open_mw_cel aes 

set RESULTS_DIR $DATA_DIR

#Outputs Script

set enable_page_mode false
change_names -rules verilog -hierarchy
save_mw_cel

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect

write_verilog -no_physical_only_cells -supply_statement none $RESULTS_DIR/des.output.pt.v

write_def -output  $RESULTS_DIR/des.output.def

#insert filler

remove_stdcell_filler -stdcell

set fillers "FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1"

insert_stdcell_filler -respect_keepout -connect_to_power VDD -connect_to_ground VSS -cell_with_metal $fillers 

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect

#for LVS use

save_mw_cel -as bak 
remove_cell *FILL* 
remove_cell *filler*
remove_cell *corner*

##########################################################
################# don't touch it !!!!!! ##################
##########################################################
write_verilog -diode_ports -pg /home/ichip/project/chip/icc/des.output.pg.lvs.filler.v 
########################################################## 
close_mw_cel
copy_mw_cel -from bak -to aes
open_mw_cel aes
remove_mw_cel bak

slot_wire -nets {VDD VSS} -cutwidth {METAL5 10} -cutlength {METAL5 20} \
	-width {METAL5 3} -length {METAL5 18}


##############################################################################
# PAUSE HERE
# DELETE VIAARRAY MANUALLY
##############################################################################


foreach_in_collection port [get_ports *] {
	set name [get_attri $port full_name]
	set center [get_attri $port center]
	set layer [get_attri $port layer]
	create_text -origin $center -layer $layer -height 1 $name
}

set_write_stream_options \
	-child_depth 255 \
	-map_layer /home/ichip/project/chip/ref/mw_lib/sc/gds2OutLayer.map \
      	-output_filling fill \
       	-output_outdated_fill \
       	-keep_data_type \
	-max_name_length 255 \
	-output_net_name_as_property 1 \
	-output_instance_name_as_property 1 \
	-output_pin {geometry text} \
	-output_polygon_pin \
	-output_design_intent 


write_stream -cells aes -format gds /home/ichip/project/chip/icc/uestc.gds

