# ==================================
# Project : NS2 Simulation
# ID: 1805028
# ==================================
# Config :
# Connection type : Wireless
# Wireless MAC protocol : 802.11
# Routing protocol : DSR
# Agent + Application : TCP-Vegas + CBR
# Node positioning : Random
# Flow : 1 sink, Random source
# ==================================

# simulator
set ns [new Simulator]

# ======================================================================
# Define options

set val(chan)         Channel/WirelessChannel     ;# channel type
set val(prop)         Propagation/TwoRayGround    ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna         ;# Antenna type
set val(ll)           LL                          ;# Link layer type
set val(ifq)          CMUPriQueue                 ;# Interface queue type
set val(ifqlen)       50                          ;# max packet in ifq
set val(netif)        Phy/WirelessPhy             ;# network interface type
set val(mac)          Mac/802_11                  ;# MAC type
set val(rp)           DSR                         ;# ad-hoc routing protocol 
set val(area_size)    1000                         ;# area size

# Define Energy Model Parameters
set val(enery_model)  EnergyModel                 ;# Energy Model
set val(init_energy)  500                         ;# Initial Energy
set val(rx_power)     1.0                         ;# Rx Power
set val(tx_power)     2.0                         ;# Tx Power
set val(sleep_power)  0.001                       ;# Sleep Power
set val(idle_power)   1.0                         ;# Idle Power
set val(trans_time)   0.005                       ;# Transmission Time
set val(trans_power)  0.2                         ;# Transmission Power

# =======================================================================

# Define variable Parameters
set val(node_count)       [lindex $argv 0]        ;# number of mobilenodes
set val(flow_count)       [lindex $argv 1]        ;# number of flows
set val(packet_count)     [lindex $argv 2]        ;# packet rate (packets/sec)
set val(speed)            [lindex $argv 3]        ;# speed 

if {$val(speed) >= 15} {
    set val(area_size) 1250
}

# Define traffic parameters
set val(packet_type) 		2
set val(packet_size) 		200
set val(packet_rate)		[expr $val(packet_size) * $val(packet_count)]

# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all-wireless $nam_file $val(area_size) $val(area_size)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(area_size) $val(area_size)


# general operation director for mobilenodes
create-god $val(node_count)


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

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF \
                -energyModel $val(enery_model) \
                -initialEnergy $val(init_energy) \
                -idlePower $val(idle_power) \
                -rxPower $val(rx_power) \
                -txPower $val(tx_power) \
                -sleepPower $val(sleep_power) \
                -transitionPower $val(trans_power) \
                -transitionTime $val(trans_time) \


# random function
expr { srand(19) }
proc generateRandom {m mod a} {
    expr int($m * rand()) % $mod + $a
}


# create nodes
for {set i 0} {$i < $val(node_count) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0       ;# disable random motion

    # Node Positioning : RANDOM
    $node($i) set X_ [generateRandom 10000 $val(area_size) 0.5]
    $node($i) set Y_ [generateRandom 10000 $val(area_size) 0.5]
    $node($i) set Z_ 0

    # Node speed
    set coord_X [generateRandom 10000 $val(area_size) 0.5]
    set coord_Y [generateRandom 10000 $val(area_size) 0.5]
    $ns at 1.0 "$node($i) setdest $coord_X $coord_Y $val(speed)"

    # Node size
    $ns initial_node_pos $node($i) 20
}


# Traffic

# configure sink
set sink [generateRandom 1000 $val(node_count) 0]

# Traffic config
set tcp_sink [new Agent/TCPSink]              ;# create sink agent
$ns attach-agent $node($sink) $tcp_sink       ;# attach tcp agent to sink node

# create flows
for {set i 0} {$i < $val(flow_count)} {incr i} {
    while {1} {
        set src [generateRandom 1000 $val(node_count) 0]
        if {$src != $sink} {
            break
        }
    }

    # Traffic config
    set tcp [new Agent/TCP/Vegas]              ;# create agent

    $ns attach-agent $node($src) $tcp          ;# attach agent to node

    $ns connect $tcp $tcp_sink                 ;# connect agents
    $tcp set fid_ $i

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
}

# End Simulation

# Stop nodes
for {set i 0} {$i < $val(node_count)} {incr i} {
    $ns at 20.0 "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at 20.0001 "finish"
$ns at 20.0002 "halt_simulation"

# Run simulation
puts "Simulation starting"
$ns run

