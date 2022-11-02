# How I set up my dev environment using `pyenv` on macOS

I had originally set up a VM-based environment in Ubuntu for running InvenioRDM using instructions put together by @tmorrell and @rsdoiel, but for developing code, I thought it would be better to get the latest versions of the GitHub repos and get as much running as I could directly in my native development environment (which is on macOS). Here's how I went about it.

## Basic components of my system
* macOS 10.15.6 (Catalina)
* Bash shell
* HomeBrew for most third-party software

## Software needed before proceeding

* Make sure you don't have a `~/.npmrc` file (or remove it for now)
* Install Docker: <https://docker-docs.netlify.app/docker-for-mac/install>
* Install npm (Node Version Manager): 
    ```
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    ```
* Add the following lines to your `~/.bash_profile` file at the end of the file. (If you don't have a `~/.bash_profile` file,  create it first.)
    ```
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    ```
* Install [HomeBrew](https://brew.sh) if you don't already have it:
    ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew shellenv >> ~/.bash_profile
    ```
* Install some needed software packages using HomeBrew:
    ```
    brew install postgresql
    brew install cairo
    brew install imagemagick
    brew install ghostscript
    brew install pyenv
    brew install pyenv-virtualenv
    brew install git
    ```
* Add the following to your `~/.bash_profile` file at the end of the file:
    ```
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    ```

## Add or create an SSH key to your GitHub profile

If your environment is a new machine or virtual environment, your GitHub profile may not have an ssh key for it yet, and attempts to use `git+http://...` style addresses with `pip` will fail. If that's the case, [follow the GitHub instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key) for creating and adding an SSH key to your profile.

## Setting up the Invenio environment

Start by creating a directory where you will do your work (if you haven't already) and `cd` into it. Let's say it's called "invenio". Here is an example:
```
mkdir invenio
cd invenio
```

Next, follow this recipe:
1. Exit your shell/bash, and restart your shell/bash.
2. `pyenv install 3.9.13`
3. `pyenv virtualenv 3.9.13 invenio-dev`
4. Exit your shell/bash **again**, and restart your shell/bash.
5. `pyenv activate invenio-dev`
6. Run the [associated shell script](install-req-from-github.sh). This will install all the Invenio Python packages and their dependencies from the GitHub source repositories. Note that it will take a very long time.
    * Alternatively, you can use the [`pip-freeze-2022-11-01.txt`](pip-freeze-2022-11-01.txt) file in this directory, containing the output of `pip freeze` after I did the installation on 2022-11-01 using Python 3.9.13 on a macOS 10.15 system. To use the freeze file, run `pip install -r pip-freeze-2022-11-01.txt`.
7. `nvm use 14.0.0`
8. Start Docker (using the macOS Finder).
9. `invenio-cli check-requirements --development` and check that everything is green.
10. `invenio-cli install` and check for errors.
