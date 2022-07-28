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
* Add the following to your `~/.bashrc` file at the end of the file. (If you don't have a `~/.bashrc` file,  create it first.)
    ```
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    ```
* Install [HomeBrew](https://brew.sh) if you don't already have it:
    ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
* Install some needed software packages using HomeBrew:
    ```
    brew install cairo
    brew install imagemagick
    brew install pyenv
    brew install pyenv-virtualenv
    brew install git
    ```
* Add the following to your `~/.bashrc` file at the end of the file:
    ```
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    ```

## Setting up Invenio environment

1. Exit your shell/bash, and restart your shell/bash.
2. `pyenv install 3.9.13`
3. `pyenv virtualenv 3.9.13 invenio-dev`
4. Exit your shell/bash **again**, and restart your shell/bash.
5. `pyenv activate invenio-dev`
6. Run the installation script. This will install all the Invenio Python packages and their dependencies should be installed in the Python virtual environment.
7. `nvm use 14.0.0`
8. Start Docker (using the macOS Finder).
9. `invenio-cli check-requirements --development` 

The checks from the last step should come back all green.
