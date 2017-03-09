# xHyve + ServeD marriage


## Requirements:

0. macOS - 10.11+, (xHyve relies on Hypervisor framework, specific to macOS).
1. OpenZFS for OSX v1.6+, [available here](https://openzfsonosx.org/wiki/Downloads).


## Create data disk:

ZFS pool on my workstation, looks like this:

```
⇢ zpool list
NAME     SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
Studio   952G   746G   206G         -    36%    78%  1.10x  ONLINE  -
```

`Studio` pool, contains `VMs` dataset (created earlier, by just: `zfs create Studio/VMs`)

⇢ zfs list Studio/VMs
NAME         USED  AVAIL  REFER  MOUNTPOINT
Studio/VMs  65.9G   176G  57.0G  /Studio/VMs
```

This dataset will be used to store zvol for our virtual machines. Now create 50GiB zvol device like this:

```
zfs create -sV 50g Studio/VMs/xhyve-1.zvol
```

NOTE: If macOS screams about uninitialized disk, click ignore. It doesn't affect process here. Later please use this solution: https://openzfsonosx.org/wiki/Suppressing_the_annoying_pop-up, to get rid of that popup.

In my case all I had to do this to get rid of it:

```
sudo gdisk /dev/rdisk3
p # to see partitions, by default there will be 1 and 2
t # change partition type
1 # of first partition of rdisk3
6A898CC3-1DD2-11B2-99A6-080020736631 # with this UUID
w # write changes, sync
y # and… no more popups!
```


After successful zvol creation, a virtual device will be assigned to it automatically. To find out name of the device try this:

```
ioreg -trn "ZVOL Studio/VMs/xhyve-1.zvol Media" | grep "BSD Name"
```

to find out assigned N of `/dev/rdiskN`.

Now edit bin/boot.sh file and replace `/dev/rdisk3` by your device name. Note that ioreg said "/dev/diskN", yet we used /dev/rdiskN" in bin/boot.sh.

Next - download most recent installer img from [official HardenedBSD site](http://installer.hardenedbsd.org/hardened_11_stable_master-LAST/). Copy absolute path to unpacked img file on disk.

Boot installer:

```
bin/boot_installer.sh
```

Complete the standard installation process. In my case - I picked ZFS auto guided installation, which means I have ZFS zvol under ZFS on host machine. After installation process it's nothing else but:

```
bin/boot.sh
```

To boot from your new VM. To boot continuous boot mode, do:

```
bin/boot_continuous.sh
```



## License

BSD / MIT compliant.

