#!/bin/bash

node_default=$((40))
flow_default=$((20))
packet_default=$((200))
speed_default=$((10))

tcl_file_to_run="topology.tcl"

node_result_file_mod="results/node-modified.out"
flow_result_file_mod="results/flow-modified.out"
packet_result_file_mod="results/packet-modified.out"
speed_result_file_mod="results/speed-modified.out"


# Varying nodes
>$node_result_file_mod
for i in 20 40 60 80 100
do
    echo "node $i " >> $node_result_file_mod
    ns "$tcl_file_to_run" $i $flow_default $packet_default $speed_default
    awk -f parse.awk trace.tr >> $node_result_file_mod
done

# Varying flows
>$flow_result_file_mod
for i in 10 20 30 40 50
do
    echo "flow $i " >> $flow_result_file_mod
    ns "$tcl_file_to_run" $node_default $i $packet_default $speed_default
    awk -f parse.awk trace.tr >> $flow_result_file_mod
done



# Varying speed
>$speed_result_file
>$speed_result_file_mod
for i in 5 10 15 20 25
do
    echo "speed $i " >> $speed_result_file_mod
    ns "$tcl_file_to_run" $node_default $flow_default $packet_default $i
    awk -f parse.awk trace.tr >> $speed_result_file_mod
done


# Varying packet rate
>$packet_result_file_mod
for i in 100 200 300 400 500
do
    echo "packet $i " >> $packet_result_file_mod
    echo ekhane
    ns "$tcl_file_to_run" $node_default $flow_default $i $speed_default 
    awk -f parse.awk trace.tr >> $packet_result_file_mod
done
