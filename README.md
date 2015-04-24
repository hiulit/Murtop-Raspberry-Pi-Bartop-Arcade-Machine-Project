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
* It will ask you to configure the input (keyboard, joystick, controller, etc.) to navigate the menus. Use the keyboard for now.
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

* When you're finished, click `ctrl + x`. This will ask you if you want to save the modified file. Press `Y` and then press `return` to save the file with the same name.
* Enter `sudo reboot`. This will reboot the Raspberry Pi.
* To check if the Wi-Fi is working, go to the command line again and enter `sudo ip addr show` and under `wlan0` it will tell you your IP.
* Or you could just type `hostname -I`. It does the same thing.

## Accessing the Raspberry Pi via SSH

### Using the Terminal

* Open a Terminal session on your computer and enter `ssh pi@your.raspberrypi.ip.address`.
* It will ask you to add this address to a list of known hosts. Type `yes` and press `return`.
* It will ask you for the Raspberry Pi **password**, which by default is **raspberry**.

### Using Cyberduck

* Open [Cyberduck](https://cyberduck.io/), click **New connection**.
* Select **SFTP (SSH File Transfer Protocol)**.
* Enter the Raspberry Pi IP address in **Server**.
* Leave the port at 22.
* Enter your username (**pi** by default) and password (**raspberry** by default).
* Click **Connect**.

## Wiring the joysticks and buttons

With the Raspberry Pi B+ and Raspberry Pi 2 B+ you can use up to 26 GPIO, perfect for a 2 player bartop, including:

* 2 joysticks (8 buttons)
* 12 action buttons
* 2 players buttons
* 2 service buttons
* 2 pinball buttons.

![GPIO](img/GPIO.png)
![Wiring-01](img/Wiring-01.jpg)
![Wiring-02.](img/Wiring-02.jpg)

## Setting up the buttons

Download [Adafruit's retrogame](https://github.com/adafruit/Adafruit-Retrogame), a software that converts the GPIO into key strokes.

* Boot the Raspberry Pi.
* Quit Emulation Station. It will take you to the command line.
* Unzip `Adafruit-Retrogame.zip`.
* Connect to your Raspberry Pi [using CyberDuck](#using-cyberduck).
* Copy the `Adafruit-Retrogame` folder into `/home/pi/` on your Raspberry Pi. 
* Open a [Terminal session](#using-the-terminal) and type:

```
cd Adafruit-Retrogame
nano retrogame.c
```

* Scroll down until you see:

```
ioStandard[] = {
    // This pin/key table is used when the PiTFT isn't found
    // (using HDMI or composite instead), as with our original
    // retro gaming guide.
    // Input   Output (from /usr/include/linux/input.h)
    {  25,     KEY_LEFT     },   // Joystick (4 pins)
    {   9,     KEY_RIGHT    },
    {  10,     KEY_UP       },
    {  17,     KEY_DOWN     },
    {  23,     KEY_LEFTCTRL },   // A/Fire/jump/primary
    {   7,     KEY_LEFTALT  },   // B/Bomb/secondary
    // For credit/start/etc., use USB keyboard or add more buttons.
    {  -1,     -1           } }; // END OF LIST, DO NOT CHANGE
```
* Change it to fit.
* Now type:

```
make retrogame
```
* Then:

```
sudo nano /etc/udev/rules.d/10-retrogame.rules
```
* And copy:

```
SUBSYSTEM=="input", ATTRS{name}=="retrogame", ENV{ID_INPUT_KEYBOARD}="1"
```
* Now try that it works. Type:

```
sudo ./retrogame
```
* If you don't get any error, it's working. Press `ctrl + c` to stop the program.
* To set it up to launch at startup, type:

```
sudo nano /etc/rc.local
``` 
* Before the final “exit 0” line, insert this line:

```
/home/pi/Adafruit-Retrogame/retrogame &
```
* Reboot the Raspberry Pi.
