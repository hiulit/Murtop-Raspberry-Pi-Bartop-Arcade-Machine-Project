# Raspberry Pi Bartop Arcade Machine Project

> Work in progress

* [Checklist](#checklist)
* [Downaload RetroPie](#download-retropie)
* [Flashing the SD card with ApplePi-Baker](#flashing-the-sd-card-with-applepi-baker)
* [Setting up RetroPie](setting-up-retropie)
	* [Expanding the Filesystem](#expanding-the-filesystem)
	* [Setting up language and input](#setting-up-language-and-input)
	* [Configuring the Raspberry Pi Wi-Fi](#configuring-the-raspberry-pi-wi-fi)
* [Accessing the Raspberry Pi via SSH](#accessing-the-raspberry-pi-via-ssh)
	* [Using the Terminal](#using-the-terminal)
	* [Using Cyberduck (or any other FTP client)](#using-cyberduck-or-any-other-ftp-client)
* [Wiring the joysticks and buttons](#wiring-the-joysticks-and-buttons)
* [Setting up the arcade buttons](#setting-up-the-arcade-buttons)
* [Configuring a USB controller](#configuring-a-usb-controller)
	* [SNES controller](#snes-controller)
	* [Xbox 360 controller](#xbox-360-controller)
	* [PlayStation 3 controller](#playstation-3-controller)
* [Emulators and ROMs](#emulators-and-roms)

## Checklist

* 1 player GPIO arcade buttons &#x2713;
* 2 players GPIO arcade buttons &#x2717;
* 1 player USB controller &#x2713;
* 2 players USB controller &#x2717;

## Download RetroPie

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

### Expanding the Filesystem

* Boot the Raspberry Pi.
* Quit Emulation Station. It will take you to the command line.
* Type:

```
sudo raspi-config
```

* It will open a basic GUI. 
* Select **1 Expand Filesystem**. This will make all the SD card storage available for usage.

### Setting up language and input

* Still in the `raspi-config` screen, select **4 Internationalisation Options**.
* Here you can change your locale, timezone and keyboard input.
* When you're done, select **Finish** and reboot.

### Configuring the Raspberry Pi Wi-Fi

* Boot the Raspberry Pi with the Wi-Fi adapter plugged in.
* Quit Emulaton Station. It will take you to the command line.
* Type:

```
sudo nano /etc/network/interfaces
```

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

* When you're finished, press `ctrl + x`. This will ask you if you want to save the modified file. Press `Y` and then press `return` to save the file with the same name.
* Type:

```
sudo reboot
```

* This will reboot the Raspberry Pi.
* To check if the Wi-Fi is working, go to the command line again and type:

```
sudo ip addr show
```

* And under `wlan0` you'll find your IP.
* Or just type:

```
hostname -I
```

* It does the same thing ;)

## Accessing the Raspberry Pi via SSH

### Using the Terminal

* Open a Terminal session on your computer and type:

```
ssh pi@your.raspberrypi.ip.address
```

* It will ask you to add this address to a list of known hosts. Type `yes` and press `return`.
* It will ask you for the Raspberry Pi **password**, which by default is **raspberry**.

### Using Cyberduck (or any other FTP client)

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

*Image from [element14](http://www.element14.com/).*

![Wiring-01](img/Wiring-01.jpg)

![Wiring-02.](img/Wiring-02.jpg)

*My humble scaffold for the controller.*

## Setting up the arcade buttons

Download [Adafruit's retrogame](https://github.com/adafruit/Adafruit-Retrogame), a Raspberry Pi GPIO-to-USB utility for classic game emulators.

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

* When you're finished, press `ctrl + x`. This will ask you if you want to save the modified file. Press `Y` and then press `return` to save the file with the same name.
* Let's see if it works. Type:

```
sudo ./retrogame
```

* If you don't get any error, it's working. Press `ctrl + c` to stop the program.
* To set it up to **launch at startup**, type:

```
sudo nano /etc/rc.local
``` 

* Before the final `exit 0` line, insert this line:

```
/home/pi/Adafruit-Retrogame/retrogame &
```

* When you're finished, press `ctrl + x`. This will ask you if you want to save the modified file. Press `Y` and then press `return` to save the file with the same name.
* Reboot the Raspberry Pi. Type:

```
sudo reboot
```

## Configuring a USB controller

* Boot the Raspberry Pi.
* Quit Emulation Station. It will take you to the command line.
* Type:

```
cd RetroPie-Setup
sudo ./retropie_setup.sh
```

* It will open a basic GUI.
* Select **Option 3 Setup**
* Select **Option 317 Register RetroArch controller**
* Follow the on screen directions. It will ask you to press all the buttons on your controller.
* Just press the ones you need. Let the one you won't need to **timeout**.

### SNES controller

![SNES controller](https://cloud.githubusercontent.com/assets/10035308/7110174/0f2fdb54-e16a-11e4-8f3d-37bdca8f1ddf.png)

### Xbox 360 controller

![Xbox 360 controller](https://cloud.githubusercontent.com/assets/10035308/7110173/0f2ea784-e16a-11e4-9c6f-5fe7c594b05a.png)

### PlayStation 3 controller

![Xbox 360 controller](https://cloud.githubusercontent.com/assets/10035308/7111199/e29365ec-e179-11e4-87b4-f00685661d7e.png)

*Images from [petrockblog's RetrPie Setup's Wiki](https://github.com/petrockblog/RetroPie-Setup/wiki/RetroArch-Configuration).*

## Emulators and ROMs

* Connect to your Raspberry Pi [using CyberDuck](#using-cyberduck).
* Go to `/home/pi/RetroPie/roms/`
* Look for the emulator's folder corresponding to your ROM and copy it there.
* Reboot the Raspberry Pi. Type:

```
sudo reboot
```