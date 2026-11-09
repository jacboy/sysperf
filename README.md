# sysperf

A benchmark script for Debian and Ubuntu servers. One command shows the system's specs and measures disk I/O, network latency and throughput to 34 locations on six continents, and CPU performance.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/jacboy/sysperf/master/bench | bash
```

or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/jacboy/sysperf/master/bench | bash
```

A run takes about 8–10 minutes (15–20 with Geekbench). A spinner shows which step is running.

### Read the script before running it

Piping a script from the internet into bash means trusting it. If you'd rather check what it does first:

```bash
wget https://raw.githubusercontent.com/jacboy/sysperf/master/bench
less bench
bash bench
```

### Keep a log

The spinner is drawn on the terminal only, so the log contains just the results:

```bash
curl -fsSL https://raw.githubusercontent.com/jacboy/sysperf/master/bench | bash 2>&1 | tee ~/sysperf.log
```

## What it measures

### System information
CPU model, cores and frequency; disk size and usage; RAM and swap; uptime and load; OS, architecture and kernel; virtualization type (KVM, LXC, OpenVZ, bare metal…); ISP and ASN; whether IPv6 works.

### Disk I/O
Three runs of a 30-second [fio](https://github.com/axboe/fio) test (random read/write 50/50, 512 KB blocks, queue depth 64, 2 jobs, direct I/O, 2 GB file) and their average. The test file is written to **the directory you run the script from**, so run it from the disk you want to measure. For safety, the script refuses to run in a directory that other users can modify (for example a shared, group-writable folder); your home directory is fine.

### Network latency
Ping to 12 locations: Frankfurt, London, New York, Los Angeles, São Paulo, Santiago, Johannesburg, Mumbai, Singapore, Hong Kong, Tokyo and Sydney. If a host doesn't answer over IPv6, the ping is retried over IPv4.

### Network throughput
Download speed from 34 hosts of 8 providers, grouped by continent:

| Region | Locations |
|---|---|
| Europe | Frankfurt (Leaseweb), Nuremberg (Hetzner), Stuttgart (BelWü), Zurich (Init7), Amsterdam (Leaseweb), London (Leaseweb), Paris (Scaleway), Roubaix (OVH), Helsinki (Hetzner), Stockholm, Warsaw, Madrid (Vultr) |
| North America | New York, Dallas, Miami, Los Angeles (Leaseweb), Ashburn, Hillsboro (Hetzner), Toronto, Chicago, Mexico City (Vultr) |
| South America | São Paulo, Santiago (Vultr) |
| Africa | Johannesburg (Vultr) |
| Asia | Tel Aviv, Delhi, Mumbai, Seoul (Vultr), Singapore (Hetzner), Hong Kong, Tokyo (Leaseweb) |
| Oceania | Sydney (Leaseweb), Melbourne (Vultr) |
| Global | CacheFly CDN (nearest node) |

Each host gets up to 100 MB or 15 seconds, whichever comes first; the speed is averaged over what arrived. A host that can't be reached shows `failed`.

### CPU
[sysbench](https://github.com/akopytov/sysbench) CPU test (prime numbers up to 20000), 10 seconds on one thread and 10 seconds on all threads, in events per second. Higher is better. The results are comparable with other sysbench 1.0 runs that use the same settings, not with Geekbench scores.

### Geekbench 7 (optional)
On request, the script also runs [Geekbench 7](https://www.geekbench.com/), see [Options](#options).

## Options

Options are set as environment variables. When piping the script into bash, put the variable in front of **`bash`**, not in front of `curl`/`wget`; otherwise it never reaches the script.

| Variable | Effect |
|---|---|
| `GEEKBENCH=7` | Also run Geekbench 7.1.0 (x86_64 and ARM). |

```bash
curl -fsSL https://raw.githubusercontent.com/jacboy/sysperf/master/bench | GEEKBENCH=7 bash
```

About Geekbench:
- It's a 462 MB download and needs about **1.5 GB free disk** and **2 GB RAM**. With less, it's skipped with a message.
- The download is verified against a pinned SHA-256 checksum before anything is run.
- The free Geekbench version **uploads its result and basic system information to the public [Geekbench Browser](https://browser.geekbench.com/)**. The script prints the result link. Without `GEEKBENCH=7`, nothing is uploaded anywhere.

## Requirements

- **OS:** Debian 10 or newer, or Ubuntu 18.04 or newer.
- **Packages:** `curl`, `wget`, `jq`, `fio`, `ping` (`iputils-ping`) and `sysbench`. If any is missing, the script asks for confirmation (`[Y/n]`) and installs them with `apt-get`. Without a terminal to ask on, it stops and prints the install command instead. To install them yourself:
  ```bash
  apt-get install -y ca-certificates curl wget jq fio iputils-ping sysbench
  ```
  On Ubuntu, `sysbench` is in the `universe` repository, which is enabled on standard installations.
- **Root:** only needed if packages have to be installed. With all packages present, the script runs as a normal user.
- **Disk:** about 2 GB free in the current directory for the I/O test file, plus 1.5 GB for Geekbench if requested.
- **Runs without a terminal** too (cron, CI), just without the spinner. Install the packages beforehand in that case.

## Security and privacy

- **Nothing is left behind.** Temporary files (the I/O test file, Geekbench) go into a private directory (`.sysperf.XXXXXXXX`, mode 0700) in the current directory, which is removed when the script ends, including on Ctrl+C.
- **Interrupted downloads don't run.** The whole script is one function that's only called on the last line, so if `curl … | bash` breaks off midway, bash runs nothing.
- **All lookups use HTTPS**, and responses from the network are never executed or put into a command line.
- **Hosts the script contacts:** `ipinfo.io` (your public IP, ISP and ASN), `ipv6.icanhazip.com` (IPv6 check), the latency and speed-test hosts listed above, your distribution's package mirror if packages are missing, and `cdn.geekbench.com` / `browser.geekbench.com` only with `GEEKBENCH=7`.
- The script doesn't collect or send any data of its own.

## Example output

From a Debian 13 KVM server with 2 vCPUs in Frankfurt, run with `GEEKBENCH=7` (ISP and ASN replaced with example values; speed table shortened):

```
-----
getsysperf.com v2.0.0 -- https://github.com/jacboy/sysperf
-----
System type          : KVM
CPU model            : AMD EPYC 7702 64-Core Processor
Number of cores      : 2
CPU frequency        : 1999.999 MHz
Total size of Disk   : 40.1 GB (1.5 GB Used)
Total amount of Mem  : 3922 MB (443 MB Used)
Total amount of Swap : 0 MB (0 MB Used)
System uptime        : 0 days, 1 hour 29 min
Load average         : 0.06, 0.08, 0.27
OS                   : Debian GNU/Linux 13
Arch                 : x86_64 (64 Bit)
Kernel               : 6.12.86+deb13-cloud-amd64
ISP                  : Example ISP
ASN                  : AS64500 Example ISP
IPv6 Support         : Yes
-----
I/O bandwidth (1st run)  : 5906MB/s
I/O bandwidth (2nd run)  : 5954MB/s
I/O bandwidth (3rd run)  : 8992MB/s
Average I/O bandwidth    : 6950.7 MB/s
-----
Location                        Latency
Europe
Frankfurt                       1.316 ms
London                          17.780 ms
North America
New York                        90.268 ms
Los Angeles                     151.903 ms
South America
Sao Paulo                       194.271 ms
Santiago                        228.158 ms
Africa
Johannesburg                    186.235 ms
Asia
Mumbai                          138.547 ms
Singapore                       166.721 ms
Hong Kong                       178.183 ms
Tokyo                           254.715 ms
Oceania
Sydney                          266.864 ms
-----
Location                        Speed
Europe
Frankfurt, Leaseweb             498.5 MB/s
Nuremberg, Hetzner              385.3 MB/s
Stuttgart, BelWue               409.9 MB/s
Zurich, Init7                   295.3 MB/s
...
North America
New York, Leaseweb              31.2 MB/s
Ashburn, Hetzner                19.4 MB/s
...
South America
Sao Paulo, Vultr                14.4 MB/s
Santiago, Vultr                 7.3 MB/s
Africa
Johannesburg, Vultr             16.5 MB/s
Asia
Tel Aviv, Vultr                 30.0 MB/s
Singapore, Hetzner              16.7 MB/s
...
Oceania
Sydney, Leaseweb                5.8 MB/s
Melbourne, Vultr                10.7 MB/s
Global (nearest CDN node)
CacheFly                        418.2 MB/s
-----
CPU benchmark (sysbench, events per second, higher is better)
Single Core          : 610.30
Multi Core           : 1229.58 (2 threads)
-----
Note: Geekbench uploads the result and basic system information to the public Geekbench Browser.
Geekbench v7.1.0
Single Core          : 1290
Multi Core           : 2363
Full result          : https://browser.geekbench.com/v7/cpu/841458
-----
```

## Troubleshooting

- **A speed or latency row shows `failed`:** that host didn't answer in time or refused the download. Test hosts come and go; please open an issue if one fails consistently.
- **Results vary between runs:** far-away hosts depend on routing and the remote server's load. Run the script twice before drawing conclusions.
- **"Couldn't find […]" and the script exits:** run it as root to install the missing packages, or install them yourself (see [Requirements](#requirements)).
- **"other users can modify …" and the script exits:** run it from a directory only you or root can change, for example `cd ~`.
- **Geekbench is skipped:** check the message; it needs 1.5 GB free disk, 2 GB RAM and an x86_64 or ARM CPU.

## Donation

[Help me to keep the project alive](https://paypal.me/ianklemm)
