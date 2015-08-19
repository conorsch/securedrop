# Set up the Secure Viewing Station

The *Secure Viewing Station (SVS)* is a computer that is kept offline and only ever used together with the *offline Tails USB*. Since this machine will never touch the Internet or run an operating system other than Tails on a USB, it does not need a hard drive or network device.

We recommend that you physically remove the hard drive and networking cards, such as wireless and Bluetooth, from this machine. If you are unable to remove a card, place tape over the port or otherwise physically disable it. If you have questions about using an older machine for this purpose, please contact us at securedrop@freedom.press.

At this point, you should have created a Tails Live USB with persistence on the *offline Tails USB*. If you haven't, follow the instructions in the first half of our [Tails Guide](tails_guide.md).

Boot your *offline Tails USB* on the *Secure Viewing Station*.

After it loads, you should see a "Welcome to Tails" screen with two options. Select *Yes* to enable the persistent volume and enter your password, but do NOT click Login yet. Under 'More Options,' select *Yes* and click *Forward*.

Enter an *Administration password* for use with this specific Tails session and click *Login*. (NOTE: the *Administration password* is a one-time password. It will reset every time you shut down Tails.)

## Create a GPG key for the SecureDrop application

When a document or message is submitted to SecureDrop by a source, it is automatically encrypted with the SecureDrop Application GPG key. You will need to create that key now before you continue with the installation.

After booting up Tails, you will need to manually set the system time before you create the GPG key. To set the system time, right-click the time in the top menu bar and select *Adjust Date & Time.*

Click *Unlock* in the top-right corner of the dialog window and enter your *Administration password.* Set the correct time, region and city.

Then click *Lock*, enter your password one more time and wait for the system time to update in the top panel.

Once that's done, follow the steps below to create a GPG key.

* Open a terminal ![Terminal](/../images/terminal.png) and run `gpg --gen-key`
* When it says, `Please select what kind of key you want`, choose `(1) RSA and RSA (default)`
* When it asks, `What keysize do you want?` type **`4096`**
* When it asks, `Key is valid for?` press Enter to keep the default
* When it asks, `Is this correct?` verify that you've entered everything correctly so far, and type `y`
* For `Real name` type: `SecureDrop`
* For `Email address`, leave the field blank and press Enter
* For `Comment` type `[Your Organization's Name] SecureDrop Application GPG Key`
* Verify that everything is correct so far, and type `o` for `(O)kay`
* It will pop up a box asking you to type a passphrase, but it's safe to click okay without typing one (since your persistent volume is encrypted, this GPG key is already protected)
* Wait for your GPG key to finish generating

To manage GPG keys using the graphical interface (a program called Seahorse), click the clipboard icon ![gpgApplet](../images/gpgapplet.png) in the top right corner and select "Manage Keys". You should see the key that you just generated under "GnuPG Keys."

![My Keys](../images/install/keyring.png)

Select the key you just generated and click "File" then "Export". Save the key to the *Transfer Device* as `SecureDrop.pgp`, and make sure you change the file type from "PGP keys" to "Armored PGP keys" which can be switched right above the 'Export' button. Click the 'Export' button after switching to armored keys.

NOTE: This is the public key only.

![My Keys](../images/install/exportkey.png)
![My Keys](../images/install/exportkey2.png)

You'll need to verify the fingerprint for this new key during the `App Server` installation. Double-click on the newly generated key and change to the `Details` tab. Write down the 40 hexadecimal digits under `Fingerprint`. (Your GPG key fingerprint will be different than what's in this photo.)

![Fingerprint](../images/install/fingerprint.png)

## Import GPG keys for journalists with access to SecureDrop

While working on a story, journalists may need to transfer some documents or notes from the *Secure Viewing Station* to the journalist's work computer on the corporate network. To do this, the journalists should re-encrypt them with their own keys. If a journalist does not already have a personal GPG key, he or she can follow the same steps above to create one. The journalist should store the private key somewhere safe; the public key should be stored on the *Secure Viewing Station*.

If the journalist does have a key, transfer their public key from wherever it is located to the *Secure Viewing Station*, using the *Transfer Device*. Open the file manager ![Nautilus](../images/nautilus.png) and double-click on the public key to import it. If the public key is not importing, rename the file to end in ".asc" and try again.

![Importing Journalist GPG Keys](../images/install/importkey.png)

At this point, you are done with the *Secure Viewing Station* for now. You can shut down Tails, grab the *admin Tails USB* and move over to your regular workstation.

