# simulator
set ns [new Simulator]


# ======================================================================
# Define options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          CMUPriQueue              ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
# set val(netif)        Phy/WirelessPhy/802_15_4 ;# network interface type
# set val(mac)          Mac/802_15_4             ;# MAC type
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSR                      ;# ad-hoc routing protocol 

set width             500
set height            500
set val(nx)           5                        ;# number of columns
set val(ny)           8                        ;# number of flows
set val(nn)           [expr $val(nx) * $val(ny)];# number of mobilenodes

set start_time        0.0
set end_time          30.0

# set val(energyModel)  EnergyModel
# set val(initialEnergy) 100.0                   ;
# set val(txPower)       0.9                     ; 
# set val(rxPower)       0.5                     ;
# set val(idlePower)     0.45                    ;
# set val(sleepPower)    0.05                    ;
# =======================================================================

# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all-wireless $nam_file $width $height

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $width $height ;# 500m x 500m area


# general operation director for mobilenodes
create-god $val(nn)


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
                -movementTrace OFF\
                -energyModel $val(energyModel) \
                -initialEnergy $val(initialEnergy) \
                -txPower $val(txPower) \
                -rxPower $val(rxPower) \
                -idlePower $val(idlePower) \
                -sleepPower $val(sleepPower) \

# create nodes
for {set i 0} {$i < $val(nx) } {incr i} {
	for {set j 0} {$j < $val(ny) } {incr j} {
		
		set node([expr {$i*$val(ny)+$j}]) [$ns node]
		$node([expr {$i*$val(ny)+$j}]) random-motion  0   ;# disable random motion
        $node([expr {$i*$val(ny)+$j}]) set energyModel_ SimplePowerModel
        $node([expr {$i*$val(ny)+$j}]) set initialEnergy_ 100.0

		$node([expr {$i*$val(ny)+$j}]) set X_ [expr ($width * $i) / $val(nx)]
		$node([expr {$i*$val(ny)+$j}]) set Y_ [expr ($height * $j) / $val(ny)]
		$node([expr {$i*$val(ny)+$j}]) set Z_ 0

		$ns initial_node_pos $node([expr {$i*$val(ny)+$j}]) 20
	}
    
}
# producing node movements with uniform random speed
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at [expr int(20 * rand()) + 0.0] "$node($i) setdest [expr int(10000 * rand()) % $width + 0.5] [expr int(10000 * rand()) % $height + 0.5] [expr int(100 * rand()) % 5 + 1]"
} 

# Traffic
set a               0
set b               [expr $val(nn)-1]
set src             -1
set dest            -1

# Traffic
set val(nf)         20                ;# number of flows

for {set i 0} {$i < $val(nf) } {incr i} {
    while {1} {
    set src [expr int(rand()*($b-$a+1))+$a]
    set dest [expr int(rand()*($b-$a+1))+$a]
    if {$src != $dest} { 
        break
    }
}
    # Traffic config
    # create agent]
    set tcp($i) [new Agent/TCP]
    set tcp_sink($i) [new Agent/TCPSink]
    # attach to nodes
    $ns attach-agent $node($src) $tcp($i)
    $ns attach-agent $node($dest) $tcp_sink($i)
    # connect agents
    $ns connect $tcp($i) $tcp_sink($i)
    $tcp($i) set fid_ $i

    # Traffic generator
    set telnet($i) [new Application/Telnet]
    # attach to agent
    $telnet($i) attach-agent $tcp($i)
    
    # start traffic generation
    $ns at $start_time "$telnet($i) start"
}

# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $end_time "$node($i) reset"
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

$ns at $end_time "finish"
$ns at $end_time "halt_simulation"




# Run simulation
puts "Simulation starting"
$ns run
