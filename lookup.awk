#!/bin/awk -f
BEGIN {
  # initialize
  requested_function = ARGV[1];
  FS="|";
  while ( ( getline < "functions.csv" ) > 0 ) function_array[$1]=$2;
  current_pos = 1; 
  annotation = "";
  result = "";
  hitpos = 0;
  # lookup function annotation per position
  while ( current_pos <= length(requested_function) ) {
    result = function_array[substr(requested_function,1,current_pos)];
    if ( length(result) > 0 ) {
      annotation = annotation " " result;
      hitpos = current_pos;
    }
    current_pos++; 
  }
  # display function annotation
  if ( hitpos > 0 ) {
    if ( hitpos == length(requested_function) ) {
      print requested_function " :" annotation
    } else {
      print "(" substr(requested_function,1,hitpos) ")" substr(requested_function,hitpos+1) " :" annotation " ??";
    }
  } else {
    print requested_function " : ??";
  }
}
