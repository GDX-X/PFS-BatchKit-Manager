# PFS-BatchKit-Manager
Is a batch script that allows you to easily manage your PS2 hard drive

![image](https://user-images.githubusercontent.com/22562949/152685787-f7b0dd25-8731-4b13-aa49-e0b9e5ed09c9.png)

<details>
  <summary> <h7> <b> How to hack your PS2 hard drive </b> </h7> </summary>
   <p>
     
IMPORTANT! If you have already Formatted and installed FreeHDBoot (From HDD), you don't need to do this.                            

1) In PFS BatchKit Manager Go to `Advanced menu` > `HDD Management`
     
2) Choose option 8 `Hack your HDD To PS2 Format` `(This is only intended to be used as an entry point for the PS2.)`
     
3) After the hacking put your HDD in your PS2 and format your hard drive with wLaunchELF.      
In wLaunchELF do this `FileBrowser` > `MISC` > `HDDManager` > `Press R1` > `Format and confirm.`
     
4) Copy the contents of the !COPY_TO_USB_ROOT folder to the root of your USB drive

5) Install FreeHDBoot (From HDD).
In wLaunchELF do this `FileBrowser` > `Mass` > `APPS` > `FreeMcBoot` > `FMCBInstaller.elf` Press Circle for Launch > `Press R1` > `Install FHDB` (From HDD)

6) Your hard drive will be properly formatted and hacked after that
  ------
     
   </p>
</details>


<details>
  <summary> <h7> <b> How to install PS2 Games </b> </h7> </summary>
   <p>
     
NOTE Before installing your games, it is strongly recommended to create the `+OPL` partition
     
Copy your `.BIN/CUE` in CD Folder

Copy your `.ISO` in DVD Folder
     
In PFS BatchKit Manager Choose `Transfer PS2 Games`
     
  ------
   </p>
</details>


<details>
  <summary> <h7> <b> How to install PS1 Games </b> </h7> </summary>
   <p>
     
Copy your .BIN/CUE in POPS Folder

1) Transfer POPS-Binaries
2) Go to the `Advanced menu` > `Conversion`
3) Choose Convert .BIN/CUE To .VCD
4) Create `__.POPS` Partition `Choose an appropriate size according to the number of games you want to install`
5) Transfer your .VCD
     
  ------
   </p>
</details>


<details>
  <summary> <h7> <b> How to Setup HDD-OSD </b> </h7> </summary>
   <p>

NOTE: You need to find the correct files to be able to install the HDD-OSD.                  
for copyright reasons I cannot provide you with these files `hddosd-1.10-u.7z`  
     
1) Install FreeHDBoot (From HDD)
2) Create `+OPL` Partition
3) Install HDD-OSD
4) Inject the `OPL-Launcher` (For PS2 games you want to run from HDD-OSD)
     
  ------
   </p>
</details>

<details>
  <summary> <h7> <b> How to Setup HDD Network </b> </h7> </summary>
   <p>

1) Go to `Advanced menu` > `HDDManagement` > `NBD Server`

2) Choose `Install/Update NBD Driver` (You will be asked to restart the computer to activate test mode)

3) After restarting Repeat steps 1 and 2 You will not need to restart your computer this time

4) A window should warn you if you want to install the driver Confirm install the driver                              
(If the driver refuses to install, you will have to go into your computer's bios and disable Secureboot UEFI)

5) After installing the driver Turn on your PS2 go to OPL (Compatible NBD [__Download Here__](https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.7z)) 
     
6) In OPL Go to `Settings` > `Enable Write Operation` `ON` Select `OK` For save
   
7) Still in OPL Go to `Network Settings` > `IP Address Type` Select `Static` and put `192.168.0.21` Select `OK` > `Start NBD server`                           
(this will depend on your devices connected to your local network change the last number if it interferes with another device)

8) Now In PFS Batchkit Manager Go to `Advanced menu` > `HDDManagement` > `NBD Server`

9) Select `Mount Device` And type the IP Address of your NBD server that you have configured in OPL                             
(From the time you start the NBD server, you have approximately 20-30 seconds to enter the IP address into PFS Batchkit Manager.)
     
10) Normally if all goes well, your hard drive should be connected to your pc as local hard drive                    
(You can check in `Show list of mounted devices`)

  ------
   </p>
</details>


# FAQ


<details>
  <summary> <h7> <b> What is <code>TROJAN_7.BIN</code>  </b> </h7> </summary>
   <p>
     
It's a patch for PS1 games that fixes some bugs.
     
you can find it [__here__](https://www.psx-place.com/threads/popstarter.19139/page-8#post-298564)
     
  ------
     
   </p>
</details>


<details>
  <summary> <h7> <b> Can use it without internet ?  </b> </h7> </summary>
   <p>

  Yes you can use it without internet

  ------
   </p>
</details>

<details>
  <summary> <h7> <b> I'm stuck during file transfer </code>  </b> </h7> </summary>
   <p>
     
If you get stuck during file transfer, it means your partition is full or corrupted
     
  ------
     
   </p>
</details>


<details>
  <summary> <h7> <b> Screenshots </b> </h7> </summary>
   <p>

![image](https://user-images.githubusercontent.com/22562949/152686188-325fe89d-c02c-4908-a517-2751774fcc9f.png)
     
![image](https://user-images.githubusercontent.com/22562949/152685686-1a12ed0d-93fc-4eeb-8971-28fb0db95152.png)
     
![image](https://user-images.githubusercontent.com/22562949/152686202-ed445546-2d1a-4756-a458-ac84f1377a57.png)

  ------
   </p>
</details>

