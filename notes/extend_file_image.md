# Dealing with low disk space on your persistent file system

You might find that the 128 MB we assigned earlier for your persistent file system turn out to be too small.  You can fix this by making the file larger without deleting your customizations.

Plug the USB drive in a computer that has Linux, but do not boot from it.  Mount the Windows partition on your USB drive.  Become an administrator to run the subsequent steps.
Create an empty temporary file using the dd command:
```
dd if=/dev/zero of=/tmp/tempfile bs=1M count=256
```
This example command creates a 256 MB file.  That's a bit small, but it should suffice to install a few programs -- like multimedia codecs and VLC in case you want to roll around with an all-purpose multimedia machine.
Now tack that file onto the end of your casper-rw persistent file  You can do that with the command:
```
cat /tmp/tempfile >> /media/USBDRIVE/casper-rw
```
Finally, enlarge the file system to encompass the added disk space:
```
e2fsck -f /media/USBDRIVE/casper-rw
resize2fs /media/USBDRIVE/casper-rw
```
Now unmount your USB drive.