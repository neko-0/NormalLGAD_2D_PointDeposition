set node_num @node|sdevice_mip@
set volt @startBias@
set particle MIP
set prob_loc [expr @width@ / 2.0]
set cutline_type x
set variable_x X
set variable_y @variable@
# ElectricField-Y
# set center [expr @width@ * 0.5]
# set LET @LET@

# Setup list of TDR file.
set part_files_name {}
lappend part_files_name "n$node_num\_$particle\_LGAD_part1_voltage_$volt\V_0000_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0000_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0001_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0002_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0003_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0004_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0005_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0006_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0007_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0008_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0009_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part2_voltage_$volt\V_0010_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0000_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0001_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0002_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0003_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0004_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0005_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0006_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0007_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0008_des.tdr"
lappend part_files_name "n$node_num\_$particle\_LGAD_part3_voltage_$volt\V_0009_des.tdr"

set timestamp {
  "t=0.90ns"
  "t=1.00ns"
  "t=1.01ns"
  "t=1.02ns"
  "t=1.03ns"
  "t=1.04ns"
  "t=1.05ns"
  "t=1.06ns"
  "t=1.07ns"
  "t=1.08ns"
  "t=1.09ns"
  "t=1.10ns"
  "t=1.15ns"
  "t=1.20ns"
  "t=1.30ns"
  "t=1.40ns"
  "t=1.50ns"
  "t=2.00ns"
  "t=4.00ns"
  "t=6.00ns"
  "t=8.00ns"
  "t=10.0ns"
}

# loading the TDR files
puts "start loading files"
set part_files {}
foreach x $part_files_name {
  lappend part_files [load_file $x]
}

# Create new 2D plot from TDR files.
windows_style -style max
set plot_2d {}
foreach x $part_files {
  lappend plot_2d [create_plot -dataset $x]
  puts "loading "; puts $x;
}

puts "start creating cutline"

# Create 1D cutline on the 2D plot.
set cutlines {}
foreach t $timestamp x $plot_2d {
  lappend [create_cutline -plot $x -type $cutline_type -at $prob_loc -name $t]
  lappend cutlines $t
}

puts "finish creating cutline"

# create cutline curve
puts "start cutlinen curve"
set cutline_curve [create_plot -1d -name "cutline_curve"]
foreach t $timestamp x $cutlines {
  create_curve -name $t -plot $cutline_curve -dataset $x -axisX "Y" -axisY @variable@
}
puts "exporting cutlinen curve"
export_curves -plot $cutline_curve -filename "n@node@_@variable@.csv" -format csv -overwrite

# + 3 cutline
puts "next plot"
set cutlines {}
set prob [expr $prob_loc + 0.5]
foreach t $timestamp x $plot_2d {
  lappend [create_cutline -plot $x -type $cutline_type -at $prob -name $t]
  lappend cutlines $t
}
set cutline_curve [create_plot -1d -name "cutline_curve_r"]
foreach t $timestamp x $cutlines {
  create_curve -name $t -plot $cutline_curve -dataset $x -axisX "Y" -axisY @variable@
}
export_curves -plot $cutline_curve -filename "n@node@_@variable@_r.csv" -format csv -overwrite

# - 3 cutline
puts "next plot"
set cutlines {}
set prob [expr $prob_loc - 0.5]
foreach t $timestamp x $plot_2d {
  lappend [create_cutline -plot $x -type $cutline_type -at $prob -name $t]
  lappend cutlines $t
}
set cutline_curve [create_plot -1d -name "cutline_curve_l"]
foreach t $timestamp x $cutlines {
  create_curve -name $t -plot $cutline_curve -dataset $x -axisX "Y" -axisY @variable@
}
export_curves -plot $cutline_curve -filename "n@node@_@variable@_l.csv" -format csv -overwrite
