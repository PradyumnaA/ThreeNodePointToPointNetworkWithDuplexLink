# Create Simulator instance
set ns [new Simulator]

# Open Trace and NAM files
set ntrace [open output.tr w]
$ns trace-all $ntrace
set namfile [open output.nam w]
$ns namtrace-all $namfile

# Define Finish procedure
proc finish {} {
    global ns ntrace namfile
    $ns flush-trace
    close $ntrace
    close $namfile
    exec nam output.nam &
    exec echo "Packet drops: " &
    exec grep -c "^d" output.tr &
    exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Label nodes
$n0 label "TCP Source"
$n2 label "Sink"

# Set link color
$ns color 1 blue

# Establish links
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

# Orient links
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right

# Set queue limits
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10

# Configure Transport layer connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n2 $sink0
$ns connect $tcp0 $sink0

# Configure Application layer traffic
set cbr0 [new Application/Traffic/CBR]
$cbr0 set type_ CBR
$cbr0 set packetSize_ 100
$cbr0 set rate_ 1Mb
$cbr0 set random_ false
$cbr0 attach-agent $tcp0
$tcp0 set class_ 1

# Schedule events
$ns at 0.0 "$cbr0 start"
$ns at 5.0 "finish"

# Run simulation
$ns run
