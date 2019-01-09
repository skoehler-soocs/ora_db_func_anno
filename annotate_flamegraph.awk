#!/bin/awk -f
function annotate(function_name) {
  current_pos = 1; 
  annotation = "";
  result = "";
  hitpos = 0;
  hitmarker = 0;
  retval= "";
  while ( current_pos <= length(function_name) ) {
    result = function_array[substr(function_name,1,current_pos)];
    if ( length(result) > 0 ) {
      annotation = annotation " " result;
      hitpos = current_pos;
    }
    current_pos++; 
  }
  if ( hitpos > 0 ) {
    if ( hitpos == length(function_name) ) retval = function_name " :" annotation;
    if ( hitpos < length(function_name) ) retval =  "(" substr(function_name,1,hitpos) ")" substr(function_name,hitpos+1) " :" annotation " ??";
  } else {
    retval = function_name " : ??";
  }
  return retval;
}
BEGIN {
  FS="|";
  while ( ( getline < "functions.csv" ) > 0 ) function_array[$1]=$2;
}
{
  FS=" ";
  if ( match($1,/<title>/) ) {
    obtained_function = $1;
    sub(/^<title>/,"",obtained_function);
    obtained_function = annotate(obtained_function);
    sub("</title>"," "obtained_function"&");
  }
  print $0;
}
