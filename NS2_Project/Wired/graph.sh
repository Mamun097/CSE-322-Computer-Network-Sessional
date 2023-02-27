#!/bin/bash
node_result_file="results/node.out"
flow_result_file="results/flow.out"
packet_result_file="results/packet.out"

node_result_file_mod="results/node-modified.out"
flow_result_file_mod="results/flow-modified.out"
packet_result_file_mod="results/packet-modified.out"

python3 mergedGraphGenerator.py $node_result_file $node_result_file_mod "node"
python3 mergedGraphGenerator.py $flow_result_file $flow_result_file_mod "flow"
python3 mergedGraphGenerator.py $packet_result_file $packet_result_file_mod "packet"
