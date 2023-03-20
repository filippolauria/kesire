# kesire
`kesire` is a simple shell script (~200 lines of code) designed to simplify the process of generating a private key and a Certificate Signing Request (CSR) using OpenSSL. The script's name is derived from **ke**y **si**gning **re**quest, as that is its primary purpose.

By simply running the script, users can quickly generate a private key and a CSR with minimal input, making it easy to request a certificate from a Certificate Authority.

The script is compatible with both Linux and macOS operating systems and requires OpenSSL to be installed on the user's machine.

## usage
Running kesire is as simple as typing `./kesire.sh` in a shell.

The script can be used in both **interactive** and **non-interactive** modes. After running `kesire`, two (or three) files with the chosen Common Name (CN) as a prefix will be produced. It is important to note that if other files with the same name prefix already exist in the same directory where the script is run, they will be overwritten by the newly generated files.

Therefore, **it is recommended to either run `kesire` in an empty directory or use a unique CN for each new private key and certificate signing request**.

### interactive mode
In interactive mode, the script prompts you for the necessary information, such as the Common Name (CN), Organization (O), and Country (C) for the certificate. After you enter the information, `kesire` creates the key and CSR files for you.

Here it is shown how to get and use `kesire` for generating a key and a CSR for the example domain `example.xyz`:
```bash
mkdir example.xyz && cd example.xyz && \
wget https://raw.githubusercontent.com/filippolauria/kesire/main/kesire.sh && \
chmod +x kesire.sh && ./kesire.sh
```

### non-interactive mode
In non-interactive mode, you can customize the certificate request by editing the script's variables section. This section, located at the beginning of the script ([lines 45 through 80](https://github.com/filippolauria/kesire/blob/main/kesire.sh#L45-L80)), includes variables such as the key length, the common name, organization name, and others.

By using a text editor you can modify these variables and customize the certificate request according to your needs without having to interact with the script during its execution. This feature makes `kesire` a useful tool for automating the generation of certificate requests.

Alternatively, you can use the `sed` tool to modify the script in place and automate the editing process. For example, you can use the following command to download, modify and execute the script for generating a key and a CSR for the example domain `example.xyz`:

```bash
mkdir example.xyz && cd example.xyz && \
wget https://raw.githubusercontent.com/filippolauria/kesire/main/kesire.sh && \
export S=45 E=80 && \
sed -Ei "${S},${E}s/^ACCEPT_DISCLAIMER=.*/ACCEPT_DISCLAIMER='yes'/" kesire.sh && \
sed -Ei "${S},${E}s/^COUNTRY_CODE=.*/COUNTRY_CODE='IT'/" kesire.sh && \
sed -Ei "${S},${E}s/^STATE_OR_PROVINCE=.*/STATE_OR_PROVINCE='Lazio'/" kesire.sh && \
sed -Ei "${S},${E}s/^LOCALITY=.*/LOCALITY='Rome'/" kesire.sh && \
sed -Ei "${S},${E}s/^ORGANIZATION=.*/ORGANIZATION='My Organization'/" kesire.sh && \
sed -Ei "${S},${E}s/^ORGANIZATIONAL_UNIT=.*/ORGANIZATIONAL_UNIT='ICT Unit'/" kesire.sh && \
sed -Ei "${S},${E}s/^EMAIL=.*/EMAIL='myemail@example.xyz'/" kesire.sh && \
sed -Ei "${S},${E}s/^CN=.*/CN='example.xyz'/" kesire.sh && \
sed -Ei "${S},${E}s/^USE_ALT_NAMES=.*/USE_ALT_NAMES='yes'/" kesire.sh && \
sed -Ei "${S},${E}s/^ALT_NAMES=.*/ALT_NAMES='fqdn1.example.xyz, fqdn2.example.xyz, fqdn3.example.xyz'/" kesire.sh && \
sed -Ei "${S},${E}s/^ENCRYPT_KEY=.*/ENCRYPT_KEY='no'/" kesire.sh && \
unset S E && \
chmod +x kesire.sh && ./kesire.sh
```

Keep in mind that, since the script is modified *in place*, **it's important to use a new copy of the script for every new private key and CSR you generate**.
