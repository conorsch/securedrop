Installing SecureDrop
=====================

This guide outlines the steps required to install SecureDrop 0.3.x. If you are looking to upgrade from version 0.2.1, please use the [migration scripts](/migration_scripts/0.3) we have created.

## Before you begin

When running commands or editing configuration files that include filenames, version numbers, userames, and hostnames or IP addresses, make sure it all matches your setup. This guide contains several words and phrases associated with SecureDrop that you may not be familiar with. A basic familiarity with Linux, the GNU core utilities and Bash shell is highly advantageous. It's recommended that you read our [Terminology Guide](terminology.md) once before starting and keep it open in another tab to refer back to.

You will also need the inventory of hardware items for the installation listed in our [Hardware Guide](hardware.md).

## Set up the Network Firewall

Now that you've set up your password manager, you can move on to setting up the Network Firewall. You should stay logged in to your *admin Tails USB*, but please go to our [Network Firewall Guide](network_firewall.md) for instructions for setting up the Network Firewall. When you are done, you will be sent back here to continue with the next section.

## Set up the Servers

Now that the firewall is set up, you can plug the *Application Server* and the *Monitor Server* into the firewall. If you are using a setup where there is a switch on the LAN port, plug the *Application Server* into the switch and plug the *Monitor Server* into the OPT1 port.

Install Ubuntu Server 14.04 (Trusty) on both servers. This setup is fairly easy, but please note the following:

* Since the firewall is configured to give the servers a static IP address, you will have to manually configure the network with those values.
* The hostname for the servers are, conventionally, `app` and `mon`.  Adhering to this isn't necessary, but it will make the rest of your install easier.
* The username and password for these two servers **must be the same**.

For detailed instructions on installing and configuring Ubuntu for use with SecureDrop, see our [Ubuntu Install Guide](ubuntu_config.md).

When you are done, make sure you save the following information:

* The IP address of the App Server
* The IP address of the Monitor Server
* The non-root user's name and password for the servers.

Before continuing, you'll also want to make sure you can connect to the App and Monitor servers. You should still have the Admin Workstation connected to the firewall from the firewall setup step. In the terminal, verify that you can SSH into both servers, authenticating with your password:

```sh
ssh <username>@<App IP address>
ssh <username>@<Monitor IP address>
```

Once you have verified that you can connect, continue with the installation. If you cannot connect, check the firewall logs.

## Finalizing the Installation

Some of the final configuration is included in these testing steps, so *do not skip them!*

### Test the web application and connectivity

1. SSH to both servers over Tor
 * As an admin running Tails with the proper HidServAuth values in your `/etc/torrc` file, you should be able to SSH directly to the App Server and Monitor Server.
 * Post-install you can now SSH _only_ over Tor, so use the onion URLs from app-ssh-aths and mon-ssh-aths and the user created during the Ubuntu installation i.e. `ssh <username>@m5apx3p7eazqj3fp.onion`.
2. Make sure the Source Interface is available, and that you can make a submission.
 * Do this by opening the Tor Browser and navigating to the onion URL from `app-source-ths`. Proceed through the codename generation (copy this down somewhere) and you can submit a message or attach any random unimportant file.
 * Usage of the Source Interface is covered by our [Source User Manual](source_user_manual.md).
3. Test that you can access the Document Interface, and that you can log in as the admin user you just created.
 * Open the Tor Browser and navigate to the onion URL from app-document-aths. Enter your password and two-factor authentication code to log in.
 * If you have problems logging in to the Admin/Document Interface, SSH to the App Server and restart the ntp daemon to synchronize the time: `sudo service ntp restart`. Also check that your smartphone's time is accurate and set to network time in its device settings.
4. Test replying to the test submission.
 * While logged in as an admin, you can send a reply to the test source submission you made earlier.
 * Usage of the Document Interface is covered by our [Journalist User Manual](journalist_user_manual.md).
5. Test that the source received the reply.
 * Within Tor Browser, navigate back to the app-source-ths URL and use your previous test source codename to log in (or reload the page if it's still open) and check that the reply you just made is present.
6. We highly recommend that you create persistent bookmarks for the Source and Document Interface addresses within Tor Browser.
7. Remove the test submissions you made prior to putting SecureDrop to real use. On the main Document Interface page, select all sources and click 'Delete selected'.

Once you've tested the installation and verified that everything is working, see [How to Use SecureDrop](journalist_user_manual.md).

### Additional testing

1. On each server, check that you can execute privileged commands by running `sudo su`.
2. Run `uname -r` to verify you are booted into grsecurity kernel. The string `grsec` should be in the output.
3. Check the AppArmor status on each server with `sudo aa-status`. On a production instance all profiles should be in enforce mode.
4. Check the current applied iptables rules with `iptables-save`. It should output *approximately* 50 lines.
5. You should have received an email alert from OSSEC when it first started. If not, review our [OSSEC Alerts Guide](ossec_alerts.md).

If you have any feedback on the installation process, please let us know! We're always looking for ways to improve, automate and make things easier.
