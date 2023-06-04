---
title: "Route 53 Resolver: NXDOMAIN|SERVFAIL"
date: 2020-05-29 11:24:01 +0300
tags:
- aws
- dns
---

What we have:

- On premises data center with own domain zone (domain.local) and dns servers
- AWS VPC with it's own domain zone (domain.r53) and using Route 53 as DNS Server

What we need:

- Ability to resolve domain zone hosted on premises DNS Servers from AWS VPC

{{< mermaid >}}
graph LR
  A[EC2 Instance] -->|a.domain.local| B[Route 53 Forward] -->|a.domain.local| C[DNS On Premises]
{{< /mermaid >}}

The configuration is straightforward and well described in [official documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html).

You simply create rules:

- what domain this rule for
- where forward requests to

But there is a problem. When you are trying to resolve domain that points to CNAME you can get a timeout.
When investigating traffic you can find the following errors:

```sh
18:32:21.328494 IP 10.0.0.2.domain > 192.168.1.10.33414: 57918 NXDomain 0/0/0 (68)
18:32:22.127343 IP 10.0.0.2.domain > 192.168.1.10.46394: 31940 ServFail 0/0/0 (38)
```

This is because when dealing with CNAME server makes multiple requests.
And if there is no rules for CNAME requests will go to the internet resolvers.

{{<mermaid>}}
graph LR
  A[EC2 Instance] -->|a.domain.local| B[Route 53] -->|a.domain.local| C[DNS On Premises]
  C --> |CNAME x.domain.local| B
{{</mermaid>}}

{{<mermaid>}}
graph LR
  A[EC2 Instance] -->|a.domain.local| B[Route 53] -->|x.domain.local| C[Internet]
  C -->|NXDOMAIN| B
  B -->|NXDOMAIN| A
{{</mermaid>}}

To fix errors we need create R53 Forward Rules for CNAME domains as well.

{{<mermaid>}}
graph LR
  A[EC2 Instance] -->|a.domain.local| B[R53 Forward] -->|a.domain.local| C[DNS On Premises]
  C[DNS On Premises] -->|CNAME x.domain.local| B[R53 Forward]
{{</mermaid>}}

{{<mermaid>}}
graph LR
  A[EC2 Instance] -->|a.domain.local| B[R53 Forward] -->|x.domain.local| C[DNS On Premises]
  C -->|A 192.168.1.200| B
  B -->|A 192.168.1.200| A
{{</mermaid>}}

