# [SSH Remote Server Setup](https://roadmap.sh/projects/ssh-remote-server-setup/solutions?fl=0)

## Secure Login

### Remote server

we need to install OpenSSH in the remote server:
`sudo apt install openssh-server`

Then to harden it we will also install ufw

```bash
sudo apt install ufw
sudo ufw allow ssh

```

We can get the ip address with

```bash
ip addr
```

I can see the private intranet ip `192.168.2.148`

### Local machine

Test the connection by:
`ssh <username>@<ip_address>`

Generate ssh-key for secure access:

```bash
cd ~/.ssh
ssh-keygen -t ed25519 -C "my-remote-server"
# then copy the public to the remote server
ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@<ip_address>
```

( **Remote Server** )
Once the key has been copied, we need to run a few "chmod" in our remote server:

```sh
# 1. Your home directory must NOT be writable by others
chmod 755 ~

# 2. Your .ssh folder must be private to you only (700)
chmod 700 ~/.ssh

# 3. Your authorized_keys file must be private to you only (600)
chmod 600 ~/.ssh/authorized_keys
```

We can test the secure login without using password with:

```bash
ssh -i ~/.ssh/id_ed25519 <username>@<ip_address>
```

If we successfully logged in without using a password we can edit "~/.ssh/config" by adding:

```bash
Host lab
    HostName <ip_address>
    User your_username
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Finally, test it out again by:

```bash
ssh <username>@lab
```

## Locking down remote server

### Configuring ssh

### Remote Server

```sh
vi  /etc/ssh/sshd_config
# inside the file, we will change the following lines:
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
UsePAM no

# finally, we need to restart the ssh service
sudo systemctl restart ssh
```

## Set up Fail2Ban

```sh
sudo apt install fail2ban

# make sure it is running.
sudo systemctl status fail2ban
```

### fail2ban configuration

```sh
# create a local copy of the default configuration file
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# update the local verison
vi /etc/fail2ban/jail.local
# in the file

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 1h
bantime  = 24h

# whielist your ip address to avoid being locked out
ignoreip = 127.0.0.1/8 ::1 100.64.0.0/10 192.168.2.0/24

# finally restart the fail2ban service to apply the changes
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
```

---

### Test fail2ban

### Temporarily Remove your Whitelist

Open your config file on the Debian server:
`sudo nano /etc/fail2ban/jail.local`

Find the `ignoreip` line and **put a `#` at the start of it** to comment it out.
Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`), then reload:
`sudo fail2ban-client reload`

### The "Attack" (From your Mac)

Run this 3 or 4 times (or whatever your `maxretry` count is):
`ssh non-existent-user@<ip_address>`

On the last attempt, the terminal should hang or say `Connection refused`.

### Verify the Ban (On the Server)

`sudo fail2ban-client status sshd`

You should see `1`

### The Jailbreak (Unban Yourself)

```bash
sudo fail2ban-client set sshd unbanip <ip_address>
```

### Restore your Safety Net

1. `sudo nano /etc/fail2ban/jail.local`
2. Remove the `#` from the `ignoreip` line.
3. `sudo fail2ban-client reload`
