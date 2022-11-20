#!c:\perl\bin
#####################################################################
#
#bug refdes inside refdes is showing as a net difference at pins in net check -fixed on 07Mar12
#bug reports existing pins as deleted by partial match of refded -fixed 27Mar12
#last line is ignored in netlist extraction - fixed 03Apr12
#net rename list is missed in the diff_report

## adding page no info extraction  - commented on 21-oct-2022

##15-nov-2019 fixed first netlist has more rows than 2nd netlist, 2nd netlist has last lines of first netlist
##modified regex to allow pin names(node names) like A1Y

## attempt to fix renamed nets appearing in deleted and moved & new nets-done
## attempt to fix regex to isolate pin numbers again n 07apr2020 - done

## made compatible to capture 21-oct-2022 -done
## sort need to be added for pin in any order of renamed nets to be identified. looks like a orcad capture issue - fixed on 2022

######################################################################
use File::Basename;
use strict;
use warnings;
use Data::Dumper;
#use DateTime;
#my $dt2 = DateTime->now(time_zone=>'local');
 
if ($#ARGV != 1 ) 
	 {
	 print "usage: sort_netlist_extract.pl old-netlist new-netlist";
	exit;
	 }
print "\n******     0v7 07-Apr-2020.....\n";
print "\n******    Reading Netlist .....\n";

my $inputfile1 = shift(@ARGV);						#get text based IN filename
my $inputfile2 = shift(@ARGV);
my $pstpinfile= shift(@ARGV);

my $result   = dirname $inputfile1;
print $result;
#my $filename = basename $filespec;

#$result = 'C:\\temp\\';

#my $inputfile=$ARGV[0];



open(log_file, "> ".$result.'\\'."debug.log");
open(diff_rpt_file, "> ".$result.'\\'."diff_report.txt");

print log_file  $inputfile1."\n";

#print diff_rpt_file $dt2."\n";

open(netlist1, "< $inputfile1") or die "\nCouldn't open input file\n";
my @input_lines = <netlist1>;
close netlist1;
chomp @input_lines;
#foreach(@input_lines){print log_file $_."\n";}
print log_file $inputfile1." being processed\n";
my($netlist1_2d_ref)=extract_netlist_file(\@input_lines);
my %NetArray1 = %{$netlist1_2d_ref};
undef @input_lines;
#print $NetArray1_ref;
#print scalar keys %NetArray1;
open(netlist1_out, "> ".$result.'\\'."netlist1_out.txt");		
#just test a display
 for(my $i=0;$i<(scalar keys %NetArray1);$i++)#just a display
	 {
	 print netlist1_out "${$NetArray1{$i}}[0] \t ${$NetArray1{$i}}[1] \n";
	 }
close netlist1_out;
print log_file "###############################################################################first file copied to array#######################################\n";
print "####################first file copied to array########################\n";

open(netlist2, "< $inputfile2") or die "\nCouldn't open input file\n";	
my @input_lines2 = <netlist2>;
close netlist2;
chomp @input_lines2;
#foreach(@input_lines){print log_file $_."\n";}
my($netlist2_2d_ref)=extract_netlist_file(\@input_lines2);
my %NetArray2 = %{$netlist2_2d_ref};
my($page_netname)=extract_page_netname(\@input_lines2);### page number extracttion
undef @input_lines2;
#print $NetArray1_ref;
#print scalar keys %NetArray2;
open(netlist2_out, "> ".$result.'\\'."netlist2_out.txt");
#just test a display
 for(my $i=0;$i<(scalar keys %NetArray2);$i++)#just a display
	 {
	 print netlist2_out "${$NetArray2{$i}}[0] \t ${$NetArray2{$i}}[1] \n";
	 }
close netlist2_out;	
print log_file "###############################################################################second file copied to array #######################################\n";
print "####################second file copied to array ######################\n";


	
print log_file "starting simple string comparison from %NetArray2 to %NetArray1 to filter out;result is stored in %Netlist1_missing \n";
print  "starting simple string comparison from %NetArray2 to %NetArray1 \n";

my($Netlist1_missing_ref,$netlist_line_match2)=simple_compare(\%NetArray2,\%NetArray1);
my %Netlist1_missing= %{$Netlist1_missing_ref};

#print log_file "#################Array##########################################\n";
#just test a display
# for($i=0;$i<(scalar keys %Netlist1_missing);$i++)#just a display
	# {
	# print log_file "${$Netlist1_missing{$i}}[0] \t ${$Netlist1_missing{$i}}[1] \n";
	# }

# print log_file "###########################################################\n";
	
##########################
print log_file "starting simple string comparison from %NetArray1 to %NetArray2 to filter out;result is stored in %Netlist2_missing \n";
print "starting simple string comparison from %NetArray1 to %NetArray2  \n";
my($Netlist2_missing_ref,$netlist_line_match1)=simple_compare(\%NetArray1,\%NetArray2);
my %Netlist2_missing= %{$Netlist2_missing_ref};
#print log_file "#################array##########################################\n";
#just test a display
# for($i=0;$i<(scalar keys %Netlist2_missing);$i++)#just a display
	# {
	# print log_file "${$Netlist2_missing{$i}}[0] \t ${$Netlist2_missing{$i}}[1] \n";
	# }

# print log_file "###########################################################\n";

undef %NetArray1,%NetArray2;	

########## check net naming/renaming without electrical changes
print log_file "##############check net naming/renaming without electrical changes#########################\n";
print "#######check net naming/renaming without electrical changes##########\n";
print diff_rpt_file "###rename_net###\n";
my @renamed_new_nets;
my @renamed_old_nets;
for(my $i=0;$i<(scalar keys %Netlist1_missing);$i++)
	{
	for(my $j=0;$j<(scalar keys %Netlist2_missing);$j++)
		{
			if((${$Netlist1_missing{$i}}[1]) eq (${$Netlist2_missing{$j}}[1]))
				{
				print log_file " NET ${$Netlist2_missing{$j}}[0] is renamed to ${$Netlist1_missing{$i}}[0] \n";
				push @renamed_old_nets,${$Netlist2_missing{$j}}[0];
				push @renamed_new_nets,${$Netlist1_missing{$i}}[0];
				print diff_rpt_file "${$Netlist2_missing{$j}}[0]"."\t"."${$Netlist1_missing{$i}}[0]\n";
				last;
				}
		}
	}

print diff_rpt_file "###rename_net_end###\n";
print log_file "###########################################################\n";	
print "###########################################################\n";	
	


	

print log_file "############## find new nets added and nets deleted\n";
print "############## find new nets added and nets deleted\n";

## new nets array
my @new_nets;



for(my $i=0;$i<(scalar keys %Netlist1_missing);$i++)
	{
	my $found_flag=0;
	for(my $j=0;$j<(scalar keys %Netlist2_missing);$j++)
		{
			if((${$Netlist1_missing{$i}}[0]) eq (${$Netlist2_missing{$j}}[0]))
				{
				$found_flag=1;
				#print log_file " NET ${$Netlist2_missing{$i}}[0] is renamed to ${$Netlist1_missing{$i}}[0] \n";
				last;
				}
		}
		
		if($found_flag==0)
		{
		push @new_nets,${$Netlist1_missing{$i}}[0];
	#	print log_file "new net ${$Netlist1_missing{$i}}[0] \n";	
		}
		
	}
print log_file "new nets:-";
print diff_rpt_file "###new_nets###\n";



foreach(@renamed_new_nets){
	print log_file  $_.' renamed new nets'."\n";
	
for(my $j=0;$j<(scalar @new_nets);$j++)
{
print log_file  $new_nets[$j].' from new nets'."\n";

if($new_nets[$j] eq $_){
	
	print log_file  $_.'renamed net is found in new nets'."\n";
	$new_nets[$j]='';
	last;
}


}

	
}	






foreach(@new_nets){
if ($_ ne '' )	
		{
		print log_file  $_.',';
		print diff_rpt_file  $_."\n";
		}
}
print log_file "\n";
#print diff_rpt_file "\n";
print log_file "###########################################################\n";
print diff_rpt_file "###new_nets_end###\n";
### removed nets array

undef @new_nets;

my @del_nets;



for(my $i=0;$i<(scalar keys %Netlist2_missing);$i++)
	{
	my $found_flag=0;
	for(my $j=0;$j<(scalar keys %Netlist1_missing);$j++)
		{
			if((${$Netlist1_missing{$j}}[0]) eq (${$Netlist2_missing{$i}}[0]))
				{
				$found_flag=1;
				last;
				}
		}
		
		if($found_flag==0)
		{
		push @del_nets,${$Netlist2_missing{$i}}[0];
		#print log_file "deleted net ${$Netlist2_missing{$i}}[0] \n";	
		}
		
	}

print log_file "deleted nets:-";
print diff_rpt_file "###deleted_nets###\n";

### look up for renamed nets before printing	

foreach(@renamed_old_nets){
	print log_file  $_.' renamed old nets'."\n";
	
for(my $j=0;$j<(scalar @del_nets);$j++)
{
print log_file  $del_nets[$j].' from old nets'."\n";

if($del_nets[$j] eq $_){
	
	print log_file  $_.'renamed net is found in old nets'."\n";
	$del_nets[$j]='';
	last;
}


}

	
}	


foreach(@del_nets){

if ($_ ne '' )
	{
	
print log_file  $_.',';
print diff_rpt_file  $_."\n";

	}


}

print log_file "\n";
#print diff_rpt_file "\n";
print log_file "###########################################################\n";
print diff_rpt_file "###deleted_nets_end###\n";

undef @del_nets;

#### check for pin/connection changes

print log_file "##########checking moved/floating pins###################\n";
print  "##########checking moved/floating pins###################\n";

my $found_flag=0;
my $temp_pin;
my @temp_last_moved=();
my @temp_moved;
my @temp_last_del=();
my @temp_del;
my %moved_pins;
my %deleted_pins;
my $k=0;
my $l=0;
for(my $i=0;$i<(scalar keys %Netlist2_missing);$i++)
	{
#print log_file ${$Netlist2_missing{$i}}[0]."\n";
my $pin_in_net_ref=pins_in_net(${$Netlist2_missing{$i}}[1]);
my @pin_in_net_array=@{$pin_in_net_ref};
	
	foreach(@pin_in_net_array)
	{
  # print log_file 'temp pin '.$_,"\n";
	$temp_pin=$_;
	my $temp_pin_len=length($temp_pin);
	my $temp_substr='';
	my $temp_line='';
#	print log_file 'temp pin len '.$temp_pin_len."\n";

	$found_flag=0;
		for(my $j=0;$j<(scalar keys %Netlist1_missing);$j++)
		{	
					if(index(${$Netlist1_missing{$j}}[1],$temp_pin.',',0) ne -1 ) 
					{	
					#print log_file 'line '.${$Netlist1_missing{$j}}[1]."\n";
					#print log_file 'line length '.length(${$Netlist1_missing{$j}}[1])."\n";
					$temp_line=${$Netlist1_missing{$j}}[1];
					my $pin_index=index(${$Netlist1_missing{$j}}[1],$temp_pin.',',0);
					#print log_file 'index '.$pin_index."\n";
					
					#if((index(${$Netlist1_missing{$j}}[1],$temp_pin.',',0 ) == 0) or substr(${$Netlist1_missing{$j}}[1],((index(${$Netlist1_missing{$j}}[1],$temp_pin.',',0)-1),$temp_pin_len+1) eq (','.$temp_pin.',') ))
					
					# if($pin_index ne 0)
					# {
					# print log_file 'pin '.substr(${$Netlist1_missing{$j}}[1],($pin_index-1),($temp_pin_len+2))."\n";
					# }
					# else
					# {
					# print log_file 'pin '.substr(${$Netlist1_missing{$j}}[1],($pin_index),($temp_pin_len+1))."\n";
					# }
					
					$temp_substr=substr(${$Netlist1_missing{$j}}[1],($pin_index-1),($temp_pin_len+2));
					
					if(($pin_index == 0) or (($temp_substr) eq (','.$temp_pin.',')) )
							{
								if(${$Netlist1_missing{$j}}[0] ne ${$Netlist2_missing{$i}}[0])#comparing netnames
									{
									#&& (${$Netlist1_missing{$j}}[0] ne ${$Netlist2_missing{$i}}[0])
									#print log_file "(${$Netlist1_missing{$j}}[0] ne ${$Netlist2_missing{$i}}[0])\n";
									#print log_file "found pin $temp_pin on ${$Netlist1_missing{$j}}[0]\n";
									#print log_file "Pin $temp_pin on NET ${$Netlist2_missing{$i}}[0] is moved to ${$Netlist1_missing{$j}}[0]\n";
									 @temp_moved=($temp_pin,${$Netlist2_missing{$i}}[0],${$Netlist1_missing{$j}}[0]);## array for keeping moved-pin,net1,net2

										$moved_pins{$k} = [@temp_moved];## move to 2d array
										#print log_file "pushed to array $temp_last_moved[0],$temp_last_moved[1],$temp_last_moved[2]\n";						

										$k++;
									
									}
							$found_flag=1;
							last;		
							}
					else# a partial match.. ignore;change the found_flag to skip it;
						{
						$found_flag=2;
						}
					}
		}
	
	if($found_flag==0)
		{
	#	print log_file "Pin $temp_pin on NET ${$Netlist2_missing{$i}}[0] is deleted or floating\n";
		@temp_del=($temp_pin,${$Netlist2_missing{$i}}[0]);
		#print log_file "$temp_line". ' doesnot contain '. "$temp_pin\n";
	#	print log_file 'substr '."$temp_substr\n";
		$deleted_pins{$l} = [@temp_del];
		#print log_file "pushed to array $temp_del[0],$temp_del[1] \n";						

		$l++;

		}
	
	}
	

	}

## group with net names before display

for(my $i=0;$i<(scalar keys %moved_pins);$i++)#just a display
	{
	for(my $j=0;$j<(scalar keys %moved_pins);$j++)
		{
			if ((${$moved_pins{$i}}[1] eq ${$moved_pins{$j}}[1]) && (${$moved_pins{$i}}[2] eq ${$moved_pins{$j}}[2]) && ($i ne $j))
			{
			#print log_file "duplicating nets ${$moved_pins{$i}}[1] ${$moved_pins{$i}}[2] \n";
			${$moved_pins{$i}}[0]=${$moved_pins{$i}}[0].','.${$moved_pins{$j}}[0];
			${$moved_pins{$j}}[0]='';
			${$moved_pins{$j}}[1]='';
			${$moved_pins{$j}}[2]='';#delete the copied cells
			#print log_file ${$moved_pins{$i}}[0]."\n";
			}
		}
	}

	
for(my $i=0;$i<(scalar keys %deleted_pins);$i++)#just a display
	{
	for(my $j=0;$j<(scalar keys %deleted_pins);$j++)
		{
			if ((${$deleted_pins{$i}}[1] eq ${$deleted_pins{$j}}[1]) && ($i ne $j))
		{
			#print log_file "duplicating nets ${$moved_pins{$i}}[1] ${$moved_pins{$i}}[2] \n";
			${$deleted_pins{$i}}[0]=${$deleted_pins{$i}}[0].','.${$deleted_pins{$j}}[0];
			${$deleted_pins{$j}}[0]='';
			${$deleted_pins{$j}}[1]='';#delete the copied cells
			#print log_file ${$deleted_pins{$i}}[0]."\n";
		}
		}
	}
	


### check and remove the renamed nets from moved pins

foreach(@renamed_new_nets){
	print log_file  $_.' renamed new nets in moved pins'."\n";
	
for(my $j=0;$j<(scalar keys %moved_pins);$j++)
	{
	print log_file  ${$moved_pins{$j}}[2].' from new nets'."\n";

	if(${$moved_pins{$j}}[2] eq $_){
		
		print log_file  $_.'renamed net is found in new nets in moved pins'."\n";
		${$moved_pins{$j}}[1]='';
		last;
	}
	}
}	


	
#just test a display
print log_file "######### moved pins\n";
print diff_rpt_file "###moved_pins###\n";
for(my $i=0;$i<(scalar keys %moved_pins);$i++)#just a display
	{
	if (${$moved_pins{$i}}[1] ne '' )
		{ 
		print log_file "${$moved_pins{$i}}[0] : ${$moved_pins{$i}}[1] -> ${$moved_pins{$i}}[2]\n";
		print diff_rpt_file "${$moved_pins{$i}}[0]"."\t"."${$moved_pins{$i}}[1]"."\t"."${$moved_pins{$i}}[2]\n";
		}
	}

print diff_rpt_file "###moved_pins_end###\n";	
print log_file "######### deleted pins\n";
print diff_rpt_file "###deleted_pins###\n";
for(my $i=0;$i<(scalar keys %deleted_pins);$i++)#just a display
	{
	if (${$deleted_pins{$i}}[1] ne '' )
		{
		print log_file "${$deleted_pins{$i}}[0] : ${$deleted_pins{$i}}[1] \n";
		print diff_rpt_file "${$deleted_pins{$i}}[0]"."\t"."${$deleted_pins{$i}}[1]\n";
		}
	}

	undef %moved_pins;
	undef %deleted_pins;
print diff_rpt_file "###deleted_pins_end###\n";	
print log_file "##########checking new pins added ###################\n";
print  "##########checking new pins added ###################\n";


my %new_pins;
my @temp_new_pins;
#my @temp_last_new_pins=();
$k=0;


for(my $i=0;$i<(scalar keys %Netlist1_missing);$i++)
	{

my $pin_in_net_ref=pins_in_net(${$Netlist1_missing{$i}}[1]);
my @pin_in_net_array=@{$pin_in_net_ref};
	
	foreach(@pin_in_net_array)
	{
    #print log_file $_,"\n";
	$temp_pin=$_;
	$found_flag=0;
		for(my $j=0;$j<(scalar keys %Netlist2_missing);$j++)
		{	
			if(index(${$Netlist2_missing{$j}}[1],$temp_pin,0) ne -1)
			{	
			$found_flag=1;
			last;
			}
		}
	
	if($found_flag==0)
		{
		#print log_file "Added new pin $temp_pin on NET ${$Netlist1_missing{$i}}[0]\n";
				@temp_new_pins=($temp_pin,${$Netlist1_missing{$i}}[0]);

						$new_pins{$k} = [@temp_new_pins];
						#print log_file "pushed to array $temp_last_new_pins[0],$temp_last_new_pins[1] \n";						
						#@temp_last_new_pins=@temp_new_pins;
						$k++;
						#}		
		}
	
	}
	
	}

	
 for(my $i=0;$i<(scalar keys %new_pins);$i++)#just a display
 {
 for(my $j=0;$j<(scalar keys %new_pins);$j++)#just a display
		 {
			if ((${$new_pins{$i}}[1] eq ${$new_pins{$j}}[1]) && ($i ne $j))
			 {
			##print log_file "duplicating nets ${$moved_pins{$i}}[1] ${$moved_pins{$i}}[2] \n";
			${$new_pins{$i}}[0]=${$new_pins{$i}}[0].','.${$new_pins{$j}}[0];
			 ${$new_pins{$j}}[0]='';
			 ${$new_pins{$j}}[1]='';#delete the copied cells
		##	print log_file ${$new_pins{$i}}[0]."\n";
			 }
		}
 }	

	
	
print log_file "######### new pins\n";
print diff_rpt_file "###new_pins###\n";	
for(my $i=0;$i<(scalar keys %new_pins);$i++)#just a display
	{
	if (${$new_pins{$i}}[1] ne '' ){print log_file "${$new_pins{$i}}[0] : ${$new_pins{$i}}[1] \n";}
	if (${$new_pins{$i}}[1] ne '' ){print diff_rpt_file "${$new_pins{$i}}[0]"."\t"."${$new_pins{$i}}[1]\n";}
	}
print diff_rpt_file "###new_pins_end###\n";	
	
close log_file;
close diff_rpt_file;









####################### sub routines
sub extract_netlist_file
{


my $arr1=$_[0];

my @netlist=@$arr1;
my $temp1='';
my $temp2='';
my $temp3;
#undef @temp;#clear 1D array
my @temp;

my $k=0;
my $pattern1='NET_NAME';
#$pattern2='NODE_NAME\s+([\S]+)\s+([\S]+)';
my $pattern2='NODE_NAME\s+([A-Z]+?[0-9]*?[A-Z]*?[0-9]*?)\s+([A-Z]*?[0-9]+?)$';
#/([A-Z]+?[0-9]*?[A-Z]*?[0-9]*?[\.][A-Z]*?[0-9]+?),/gi
my $combine_flag=0;
my %_netArray;

for(my $i=0;$i<(scalar @netlist);$i++)
		{
#print "$i\n";
#print log_file $_;
		$_=$netlist[$i];
		
		if ((m/$pattern1/) && $combine_flag eq 0)# first time ever in the loop
					{

					$temp1=$netlist[($i+1)];
					#print log_file $temp;
					#print log_file 'first occurance'.$temp."\n";
					$combine_flag=1;
					}
			elsif((m/$pattern1/) && $combine_flag eq 1)#moving to new net name..  complete the net & pins for the curretn net now
					{
					
					### sort the $temp2 & put back in temp2
					$temp2=sort_pins_in_net($temp2);
					@temp=($temp1,$temp2.','); 
					$_netArray{$k}=[@temp];
					$k++;
					$temp2='';
					#print log_file '$temp[0]->'.$temp[0]."\n";
					undef @temp;#clear 1D array
					$temp[0]='';
					$temp1=$netlist[($i+1)];
					#print log_file '$temp1->'.$temp1."\n";
					$combine_flag=1;
					
					}
			elsif(m/$pattern2/)
					{
					#print log_file " $_ has spaces in starting\n";
					$temp2=$temp2.$1.'.'.$2.',';
					#$temp3='NODE_NAME'.'     '.$1.' '.$2;
					$temp3='NODE_NAME'."\t".$1.' '.$2;#tab was used in capture while concpet hdl uses 5 spaces
					#print log_file $temp2."\n";
					if($temp3 ne $_) ## re assembling pins to make sure that regex is not missing anything
					{
					print "Runtime Error:optimize regex for pins extraction!!!!!!!!!!!!!!!!!!!!!!!!!\n";
					print log_file "Runtime Error:optimize regex for pins extraction!!!!!!!!!!!!!!!!!!!!!!!!!\n";
					print log_file $_."\n";
					print log_file 'NODE_NAME'."\t".$1.' '.$2."\n";
					}
					else
						{
						#print log_file '$temp3->'.$temp3."\n";
						#print log_file '$temp2->'.$temp2."\n";
						}

					}
		
		#print log_file $temp3;
		#print log_file "\n";
		}


#store the last pin to array
@temp=($temp1,$temp2); 
print log_file "printing dumper(\@temp)"."\n";
print log_file Dumper(@temp);
#print @temp;
#print "\n";
$_netArray{$k}=[@temp];	
undef @temp;
undef $temp1;
undef $temp2;		
		
		
return \%_netArray;
}

############ extract page numbers
sub extract_page_netname
{

print log_file "\n Getting into extract page netname \n";

my $arr1=$_[0];

my @netlist=@$arr1;
my $temp1='';
my $temp2='';
my $temp3;
#undef @temp;#clear 1D array
my @temp;
my %_netArray;
my $k=0;
my $pattern1='NET_NAME';
#$pattern2='NODE_NAME\s+([\S]+)\s+([\S]+)';
my $pattern2='PAGE([0-9]+)';
#/([A-Z]+?[0-9]*?[A-Z]*?[0-9]*?[\.][A-Z]*?[0-9]+?),/gi
my $combine_flag=0;
for(my $i=0;$i<(scalar @netlist);$i++)
		{
#print log_file "\n$i\n";
#print log_file $_."\n";

		$_=$netlist[$i];
		
		if ((m/$pattern1/) && $combine_flag eq 0)# first time ever in the loop
					{

					$temp1=$netlist[($i+1)];
					#print log_file 'first occurance'.$temp1."\n";
					#print log_file $temp1."\n";
					$combine_flag=1;
					}
			elsif((m/$pattern1/) && $combine_flag eq 1)#moving to new net name..  complete the net & pins for the curretn net now
					{
					@temp=($temp1,$temp2); 
					$_netArray{$k}=[@temp];
					$k++;
					$temp2='';
					#print log_file "entered in 2nd loop ".$temp1."->".$temp2."\n";
					#undef @temp;#clear 1D array
					#$temp='';
					$temp1=$netlist[($i+1)];
					#print log_file $temp1."\n";
					##$combine_flag=0; ##clear for next netname
					}
			elsif(m/$pattern2/)
					{
					#print log_file " pattern2 match \n";
					my $temp4=$1.',';
					## check whether the page number is already present in the list before adding
					 if($temp2 !~ /$temp4/)
					{
					$temp2=$temp2.$temp4;
					$temp3='PAGE NO '.$temp4;
					
					}
					
					#print log_file $temp2."\n";
					#print log_file $temp3."\n";
					
					}
		

		}
		
#store the last net connection also to array
@temp=($temp1,$temp2); 
$_netArray{$k}=[@temp];		
undef @temp;
undef $temp1;
undef $temp2;		
print log_file "\n exiting from extract page netname \n";	
		
return \%_netArray;
}


### Start simple comparison of %NetArray2 & %NetArray1
sub simple_compare
{
my $arr1=$_[0];
my $arr2=$_[1];

my $found_net_flag;
my @temp;
my $k=0;
my %net_missing;
my $same=0;
my $j;
for(my $i=0;$i<(scalar (keys %{$arr1}));$i++)
	{
my $found_net_flag=0;
     for( $j=0;$j<(scalar (keys %{$arr2}));$j++)
		{
		 if((${${$arr1}{$i}}[0] eq ${${$arr2}{$j}}[0]))
			 {
			 #print log_file "${$NetArray1{$i}}[0]\n";
			 $found_net_flag=1;
			 last;
			 }

		}
		
	if($found_net_flag==0)
		 {
		# print log_file "${${$arr1}{$i}}[0] not found in 2nd Array\n";
		 @temp=(${${$arr1}{$i}}[0],${${$arr1}{$i}}[1]);
		  $net_missing{$k}=[@temp];
		  $k++;
		 }
		 
	 elsif($found_net_flag==1 && (${${$arr1}{$i}}[1] ne ${${$arr2}{$j}}[1]))
		{
		#print log_file "${${$arr1}{$i}}[0] has a change in pins on 2nd Array\n";
		@temp=(${${$arr1}{$i}}[0],${${$arr1}{$i}}[1]);
		$net_missing{$k}=[@temp];
		  $k++;
		}
	 else
		{
		$same++;
		}
	
	}
	
return (\%net_missing,$same);	
	
###############################
}


sub pins_in_net
{
my $temp=$_[0];


my @pins_array=($temp=~/([A-Z]+?[0-9]*?[A-Z]*?[0-9]*?[\.][A-Z]*?[0-9]+?),/gi);

my $temp1=join(',', @pins_array);


#check regex by comparing input & outputs


if ($temp ne $temp1.',')
{
print "Runtime Error:optimize regex for pins isolation!!!!!!!!!!!!!!!!!!!!!!!!!\n";
print log_file "Runtime Error:optimize regex for pins isolation!!!!!!!!!!!!!!!!!!!!!!!!!\n";
print log_file $temp1.',';
print log_file "\n";
print log_file "$temp\n";
}

return \@pins_array;
}

#######################################

sub sort_pins_in_net
{
my $temp=$_[0];


my @pins_array=($temp=~/([A-Z]+?[0-9]*?[A-Z]*?[0-9]*?[\.][A-Z]*?[0-9]+?),/gi);

my @sorted_pins_array= sort @pins_array;

my $temp1=join(',', @pins_array);
my $temp2=join(',', @sorted_pins_array);

#print log_file 'sort_pins_in_net temp1 '.$temp1."\n";
#print log_file 'sort_pins_in_net temp2 '.$temp2."\n";

#check regex by comparing input & outputs


return $temp2;
}
