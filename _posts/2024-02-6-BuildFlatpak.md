# A Guide for Building Flatpak Versions of GIMP
Here's how I learned to build a Flatpak version of a [GIMP source](https://gitlab.gnome.org/GNOME/gimp) code fork, from a specified branch. In this case, the branch is called ['Imp'](https://gitlab.gnome.org/pixelmixer/gimp-plugins/-/tree/Imp?ref_type=heads), and is an **unofficial** testbed for possible GIMP features. It also serves as an **example** of how you might build your own [Flatpak version of GIMP](https://www.gimp.org/downloads/).

## Why Flatpak?
[Flatpak](https://flatpak.org/) is a software utility for packaging and running Linux applications.
Each Flatpak application is contained in its own sandboxed environment, which includes its dependencies and runtime. This isolation allows you to have different versions of the same software installed side by side without interference. Using Flatpak also provides a structured and reproducible way to compile applications.

There is a 'manifest' file, **org.gimp.GIMP.json**, in [this repository](https://github.com/script-fu/Imp), which an adapted version of [this](https://gitlab.gnome.org/GNOME/gimp/-/tree/master/build/flatpak?ref_type=heads) nightly one. It provides a way to describe the application and its environment so that it can be packaged as a Flatpak. This is also a neat way to build GIMP locally. Within the manifest, right at the end, GIMP is built from a 'source' of code. This can be the official source, or your own remote repo, or a local branch.

If you would like to take the risk of building Imp, are willing to trust a stranger on the internet, and have other security features in place, don't mind being hacked, or having your data wiped, then you can build Imp by cloning [this](https://github.com/script-fu/Imp) repository and adjusting the manifest file. It's **not** recommended by me, I do recommend playing around with the verified source code for fun and education.

## Prepare the System
If you are going to build GIMP as a Flatpak, you need to have the latest parts it needs to be assembled.  Here's a rough guide to this process for a Debian based, Linux Mint platform. It will probably be a unique process for your system, good luck.

Sourced from:
<https://gitlab.gnome.org/GNOME/gimp/tree/master/build/flatpak>
<https://developer.gimp.org/core/setup/build/linux/>

```sh
sudo apt build-dep gimp
```

Dependencies to install or update:

- flatpak
- flatpak-builder
- appstream-compose

Perhaps install these extra bits:
```sh
flatpak remote-add --user --from gnome https://nightly.gnome.org/gnome-nightly.flatpakrepo
flatpak install --user gnome org.gnome.Platform/x86_64/master org.gnome.Sdk/x86_64/master
flatpak install --user gnome org.gnome.Platform/aarch64/master org.gnome.Sdk/aarch64/master
```

## Learn About Git
This is another topic altogether, you'll need some [basic knowledge](https://script-fu.github.io/2024/02/05/Git.html) and have 'Git' installed.

## Cloning the Repository

##### Clone the Github GIMP Flatpak fork for Imp into a local folder
```sh
cd /yourfolder
git clone https://github.com/script-fu/Imp.git
```
##### Download the submodules and update them, this may not work...
```sh
git submodule update --init --recursive
git submodule update --remote --merge

```
##### Open the file _org.gimp.GIMP.json_ in a text editor, find the lines that specify the official, the verified and trustable source, the safe code
```json
"type": "git",
"url": "https://gitlab.gnome.org/GNOME/gimp.git",
"branch": "master"
```
Change to:

##### Trust me, I'm not a hacker, honest. LoTs of BAd thiNgs MiGht HaPPen
```json
"type": "git",
"url": "https://gitlab.gnome.org/pixelmixer/gimp-plugins.git",
"branch": "Imp"
```

##### Much Better, Play with the Verified Source Code Locally
```json
"type": "git",
"url": "file:///path/to/your/repo/for/building/gimp",
"branch": "YourBranch"
```

## What do the shell scripts do?
There is a script file in this repo, **build-flatpak.sh**, it builds the necessary files for installing a Flatpak version of GIMP. It downloads and stores all the parts that make up GIMP, into a folder called '.flatpak-builder', compiles them and assembles the result into a folder called 'flatpak-install'. This process can take a long while. It then installs the Flatpak on your system.

After build and installiion, start Imp by executing the script **launch-flatpak-Imp.sh**

## How to Make lots of GIMPS

Change the version at the top of **build-flatpak.sh**
```sh
export VERSION="AnyName"
```

Change the 'app ID' at the top of **org.gimp.GIMP.json**
```json
  "app-id": "org.gimp.AnyName",
```

Change the code source at the end of **org.gimp.GIMP.json**
```json
"type": "git",
"url": "https://gitlab.gnome.org/yourGitLab/yourRepo.git",
"branch": "yourBranch"
```

Or point at a local repository
```json
"type": "git",
"url": "file:///path/to/your/repo/for/building/gimp",
"branch": "yourBranch"
```

Change the 'app ID' at the top of **launch-flatpak-Imp.sh**
```sh
flatpak run org.gimp.AnyName -s
```

## Imp
Imp is coded to use a different 'workspace' folder than GIMP, to protect GIMP rc files.
The Imp version of gimprc is not compatable with GIMP, it has extra features.
You can copy your gimprc to the Imp .config location. **Do not** copy your gimprc from Imp to GIMP 2.99.

**Use at your own risk, it's unofficial, it’s not GIMP stable, not even GIMP Dev.**

## More about Imp
https://script-fu.github.io/2023/11/21/ProjectImp.html
