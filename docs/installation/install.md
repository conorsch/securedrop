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

