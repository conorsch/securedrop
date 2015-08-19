# Set up Tails USB sticks

Before installing the SecureDrop application, the first thing you need to do is set up several USB sticks with the Tails operating system. Tails is a privacy-enhancing live operating system that runs on removable media, such as a DVD or a USB stick. It sends all your Internet traffic through Tor, does not touch your computer's hard drive, and securely wipes unsaved work on shutdown.

You'll need to install Tails onto at least four USB sticks and enable persistent storage, which is an encrypted volume that allows you to save information even when Tails securely wipes everything else:

1. *offline Tails USB*

2. *admin Tails USB*

3. *journalist Tails USB*.

4. *long-term storage Tails USB*

You will need one Tails USB for each journalist, so if you have more than one journalist checking SecureDrop, you'll need to create even more. It's a good idea to label or color-code these in order to tell them apart.

## Installing Tails

We recommend creating an initial Tails Live DVD or USB, and then using that to create additional Tails Live USBs with the *Tails Installer*, a special program that is only available from inside Tails. *You will only be able to create persistent volumes on USB sticks that had Tails installed via the Tails Installer*.

The [Tails website](https://tails.boum.org/) has detailed and up-to-date instructions on how to download and verify Tails, and how to create a bootable Tails USB stick. Follow the instructions at these links and then return to this page:

* [Download and verify the Tails .iso](https://tails.boum.org/download/index.en.html)
* [Install onto a USB stick or SD card](https://tails.boum.org/doc/first_steps/installation/index.en.html)

Note that this process will take some time because once you have one copy of Tails, you have to create each additional Tails USB, shut down, and boot into each one to complete the next step.

Also, you should be aware that Tails doesn't always completely shut down and reboot properly when you click "restart", so if you notice a signficant delay, you may have to manually power off and restart your computer for it to work properly.

## Enabling Persistence Storage on Tails

Creating an encrypted persistent volume will allow you to securely save information and settings in the free space that is left on your Tails USB. This information will remain available to you even if you reboot Tails. (Tails securely erases all other data on every shutdown.)

You will need to create a persistent storage on each Tails USB, with a unique password for each.

Please use the instructions on the [Tails website](https://tails.boum.org/doc/first_steps/persistence/index.en.html) to make the persistent volume on each Tails USB stick you create.

When creating the persistence volume, you will be asked to select from a list of features, such as 'Personal Data'. We recommend that you enable **all** features.

Some other things to keep in mind:

* You will want to create a persistent volume for all three main Tails USBs: the *offline Tails USB*, the *admin Tails USB*, and the *journalist Tails USB*.

* The admin and the journalist should create separate passwords for their own USBs.

* Only the journalist should have access to the *offline Tails USB password*, though during the initial installation, often the admin will create their own password to facilitate setup and then the journalist can change it afterwards.

* Unlike many of the other passphrases for SecureDrop, the persistence volume passwords must be remembered by the admin and journalist. So after creating each passphrase, you should write it down until you can memorize it, and then destroy the paper you wrote it on.

NOTE: Make sure that you never use the *offline Tails USB* on a computer connected to the Internet or a local network. This USB will be used on the air-gapped *Secure Viewing Station* only.

