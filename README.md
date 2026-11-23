\# bash-installer



A small Bash script that sets up a Python development environment.



It detects the operating system, checks that python3 and pip are available,

and installs python3 if it is missing. On Ubuntu/Debian it also installs pip

and the venv module. Jupyter Notebook is installed in a virtual environment at

`\~/.venvs/jupyter`. On macOS, the script runs `brew doctor` to check that

Homebrew is healthy.



\## Requirements



\- Ubuntu or Debian (including WSL), or macOS with Homebrew

\- Internet access

\- A user account with `sudo` rights on Linux (you will be asked for your password)



\## Usage



&#x20;   chmod +x env\_install.sh

&#x20;   ./env\_install.sh



To start Jupyter afterwards:



&#x20;   \~/.venvs/jupyter/bin/jupyter notebook

