#!/bin/awk -f
function lookup_function( function_name ) {
  current_pos = 1; 
  annotation = "";
  result = "";
  hitpos = 0;
  while ( current_pos <= length(function_name) ) {
    result = function_array[substr(function_name,1,current_pos)];
    if ( length(result) > 0 ) {
      annotation = annotation " " result;
      hitpos = current_pos;
    }
    current_pos++; 
  }
  # display function annotation
  if ( hitpos > 0 ) {
    if ( hitpos == length(function_name) ) {
      retval = function_name " :" annotation
    } else {
      retval = "(" substr(function_name,1,hitpos) ")" substr(function_name,hitpos+1) " :" annotation " ??";
    }
  } else {
    retval = function_name " : ??";
  }
  return retval;
}
BEGIN {
  # argument handling
  if ( ARGC == 1 || ARGV[1] == "-h" ) {
    print "Usage: ./lookup.awk [-w] <function>";
    print "<function> = full function name, or part of a function name when used with -w."
    print "-w = wildcard, lookup all functions start with <function>"
    exit 1
  }
  if ( ARGV[1] == "-w" ) {
    requested_function = ARGV[2];
  } else {
    requested_function = ARGV[1];
  }
  # load functions from csv into array
  PROCINFO["sorted_in"] = "@ind_str_asc";
  FS="|";
  while ( ( getline < "functions.csv" ) > 0 ) function_array[$1]=$2;
  # lookup function annotation starting with <function>
  if ( ARGV[1] == "-w" ) {
    for ( function_from_array in function_array )
      if ( function_from_array ~ "^" requested_function ) print lookup_function(function_from_array);
  } else {
  # lookup function annotation for <function>
    print lookup_function(requested_function);
  }
}
