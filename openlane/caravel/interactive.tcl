# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

package require openlane
set script_dir [file dirname [file normalize [info script]]]
set save_path $script_dir/../..

# FOR LVS AND CREATING PORT LABELS
prep -design $script_dir -tag caravel_lvs -overwrite

set ::env(SYNTH_DEFINES) "USE_POWER_PINS"
verilog_elaborate
init_floorplan
file copy -force $::env(CURRENT_DEF) $::env(TMP_DIR)/lvs.def
file copy -force $::env(CURRENT_NETLIST) $::env(TMP_DIR)/lvs.v

# ACTUAL CHIP INTEGRATION
prep -design $script_dir -tag caravel -overwrite

file copy $script_dir/runs/caravel_lvs/tmp/merged_unpadded.lef $::env(TMP_DIR)/lvs.lef
file copy $script_dir/runs/caravel_lvs/tmp/lvs.def $::env(TMP_DIR)/lvs.def
file copy $script_dir/runs/caravel_lvs/tmp/lvs.v $::env(TMP_DIR)/lvs.v

set ::env(SYNTH_DEFINES) "TOP_ROUTING"
verilog_elaborate
#logic_equiv_check -lhs $top_rtl -rhs $::env(yosys_result_file_tag).v

init_floorplan

add_macro_placement padframe 0 0 N
add_macro_placement storage 260.160 265.780 N
add_macro_placement soc 952.170 268.010 N
# add_macro_placement soc 1052.170 267.900 N
add_macro_placement mprj 326.540 1393.590 N
add_macro_placement mgmt_buffers 960.900 1200.180 N
# add_macro_placement mgmt_buffers 1060.850 1234.090 N
add_macro_placement rstb_level 708.550 235.440 S
add_macro_placement user_id_value 3283.120 404.630 N
add_macro_placement por 3270.730 522.721 MX

# west
set west_x 38.155
add_macro_placement "gpio_control_bidir_2\\\[1\\\]" $west_x 1013.000 R0
add_macro_placement "gpio_control_bidir_2\\\[0\\\]" $west_x 1229.000 R0
add_macro_placement "gpio_control_in_2\\\[16\\\]" $west_x 1445.000 R0
add_macro_placement "gpio_control_in_2\\\[15\\\]" $west_x 1661.000 R0
add_macro_placement "gpio_control_in_2\\\[14\\\]" $west_x 1877.000 R0
add_macro_placement "gpio_control_in_2\\\[13\\\]" $west_x 2093.000 R0
add_macro_placement "gpio_control_in_2\\\[12\\\]" $west_x 2731.000 R0

add_macro_placement "gpio_control_in_2\\\[11\\\]" $west_x 2947.000 R0
add_macro_placement "gpio_control_in_2\\\[10\\\]" $west_x 3163.000 R0
add_macro_placement "gpio_control_in_2\\\[9\\\]" $west_x 3379.000 R0
add_macro_placement "gpio_control_in_2\\\[8\\\]" $west_x 3595.000 R0
add_macro_placement "gpio_control_in_2\\\[7\\\]" $west_x 3811.000 R0
add_macro_placement "gpio_control_in_2\\\[6\\\]" $west_x 4027.000 R0
add_macro_placement "gpio_control_in_2\\\[5\\\]" $west_x 4656.120 R0

# north
set north_y 4980.385
add_macro_placement "gpio_control_in_2\\\[4\\\]" 486.000 $north_y R270
add_macro_placement "gpio_control_in_2\\\[3\\\]" 743.000 $north_y R270
add_macro_placement "gpio_control_in_2\\\[2\\\]" 1000.000 $north_y R270
add_macro_placement "gpio_control_in_2\\\[1\\\]" 1257.000 $north_y R270
add_macro_placement "gpio_control_in_2\\\[0\\\]" 1515.000 $north_y R270
add_macro_placement "gpio_control_in_1\\\[16\\\]" 1767.000 $north_y R270
add_macro_placement "gpio_control_in_1\\\[15\\\]" 2104.000 $north_y R270
add_macro_placement "gpio_control_in_1\\\[14\\\]" 2489.000 $north_y R270
add_macro_placement "gpio_control_in_1\\\[13\\\]" 2746.000 $north_y R270

# east
set east_x 3381.015
add_macro_placement "gpio_control_bidir_1\\\[0\\\]" $east_x 605.000 MY
add_macro_placement "gpio_control_bidir_1\\\[1\\\]" $east_x 831.000 MY
add_macro_placement "gpio_control_in_1\\\[0\\\]" $east_x 1056.000 MY
add_macro_placement "gpio_control_in_1\\\[1\\\]" $east_x 1282.000 MY
add_macro_placement "gpio_control_in_1\\\[2\\\]" $east_x 1507.000 MY
add_macro_placement "gpio_control_in_1\\\[3\\\]" $east_x 1732.000 MY
add_macro_placement "gpio_control_in_1\\\[4\\\]" $east_x 1958.000 MY
add_macro_placement "gpio_control_in_1\\\[5\\\]" $east_x 2399.000 MY
add_macro_placement "gpio_control_in_1\\\[6\\\]" $east_x 2619.000 MY
add_macro_placement "gpio_control_in_1\\\[7\\\]" $east_x 2844.000 MY
add_macro_placement "gpio_control_in_1\\\[8\\\]" $east_x 3070.000 MY
add_macro_placement "gpio_control_in_1\\\[9\\\]" $east_x 3295.000 MY
add_macro_placement "gpio_control_in_1\\\[10\\\]" $east_x 3521.000 MY
add_macro_placement "gpio_control_in_1\\\[11\\\]" $east_x 3746.000 MY
add_macro_placement "gpio_control_in_1\\\[12\\\]" $east_x 4638.000 MY

manual_macro_placement f

# modify to a different file
remove_pins -input $::env(CURRENT_DEF)
remove_empty_nets -input $::env(CURRENT_DEF)

# add_macro_obs \
# 	-defFile $::env(CURRENT_DEF) \
# 	-lefFile $::env(MERGED_LEF_UNPADDED) \
# 	-obstruction vddio_obs \
# 	-placementX 103.400 \
# 	-placementY 607.150 \
# 	-sizeWidth 94.500 \
# 	-sizeHeight 30 \
# 	-fixed 1 \
# 	-layerNames "met2 met4"

# add_macro_obs \
# 	-defFile $::env(CURRENT_DEF) \
# 	-lefFile $::env(MERGED_LEF_UNPADDED) \
# 	-obstruction vddio_pad_obs \
# 	-placementX 33.375 \
# 	-placementY 557.100 \
# 	-sizeWidth 62.615 \
# 	-sizeHeight 62.700 \
# 	-fixed 1 \
# 	-layerNames "li1 met1 met2 met3 met4 met5"

li1_hack_start
global_routing
detailed_routing
li1_hack_end

label_macro_pins\
	-lef $::env(TMP_DIR)/lvs.lef\
	-netlist_def $::env(TMP_DIR)/lvs.def
	# -extra_args {-v\
	# --map padframe vddio vddio INOUT\
	# --map padframe vssio vssio INOUT\
	# --map padframe vssa vssa INOUT\
	# --map padframe vccd vccd INOUT\
	# --map padframe vssd vssd INOUT}

run_magic

run_magic_spice_export

save_views       -lef_path $::env(magic_result_file_tag).lef \
                 -def_path $::env(tritonRoute_result_file_tag).def \
                 -gds_path $::env(magic_result_file_tag).gds \
                 -mag_path $::env(magic_result_file_tag).mag \
				 -verilog_path $::env(TMP_DIR)/lvs.v \
				 -spice_path $::env(magic_result_file_tag).spice \
                 -save_path $save_path \
                 -tag $::env(RUN_TAG)

run_lvs $::env(magic_result_file_tag).spice $::env(TMP_DIR)/lvs.v
