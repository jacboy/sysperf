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
&nbsp;
### Donation

[Help me to keep the project alive](https://paypal.me/ianklemm)

### Sample Output
![Sample Output](sample_output.png)


