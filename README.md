## getsysperf.com
A simple benchmark script to test your Disk, Network and CPU performance on Debian/ Ubuntu based systems.     
&nbsp;
### Usage
You just have to run the command below.
```
wget -qO- https://raw.githubusercontent.com/iandk/sysperf/master/bench | bash
```

If you'd rather read the script before running it:
```
wget https://raw.githubusercontent.com/iandk/sysperf/master/bench
less bench
bash bench
```

Root is only needed if the required packages below are missing and the script should install them.
    
If you don't get an output when running the script, make sure the following packages are installed
```
apt install dialog ca-certificates jq curl fio wget iputils-ping sysbench
```

### CPU benchmark
By default the CPU is benchmarked with [sysbench](https://github.com/akopytov/sysbench) from your distribution's own packages: a small download, and nothing is uploaded anywhere.

Optionally, the script can also run [Geekbench](https://www.geekbench.com/) (x86_64 and ARM). It is only downloaded when you ask for it:

| Variable | Effect |
|---|---|
| `GEEKBENCH=7` | Also run Geekbench 7 (462 MB download, needs ~1.5 GB free disk; falls back to Geekbench 6 with less) |
| `GEEKBENCH=6` | Also run Geekbench 6 (218 MB download, needs ~0.8 GB free disk) |

The free Geekbench versions upload their result to the public [Geekbench Browser](https://browser.geekbench.com/).

When piping the script into bash, put the variable in front of `bash`, not `wget`:
```
wget -qO- https://raw.githubusercontent.com/iandk/sysperf/master/bench | GEEKBENCH=7 bash
```
&nbsp;
### Donation

[Help me to keep the project alive](https://paypal.me/ianklemm)

### Sample Output
![Sample Output](sample_output.png)


