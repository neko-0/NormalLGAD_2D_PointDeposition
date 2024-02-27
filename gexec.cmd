# project name
name NormalLGAD_new_2D_Xray
# execution graph
job 7208   -post { extract_vars "$wdir" n7208_dvs.out 7208; waiting "$wdir" 7208 dvs }  -o n7208_dvs "sde -e -l n7208_dvs.cmd"
job 41950   -post { extract_vars "$wdir" n41950_des.out 41950; waiting "$wdir" 41950 des }  -o n41950_des "sdevice pp41950_des.cmd"
job 41965   -post { extract_vars "$wdir" n41965_des.out 41965; waiting "$wdir" 41965 des }  -o n41965_des "sdevice pp41965_des.cmd"
job 41980   -post { extract_vars "$wdir" n41980_des.out 41980; waiting "$wdir" 41980 des }  -o n41980_des "sdevice pp41980_des.cmd"
job 41995   -post { extract_vars "$wdir" n41995_des.out 41995; waiting "$wdir" 41995 des }  -o n41995_des "sdevice pp41995_des.cmd"
job 42010   -post { extract_vars "$wdir" n42010_des.out 42010; waiting "$wdir" 42010 des }  -o n42010_des "sdevice pp42010_des.cmd"
job 42025   -post { extract_vars "$wdir" n42025_des.out 42025; waiting "$wdir" 42025 des }  -o n42025_des "sdevice pp42025_des.cmd"
job 41933   -post { extract_vars "$wdir" n41933_des.out 41933; waiting "$wdir" 41933 des }  -o n41933_des "sdevice pp41933_des.cmd"
job 41928   -post { extract_vars "$wdir" n41928_dvs.out 41928; waiting "$wdir" 41928 dvs }  -o n41928_dvs "sde -e -l n41928_dvs.cmd"
job 22   -post { extract_vars "$wdir" n22_dvs.out 22; waiting "$wdir" 22 dvs }  -o n22_dvs "sde -e -l n22_dvs.cmd"
check sde_dvs.cmd 1699741365
check sdevice_des.cmd 1699741365
check sdevice_alpha_des.cmd 1699741365
check sdevice_mip_des.cmd 1699741365
check svisual_vis.tcl 1699741366
check global_tooldb 1445040373
check gtree.dat 1699745869
# included files
