#!/bin/bash

a=100
#a is 10 and integer

b=xyz
# abc is string

### No datatypes in BASH screpting by default all are string


echo Value of a : $a

echo Value of b: $b

echo $a:$b

echo Today is : $(date +%F)

echo 2nd date : $(date)

echo Value : $$
echo Value : $@
echo Value : $(who)
echo Value : $(uptime | awk -F : '{print $NF}' | awk -F , '{print $1}')