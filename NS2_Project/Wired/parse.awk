BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants
    header_bytes = 20;
}


{
    event = $1;
    time_sec = $2;
    node_from = $3;
    node_to = $4;
    packet_type = $5;
    packet_bytes = $6;
    source = $9; 
    dest = $10;


    sub(/^_*/, "", node);
	sub(/_*$/, "", node);

    # set start time for the first line
    if(start_time > time_sec) {
        start_time = time_sec;
    }


    if (packet_type == "tcp") {
        
        if(event == "+" && node_from == source) {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }

        else if(event == "r" && node_to == dest) {
            delay = time_sec - sent_time[packet_id];
            total_delay += delay;

            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;

            received_packets += 1;

        }
    }

    if (packet_type == "tcp" && event == "d") {
        dropped_packets += 1;
    }
}


END {
    end_time = time_sec;
    simulation_time = end_time - start_time;
    print (received_bytes * 8) / (simulation_time * 1000), (total_delay / received_packets), (received_packets / sent_packets), 	   (dropped_packets / sent_packets);
}
