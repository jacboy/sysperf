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
apt install dialog ca-certificates jq curl fio wget iputils-ping
```

### Options
The CPU benchmark uses Geekbench 7 (x86_64 and ARM). It needs about 1.5 GB of free disk space while it runs; with less, Geekbench 6 (about 0.8 GB) is used instead, and with less than that the CPU benchmark is skipped. Geekbench uploads its result to the public [Geekbench Browser](https://browser.geekbench.com/).

| Variable | Effect |
|---|---|
| `SKIP_GEEKBENCH=1` | Skip the Geekbench CPU benchmark |
| `FORCE_GEEKBENCH6=1` | Use Geekbench 6 instead of Geekbench 7 |

When piping the script into bash, put the variable in front of `bash`, not `wget`:
```
wget -qO- https://raw.githubusercontent.com/iandk/sysperf/master/bench | SKIP_GEEKBENCH=1 bash
```
&nbsp;
### Donation

[Help me to keep the project alive](https://paypal.me/ianklemm)

### Sample Output
![Sample Output](sample_output.png)


