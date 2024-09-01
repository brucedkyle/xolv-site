# Store keys, API tokens, secrets using keyring

The Python [keyring](https://pypi.org/project/keyring/) library provides an easy way to access the system keyring service from python. It can be used in any application that needs password storage locally.

> [!CAUTION]
> This technique stores the password/secret in the clear on your development machine. 

## Prerequisites

- Using WSL with Ubuntu 24.04 or later (Will probably work on earlier versions)
- Conda is installed

## Install Keyring in WSL

Use the following to install **keyring** and **keyring.alt** in a virtual environment on Ubuntu:

```
conda install anaconda::keyring 
pip install keyrings.alt
```

> [!NOTE] 
> keyrings.alt is available as part of the [Tidelift Subscription](https://tidelift.com/subscription). WSL does not use the Windows Credential Manager out of the box. So you will need a thrid party solution. Other 3rd party key storage are available. See [third party backend](https://pypi.org/project/keyring/#third-party-backends).

## Set test password in Keyring

No need to create a file and check in your password use keyring to set 

```bash
keyring set system username 
```

To see your password, use

```bash
keyring get system username 
```

Alternatively, you can use Python command line. Start `python` then you can set your password interactively.

```python
>>> import keyring
>>> keyring.get_keyring()
<keyring.backends.SecretService.Keyring object at 0x7f9b9c971ba8>
>>> keyring.set_password("system", "username", "password")
>>> keyring.get_password("system", "username")
'password'
```

## Set and get password in your Jupyter Notebook



## References

- [keyring](https://pypi.org/project/keyring/)
- [keyring.alt]