# kesire
`kesire.sh` is a shell script designed to simplify the process of generating a private key and a Certificate Signing Request (CSR) using OpenSSL. The script's name is derived from **ke**y **si**gning **re**quest, as that is its primary purpose.

By simply running the script, users can quickly generate a private key and a CSR with minimal input, making it easy to request a certificate from a Certificate Authority.

The script is compatible with both Linux and macOS operating systems and requires OpenSSL to be installed on the user's machine.

## usage
Running kesire is as simple as typing `./kesire.sh` in a shell.

The script can be used in both **interactive** and **non-interactive** modes.

### interactive mode
When using the script in interactive mode, it will prompt you for the necessary information, such as the Common Name (CN), Organization (O), and Country (C) for the certificate. Once the information is entered, kesire.sh will create the key and CSR files for you to use in your SSL/TLS setup.


### non-interactive mode
To use the script in non-interactive mode, you need to edit the variables section of the script. This section contains self-explaining variables such as the key length, the common name, and the organization name, among others. By modifying these variables, you can customize the certificate request according to your needs without having to interact with the script during its execution. This feature makes kesire.sh a useful tool for automating the generation of certificate requests.
