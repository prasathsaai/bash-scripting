#!/bin/bash

# case $var in
#     cond1)
#         command1 ;;
#     cond2)
#         command2 ;;
#     *)
#         exz ;;; 
# 
# esac

Action=$1

case $Action in 
    start)
        echo "Starting X service"
        ;;
    stop)
        echo "Stop X Service"
        ;;
    restart)
        echo "Restarting X service"
        ;;
    *)
        echo -e "Valid options are \e[31 start \e[0m or \e[32 stop \e[0m or \e[33 restart \e[0m only"
esac

