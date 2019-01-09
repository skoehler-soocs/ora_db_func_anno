#!/bin/awk -f
BEGIN {
  depth = 0;
  prev_ins = 0;
  delta_ins = 0;
  current_stack = "";
  stack_to_charge = "";
  debug = 0;
}
{ 
  fn = $0;
  ins = $1;

  if ( match(fn, /Call\ [0-9a-fx]*\ .*:.*+[0-9a-fx]*\ ->\ [0-9a-fx]*/) ) {
    gsub(/+[0-9a-fx]* -> [0-9a-fx]*.*$/,"",fn);
    gsub(/^.*Call [0-9a-fx]* .*:/,"",fn);
    delta = ins - prev_ins;
    prev_ins = ins;
    if ( depth == 0 ) {
      stack_to_charge = fn;
    } else {
      stack_to_charge = current_stack ";" fn;
    }
    current_stack = stack_to_charge;
    depth++;
    if ( debug == 1 ) print stack_to_charge, delta, "c1";
  } else if ( match(fn, /Call\ [0-9a-fx]*\ .*:.*\ ->\ [0-9a-fx]*/) ) {
    gsub(/ -> [0-9a-fx]*.*$/,"",fn);
    gsub(/^.*Call [0-9a-fx]* .*:/,"",fn);
    delta = ins - prev_ins;
    prev_ins = ins;
    if ( depth == 0 ) {
      stack_to_charge = fn;
    } else {
      stack_to_charge = current_stack ";" fn;
    }
    current_stack = stack_to_charge;
    depth++;
    if ( debug == 1 ) print stack_to_charge, delta, "c2";
  } else if ( match(fn, /^[0-9\ \|]+Return\ /) ) {
    gsub(/+[0-9a-fx]*\ returns.*$/,"",fn);
    gsub(/^[0-9\ \|]*\ Return\ [0-9a-fx]*\ .*:/,"",fn);
    delta = ins - prev_ins;
    prev_ins = ins;
    stack_to_charge = current_stack ";" fn;
    current_stack = stack_to_charge;
    gsub(/;[a-zA-Z0-9_\.]*;[a-zA-Z0-9_\.]*$/,"",current_stack);
    depth--;
    if ( debug == 1 ) print stack_to_charge, delta, "r";
  } else if ( match(fn, /Tailcall\ [0-9a-fx]*\ .*:.*\+[0-9a-fx]*\ ->\ [0-9a-fx]*/) ) {
    gsub(/+[0-9a-fx]* -> [0-9a-fx]*.*$/,"",fn);
    gsub(/^.*Tailcall [0-9a-fx]* .*:/,"",fn);
    delta = ins - prev_ins;
    prev_ins = ins;
    stack_to_charge = current_stack; 
    stack_to_charge = stack_to_charge ";" fn;
    if ( debug == 1 ) print stack_to_charge, delta, "tc1";
  } else if ( match(fn, /Tailcall\ [0-9a-fx]*\ .*:.*\ ->\ [0-9a-fx]*/) ) {
    gsub(/ -> [0-9a-fx]*.*$/,"",fn);
    gsub(/^.*Tailcall [0-9a-fx]* .*:/,"",fn);
    delta = ins - prev_ins;
    prev_ins = ins;
    stack_to_charge = current_stack; 
    stack_to_charge = stack_to_charge ";" fn;
    if ( debug == 1 ) print stack_to_charge, delta, "tc2";
  } else {
    if ( debug == 2 ) print fn, ins, "o";
  }
  if ( stack_to_charge != "" ) stacks_folded[stack_to_charge]+=delta;
}
END {
  PROCINFO["sorted_in"] = "@ind_str_asc"
  #PROCINFO["sorted_in"] = "@val_num_desc"
  for ( stack in stacks_folded ) print stack, stacks_folded[stack]
}
