# ==================================
# Project : NS2 Simulation
# ID : 1805028
# ==================================
# Config :
# Connection type : Wired
# Agent + Application : TCP-Vegas + FTP
# Node positioning : Random
# ==================================

# simulator
set ns [new Simulator]

$ns color 1 green
$ns color 2 Orange
$ns color 3 Red

# ======================================================================
# Define options
set val(area_size)        1000                    ;# area size

# =======================================================================

# Define variable Parameters
set val(node_count)       [lindex $argv 0]        ;# number of nodes
set val(flow_count)       [lindex $argv 1]        ;# number of flows
set val(packet_count)     [lindex $argv 2]        ;# packet rate (packets/sec)

# Define traffic parameters
set val(packet_type) 		1
set val(packet_size) 		200
set val(packet_rate)		[expr $val(packet_size) * $val(packet_count)]

# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all $nam_file


# node configs
# ======================================================================

# $ns node-config -addressingType flat or hierarchical or expanded
#                  -adhocRouting   DSDV or DSR or TORA
#                  -llType	   LL
#                  -macType	   Mac/802_11
#                  -propType	   "Propagation/TwoRayGround"
#                  -ifqType	   "Queue/DropTail/PriQueue"
#                  -ifqLen	   50
#                  -phyType	   "Phy/WirelessPhy"
#                  -antType	   "Antenna/OmniAntenna"
#                  -channelType    "Channel/WirelessChannel"
#                  -topoInstance   $topo
#                  -energyModel    "EnergyModel"
#                  -initialEnergy  (in Joules)
#                  -rxPower        (in W)
#                  -txPower        (in W)
#                  -agentTrace     ON or OFF
#                  -routerTrace    ON or OFF
#                  -macTrace       ON or OFF
#                  -movementTrace  ON or OFF

# ======================================================================

# random function
expr { srand(19) }
proc generateRandom {m mod a} {
    expr int($m * rand()) % $mod + $a
}


# create nodes
for {set i 0} {$i < $val(node_count) } {incr i} {
    set node($i) [$ns node]

    # Node Positioning : RANDOM
    $node($i) set X_ [generateRandom 10000 $val(area_size) 0.5]
    $node($i) set Y_ [generateRandom 10000 $val(area_size) 0.5]
    $node($i) set Z_ 0
}

set temp [expr int($val(node_count) * 0.5)]
for {set i 0} {$i < $temp} {incr i} {
    set to [expr $i + $temp]
    $ns duplex-link $node($i) $node($to) 1Mb 2ms DropTail
    $ns queue-limit $node($i) $node($to) 10
}

# create flows
for {set i 0} {$i < $val(flow_count)} {incr i} {

    # Traffic config
    set tcp [new Agent/TCP/Vegas]          ;# create agent

    set src [generateRandom 1000 $val(node_count) 0]
    if { $src >= $temp } {
        set src [expr $src - $temp]
    }
    $ns attach-agent $node($src) $tcp          ;# attach agent to node

    set sink [expr $src + $temp]
    set tcp_sink [new Agent/TCPSink]              ;# create sink agent
    $ns attach-agent $node($sink) $tcp_sink       ;# attach sink agent to node

    $ns connect $tcp $tcp_sink                 ;# connect agents
    $tcp set fid_ $i

    # Traffic generator
    #set cbr [new Application/Traffic/CBR]      ;# create traffic generator
    #$cbr attach-agent $tcp                     ;# attach traffic generator to agent
    # Traffic generator
    set telnet [new Application/Telnet]
    # attach to agent
    $telnet attach-agent $tcp

    # # Traffic config parameters
    $telnet set type_ $val(packet_type)             ;# packet type
    $telnet set packetSize_  $val(packet_size)      ;# packet size
    $telnet set maxseq_ $val(packet_rate)           ;# sending rate
    $telnet set random_ false

    # start traffic generation
    $ns at 1.0 "$telnet start"
    $ns at 19.5 "$telnet stop"
}

# End Simulation

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
    exit 0
}

$ns at 20.0 "finish"

puts "Simulation started"
# Run simulation
$ns run

