---
title: "Convert OnePlus 12 From ColorOS to OxygenOS"
date: 2024-02-04T22:03:39+03:00
draft: false
---

# How to convert OnePlus 12 from ColorOS to OxygenOS using Linux
## Intro
Somehow I decided to order a new phone from China. At the same time, I missed the moment to explore how problematic this option is.

As a result, I received a phone with the ColorOS operating system, which is designed for the Chinese region.

The seller wrote to me after receiving the phone that it could be blocked in case of an attempt to update it. There is actually a risk of blocking, but not as a result of an update, but if you insert a SIM card from another country other than China into the phone.

Fortunately, we managed to find enthusiasts on the web who somehow got the global firmware version for the phone. The main problem with all the techniques was that they were designed for Windows users. I've been a Linux user and a bit of a macOS user for quite some time now.

You can learn more about other techniques at the links below, but I will focus on how to flash the phone using Linux OS.

## References
- [How to Unbrick](https://xdaforums.com/t/oneplus-12-flash-file-stock-rom-edl-flash-file.4653536/post-89309932)
- [Unlock Bootloader](https://xdaforums.com/t/how-to-unlock-bootloader.4653170/)
- [Youtube: OnePlus 12 Switch From ColorOS To Global OxygenOS](https://www.youtube.com/watch?v=gl-tY6ocig4&t=1s)
- [How to convert from ColorOS to Global](https://xdaforums.com/t/how-to-convert-from-coloros-to-global-us-india-on-chinese-oneplus-12.4653255/)

## How To
### Preparation
#### Linux
1. Install android-tools: `pacman -S android-tools`

#### Phone
##### Developer Mode
Go to:
- Settings
  - About device
    - Version
      - Tap on Version number 7 times to enable developer mode

##### Enable USB Debug
- Settings
  - Additional settings
    - Developer Options
      1. Enable OEM unlocking
      2. Enable USB debugging

##### Add a computer to the trusted list
1. start adb server on Linux: `adb start-server`
	- it may be necessary to execute the command via sudo
2. connect phone to the Linux with cable
3. check your phone's screen
	- chose file transfer mode
	- on prompt "Allow USB debugging?" check "Always allow from this computer" and press "OK"
	- type `adb devices` to see if phone is visible for system

##### Unlock bootloader
1. type `adb reboot bootloader`
2. phone will be rebooted to fastboot
3. see if phone is visible for Linux: `fastboot devices`
4. `fastboot flashing unlock`
5. use volume up/down buttons to select **unlock bootloader** then press **power** button
6. **this will wipe phone completely**

### Flash Script

Next you can see bash script which one was rewritten from bat file that [can be found here](https://xdaforums.com/t/how-to-convert-from-coloros-to-global-us-india-on-chinese-oneplus-12.4653255/).
Save it as `flash.sh`.

```sh
# Set terminal title
echo -ne "\033]0;FTH PHONE 1902\007"

# Header
echo "**********************************************************************"
echo "             OP12_CONVERT_GLOBAL_CPH2581GDPR_11_14.0.0.232"
echo "                     FTH PHONE 1902"
echo

# Change to the directory where the script resides
cd "$(dirname "$0")" || exit

# Set fastboot command
fastboot="/usr/bin/fastboot"

# Check if fastboot exists
if [[ ! -f "$fastboot" ]]; then
    echo "$fastboot not found."
    exit 1
fi

file="vendor_boot"

# Start flashing message
echo "************************      START FLASH     ************************"
echo "*******************      REBOOT FASTBOOTD     *******************"

$fastboot -w # Wipe userdata
$fastboot reboot bootloader

$fastboot -aa # set active slot A
$fastboot reboot fastboot

read -rp "Press enter to continue..."

# Flash all img files in FTH directory
for image in FTH/*.img; do
    echo "FTH flashing $(basename "$image" .img)"
    $fastboot flash "$(basename "$image" .img)" "$image"
done

echo "********************** FTH FLASHING **************************"
if [ -f "FTH/${file}.zip" ]; then
    echo
    # Assuming rar is the equivalent command for WinRAR on Linux
    rar x -p"$password" "FTH/${file}.zip" "FTH/"
    echo "****************** WELCOME TO FTH *********************"
    $fastboot flash "$file" "FTH/${file}.img"
    echo "*********************** FASTBOOT AGAIN ***************************"
    rm -f "FTH/${file}.img"
fi

read -rp "Press enter to continue..."
$fastboot reboot fastboot

echo "**************************** FORMAT DATA ******************************"

read -rp "Press enter to continue..."
$fastboot -w

read -rp "Press enter to continue..."
$fastboot reboot bootloader
$fastboot flashing lock

echo "Press the 'volume down' button to 'lock the bootloader'"
echo "**********************************************************************"
echo
echo "Ncphone:"
echo "FTH:"
echo "Canuckknarf:"
echo
echo
echo
echo "**********************************************************************"
echo "Select ENGLISH"
echo "FORMAT DATA - ENTER CODE"
```

Unpack the firmware of your choice:
```sh
mkdir "FTH - CPH2581. Global"
unzip "FTH - CPH2581. Global.zip -d FTH - CPH2581. Global"
```

Make a symlink pointing to the folder:

```sh
ln -s "FTH - CPH2581. Global" FTH
ls -l

FTH -> 'FTH - CPH2581. Global'/
'FTH - CPH2581. Global'/
```

### Flash

1. Boot phone into fastboot mode
	- Disconnect phone from PC
	- Turn the phone off
	- Hold power and volume down
3. Go to folder with `flash.sh` file and FTL folder/symlink
4. Run script and follow prompt: `bash ./flash.sh`
5. After phone boot, turn it off
6. Boot into fastboot holding power and volume down
7. Go into recovery mode
8. **Format data**
9. Phone will reboot and load into OxygenOS
10. Turn the phone off
11. Boot into fastboot holding power and volume down
12. Type `fastboot flashing lock`
13. All done
