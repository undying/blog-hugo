---
title: "Network: Capturing TCP Retransmissions"
date: 2020-06-20 16:04:35 +0300
tags:
- linux
- network
- tcp
---

When server have a lot network connections it's not rare to see tcp retransmissions. The permanent background retransmissions it's even normal situation if it's not abnormally high.

But when the charts shows abnormally jump of retransmissions it's good to find the reason.

The reason is may be:
- server is overloaded
- remote server is overloaded
- network where servers is based is degraded
- network of remote endpoint is degraded

When servers is not overloaded the next step is to find which endpoint causes the retransmissions. We can see this in multiple ways described below.

### [Netstat](https://linux.die.net/man/8/netstat)

- To begin with it makes sense to collect statistics on retransmited packages. Netstat can help with that.
  Compare total segments count with retransmited.
```sh
netstat -s|grep segments
```

### [TShark](https://www.wireshark.org/docs/man-pages/tshark.html)

- Realtime output with source and destination
```sh
tshark -R tcp.analysis.retransmission
```

- Capture result into pcap file
```sh
tshark -i any -w /tmp/result.pcap -R tcp.analysis.retransmission
```

- Collecting data and displaying statistics after the CTRL-C
```sh
tshark -q -z io,stat,1,"COUNT(tcp.analysis.retransmission) tcp.analysis.retransmission"
```

- Use more columns in statistics.
```sh
tshark -q -z io,stat,1,\
"COUNT(tcp.analysis.fast_retransmission) tcp.analysis.fast_retransmission",\
"COUNT(tcp.analysis.retransmission) tcp.analysis.retransmission",\
"COUNT(tcp.analysis.duplicate_ack) tcp.analysis.duplicate_ack",\
"COUNT(tcp.analysis.lost_segment) tcp.analysis.lost_segment"
```

### [Perf-Tools](https://github.com/brendangregg/perf-tools)

- perf-tools has great tool named [tcpretrans](https://github.com/brendangregg/perf-tools/blob/master/net/tcpretrans).
```sh
./tcpretrans
TIME     PID    LADDR:LPORT          -- RADDR:RPORT          STATE
05:16:44 3375   10.150.18.225:53874  R> 10.105.152.3:6001    ESTABLISHED
05:16:44 3375   10.150.18.225:53874  R> 10.105.152.3:6001    ESTABLISHED
05:16:54 4028   10.150.18.225:6002   R> 10.150.30.249:1710   ESTABLISHED
```
