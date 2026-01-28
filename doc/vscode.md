# VS Code


## Notes

* VS Code Server download
  * By default the Remote SSH extension will download VS Code Server on the remote host and fail back to downloading VS Code Server locally and transferring it remotely once a connection is established. (Setting : `remote.SSH.localServerDownload`)
  * https://code.visualstudio.com/docs/remote/faq#_what-are-the-connectivity-requirements-for-vs-code-server

* VS Code Remote SSH to older linux system
  * linux minimal requirements : kernel >= 4.18, glibc >=2.28, libstdc++ >= 3.4.25, binutils >= 2.29
  * links
    * https://code.visualstudio.com/docs/remote/faq#_can-i-run-vs-code-server-on-older-linux-distributions 
    * https://github.com/microsoft/vscode/issues/238873

* How-To remote SSH to a linux glibc 2.17 (tested on RHEL7)
  * Install patchelf (patchelf >=v0.18.x) (https://github.com/NixOS/patchelf)
  * Provide a sysroot with glibc 2.28
    * Build using crosstool-NG and configs from https://github.com/microsoft/vscode-linux-build-agent
    * OR Extract a precompiled sysroot from https://github.com/microsoft/vscode-linux-build-agent/releases
  * 
VSCODE_SERVER_CUSTOM_GLIBC_LINKER : path to the dynamic linker (ld-linux.so) in the sysroot (used for --set-interpreter option with patchelf)
VSCODE_SERVER_CUSTOM_GLIBC_PATH : path to the library locations in the sysroot (used as --set-rpath option with patchelf)
VSCODE_SERVER_PATCHELF_PATH : path to the patchelf binary on the remote host 

