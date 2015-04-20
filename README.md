# Raspberry Pi Bartop Arcade Machine Project

> Work in progress

* Download [RetroPie Project SD-card Image for Raspberry Pi 1](http://blog.petrockblock.com/retropie/retropie-downloads/download-info/retropie-sd-card-image-for-rpi-version-1/) or [RetroPie Project SD-card Image for Raspberry Pi 2](http://blog.petrockblock.com/retropie/retropie-downloads/download-info/retropie-sd-card-image-for-rpi-version-2/).
* Unzip the image.
* Flash de image into an SD card using [ApplePi-Baker](http://www.tweaking4all.com/hardware/raspberry-pi/macosx-apple-pi-baker/) or [RPi-sd card builder](https://alltheware.wordpress.com/2012/12/11/easiest-way-sd-card-setup/).
* [More info](http://elinux.org/RPi_Easy_SD_Card_Setup#Flashing_the_SD_card_using_Mac_OS_X) about flashing sd cards on OSX.

## Flashing the SD card with ApplePi-Baker

> Using another app like this one should be pretty similar to use.

* Select the SD card. ![Select the SD card.](img/ApplePi-Baker-01.png)
* Select the `.img` you just downloaded. ![Select the .img.](img/ApplePi-Baker-02.png)
* Restore backup. ![Restore backup.](img/ApplePi-Baker-03.png)
* Finished! :D ![Finished! :D](img/ApplePi-Baker-04.png)
* Safely eject the SD card using the **Utility Disks** app.

## Setting up RetroPie

* Insert the recently flashed SD card into the Raspberry Pi and power it up.
* It will boot up directly into [EmulationStation](http://www.emulationstation.org/) (the graphical front-end emulator).
* It will ask you to configure the input (keyboard, joystick, controller, etc.) to navigate the menus.
* But, **before proceeding any further**, let's back up a little and configure the Wi-Fi and other settings.

## Expanding the Filesystem

* Boot the Raspberry Pi.
* Quit Emulation Station. It will take you to the command line.
* Enter `sudo raspi-config`. 
* Select `1 Expand Filesystem`. This will make all the SD card storage available for usage.

## Setting up language and input

* Still in the `raspi-config` screen, select `4 Internationalisation Options`.
* Here you can change your locale, timezone and keyboard input.
* When you're done, select `Finish` and reboot.

## Configuring the Raspberry Pi Wi-Fi

* Boot the Raspberry Pi with the Wi-Fi adapter plugged in.
* Quit Emulaton Station. It will take you to the command line.
* Enter `sudo nano /etc/network/interfaces`.
* Modify the file so it looks like this one:

```
auto lo
 
iface lo inet loopback
iface eth0 inet dhcp


auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
        wpa-ssid "ssid"
        wpa-psk "password"
```

* When you're finished, click `ctrl + x`. This will ask you if you want to save the modified file. Press `Y` and then `return` to save the file with the same name.
* Enter `sudo reboot`. This will reboot the Raspberry Pi.
* To check if the Wi-Fi is working, go to the command line again and enter `sudo ip addr show` and under `wlan0` it will tell you your IP.

## Accessing the Raspberry Pi via SSH

### Using the Terminal

* Open a Terminal session on your computer and enter `ssh pi@your.raspberrypi.ip.address`.
* It will ask you to add this address to a list of known hosts. Say `yes`.
* It will ask you for the Raspberry Pi **password**, which by default is **raspberry**.

### Using Cyberduck

* Open [Cyberduck](https://cyberduck.io/), click **New connection**.
* Select **SFTP (SSH File Transfer Protocol)**.
* Enter the Raspberry Pi IP address in **Server**.
* Leave the port at 22.
* Enter your username (by default **pi**) and password (by default **raspberry**).
* Connect.

## Wiring the joysticks and buttons

![GPIO](img/GPIO.png)
![Wiring-01](img/Wiring-01.jpg)
![Wiring-02.](img/Wiring-02.jpg)


