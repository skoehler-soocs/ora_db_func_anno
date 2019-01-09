#!/bin/awk -f
BEGIN {
  FS="|";
  while ( ( getline < "functions.csv" ) > 0 ) function_array[$1]=$2;
  current_pos = 1; 
  annotation = "";
  result = "";
  hitpos = 0;
  hitmarker = 0;
}
{
  while ( current_pos <= length($1) ) {
    result = function_array[substr($1,1,current_pos)];
    if ( length(result) > 0 ) {
      annotation = annotation " " result;
      hitpos = current_pos;
    }
    current_pos++; 
  }
}
END {  
  if ( hitpos > 0 ) {
    if ( hitpos == length($1) ) print $1 " :" annotation;
    if ( hitpos < length($1) ) print "(" substr($1,1,hitpos) ")" substr($1,hitpos+1) " :" annotation " ??";
  } else {
    print $1 " : ??";
  }
}
