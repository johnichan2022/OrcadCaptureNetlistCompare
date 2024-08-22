# Orcad Capture Netlist Compare
Simple comparison between pstxnet files created by capture for identifying the modifications.


Run netlist_diff_vanced_capture.bat on a perl installed Windows PC.Strawberry Perl (64-bit) 5.32.1.1-64bit is tested.
The input files pstxnet.dat & pstxnet2.dat are called in bat file. The result is displayed in diff_report. The netlist1_out & netlist2_out are created in *.tel file format for debugging
debug.log can be used for debug.

-------the following bugs are known and fixed so far---

#bug refdes inside refdes is showing as a net difference at pins in net check -fixed on 07Mar12
#bug reports existing pins as deleted by partial match of refded -fixed 27Mar12
#last line is ignored in netlist extraction - fixed 03Apr12
#net rename list is missed in the diff_report

## adding page no info extraction  - commented on 21-oct-2022

##15-nov-2019 fixed first netlist has more rows than 2nd netlist, 2nd netlist has last lines of first netlist
##modified regex to allow pin names(node names) like A1Y

## attempt to fix renamed nets appearing in deleted and moved & new nets-done
## attempt to fix regex to isolate pin numbers again n 07apr2020 -done

## made compatible to capture 21-oct-2022 -done
## sort need to be added for pin in any order of renamed nets to be identified. looks like a orcad capture issue - fixed
----------------------------------
