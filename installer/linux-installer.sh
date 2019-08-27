#!/usr/bin/env bash

# ===== EXPERIMENTAL =====
# ===== EXPERIMENTAL =====
# ===== EXPERIMENTAL =====

# Linux installer script for CESIOMpy and its core dependencies
#
# This script will download and install Miniconda. Then a Conda virtual
# is created, and CEASIOMpy dependencies are installed.
#
# Related information:
#
# * MINICONDA:
#   - https://docs.conda.io/en/latest/miniconda.html
#
# * BASH
#   - https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
#
# Author: Aaron Dettmann

# ---------------------------------------------------------------------------
# TODO:
# * Make installer work for 32/64 bit (different Miniconda installations)
# * Make initial check that we are not already in a Conda environment
# * Make Miniconda PATH change persistent!
# * Add local executable "ceasiompy" to start up the Conda environment?
# * Downloads in temp directory
# ---------------------------------------------------------------------------

name="CEASIOMpy"
required=( \
    wget \
    python3 \
)

# Miniconda variables
miniconda_install_dest="$HOME/miniconda"
miniconda_install_script="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"

function _print_section {
    echo
    echo "---------- $1 ----------"
    echo
}

function _check_requirements {
    # Check that external prgrams are installed
    _print_section "Checking environment"
    for app in ${required[@]}; do
        command -v $app >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo >&2 "'$app' is required but not found. Aborting."
            exit 1
        fi
    done
}

function _install_miniconda {
    # Download and install Miniconda
    _print_section "Installing Miniconda"
    if [[ -d $miniconda_install_script ]]; then
        echo >&2 "Path '$miniconda_install_script' does exist. Aborting."
        exit 1
    fi

    wget $miniconda_install_script -O miniconda.sh
    bash miniconda.sh -b -p $miniconda_install_dest
}

function _install_ceasiompy {
    # Install CEASIOMpy
    _print_section "Installing $name libraries"
    cd ..
    if [[ ! -f "setup.py" ]]; then 
        echo >&2 "'setup.py' not found. Aborting."
        exit 1
    fi
    python3 setup.py install
}

function _install_pytornado {
    # Installer for PyTornado (external dependencies, source code has to be compiled)
    _print_section "Installing PyTornado"
    echo "PyTornado installer -- NOT YET IMPLEMENTED!"
}

function main {
    cd $(dirname $0)
    _print_section "$name installer"
    _check_requirements
    _install_miniconda

    # ----------
    # Setup PATH variable
    export PATH="$miniconda_install_dest/bin:$PATH"
    hash -r

    # Setup the Miniconda environment
    alias miniconda='$miniconda_install_dest/bin/conda'
    miniconda config --set always_yes yes --set changeps1 no
    miniconda update -q conda
    miniconda env create -f ../environment.yml
    source activate ceasiompy
    # ----------

    _install_ceasiompy
    _install_pytornado
}

main
