#!/usr/bin/env bash

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
# * Only works locally -- how deal with systemwide Conda installation?
# * Better try 'which' to find conda bin in _get_conda_install_dest ... ?
# ---------------------------------------------------------------------------

# ===== General =====
NAME="CEASIOMpy"

# "External" requirements to run this script
EXT_REQUIRED=( \
    wget \
    python3 \
)

HERE=$(dirname $0)
TMP_DIR=$(mktemp -d -t "CEASIOMpy_XXXXXX")
BIN_DIR="$HOME/.local/bin"

# ===== Miniconda/Conda =====
MINICONDA_INSTALL_DIR="$HOME/miniconda"
MINICONDA_INSTALL_SCRIPT="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"

CONDA_TEST_PATHS=( \
    "$HOME/anaconda3" \
    "$HOME/miniconda" \
)

CONDA_ENV_NAME="ceasiompy_${RANDOM}"

# ===== PyTornado =====
# PyTornado variables
PYTORNADO_ZIP=https://github.com/airinnova/pytornado/archive/master.zip

# ===== CEASIOMpy =====
# CEASIOMpy variables
CEASIOMPY_ZIP=https://github.com/cfsengineering/CEASIOMpy/archive/master.zip
CEASIOMPY_BIN="$BIN_DIR/ceasiompy"

function _print_section {
    echo "---------- ${@} ----------"
    echo
}

function _check_requirements {
    # Check that external programs required for installation are installed

    _print_section "Checking environment"
    for app in ${EXT_REQUIRED[@]}; do
        command -v $app >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo >&2 "'$app' is required but not found. Aborting."
            echo >&2 "Please install '$app' and try again."
            exit 1
        fi
    done
}

function _get_conda_install_dest {
    # Try to identify existing Anaconda/Miniconda installation

    for dir in ${CONDA_TEST_PATHS[@]}; do
        conda_main_bin="$dir/bin/conda"
        if [[ -f $conda_main_bin ]]; then
            echo "$dir"
            return 0
        fi
    done

    # Default installation destination
    echo $MINICONDA_INSTALL_DIR
    return 1
}

function _install_miniconda {
    # Download and install Miniconda

    _print_section "Installing Miniconda"
    conda_dir=$(_get_conda_install_dest)
    if [[ -d $conda_dir ]]; then
        echo "Path '$conda_dir' does already exist..."
        echo "Trying to use existing miniconda installation..."
    else
        wget $MINICONDA_INSTALL_SCRIPT -O miniconda.sh
        bash miniconda.sh -b -p $conda_dir
    fi

    export PATH="${conda_dir}/bin:$PATH"
    hash -r
    conda config --set always_yes yes
    conda update -q conda
    conda env create --file ../environment.yml --name "${CONDA_ENV_NAME}"

    activate_script="source ${conda_dir}/bin/activate ${CONDA_ENV_NAME}"
    eval $activate_script

    # Make CEASIOMpy executable
    echo $activate_script >$CEASIOMPY_BIN
    chmod +x $CEASIOMPY_BIN
}

function _install_ceasiompy {
    # Installer for CEASIOMpy

    _print_section "Installing CEASIOMpy"
    unzip_folder="CEASIOMpy-master"

    [[ -d $unzip_folder ]] && rm -r $unzip_folder
    wget $CEASIOMPY_ZIP -O master.zip
    unzip master.zip

    cd $unzip_folder
    pip install .

    cd ..
    rm -r $unzip_folder
    cd $HERE
}

function _install_pytornado {
    # Installer for PyTornado (external dependencies, source code has to be compiled)

    _print_section "Installing PyTornado"
    unzip_folder="pytornado-master"

    [[ -d $unzip_folder ]] && rm -r $unzip_folder
    wget $PYTORNADO_ZIP -O master.zip
    unzip master.zip

    cd $unzip_folder
    pip install numpy
    pip install .

    cd ..
    rm -r $unzip_folder
    cd $HERE
}

function main {
    _print_section "$NAME installer"
    _check_requirements
    _install_miniconda
    # Install within Conda virtual environment...
    _install_ceasiompy
    _install_pytornado

    # Clean up
    rm -r $TMP_DIR
}

main
