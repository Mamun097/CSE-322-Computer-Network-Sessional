#!/bin/bash

node_default=$((40))
flow_default=$((20))
packet_default=$((200))

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
    ns "$tcl_file_to_run" $i $flow_default $packet_default
    awk -f parse.awk trace.tr >> $node_result_file_mod
done

# Varying flows
>$flow_result_file_mod
for i in 10 20 30 40 50
do
    echo "flow $i " >> $flow_result_file_mod
    ns "$tcl_file_to_run" $node_default $i $packet_default
    awk -f parse.awk trace.tr >> $flow_result_file_mod
done

# Varying packet rate
>$packet_result_file_mod
for i in 100 200 300 400 500
do
    echo "packet $i " >> $packet_result_file_mod
    ns "$tcl_file_to_run" $node_default $flow_default $i
    awk -f parse.awk trace.tr >> $packet_result_file_mod
done
