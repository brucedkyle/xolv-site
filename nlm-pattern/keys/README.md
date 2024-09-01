# Store keys, API tokens, secrets using keyring

The Python [keyring](https://pypi.org/project/keyring/) library provides an easy way to access the system keyring service from python. It can be used in any application that needs safe password storage.

These recommended keyring backends are supported:

macOS Keychain
Freedesktop Secret Service supports many DE including GNOME (requires secretstorage)
KDE4 & KDE5 KWallet (requires dbus)
Windows Credential Locker

Other keyring implementations are available through Third-Party Backends.

## Prerequisites

- Using WSL with Ubuntu 24.04 or later (Will probably work on earlier versions)
- Conda is installed

## Install Keyring in WSL

The following is a complete transcript for installing keyring in a virtual environment on Ubuntu 16.04. No config file was used:

```
conda install anaconda::keyring
```

## Set test password in Keyring

```python
>>> import keyring
>>> keyring.get_keyring()
<keyring.backends.SecretService.Keyring object at 0x7f9b9c971ba8>
>>> keyring.set_password("system", "username", "password")
>>> keyring.get_password("system", "username")
'password'
```


```

## References

= [keyring](https://pypi.org/project/keyring/)