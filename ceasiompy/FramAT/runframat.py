"""
CEASIOMpy: Conceptual Aircraft Design Software

Developed by CFS ENGINEERING, 1015 Lausanne, Switzerland

This is a wrapper module for FramAT. FramAT allows to perform 3D beam FEM.
Note that FramAT is being developed in a separate repository on Github.
For installation guides and general documentation refer to:

* https://github.com/airinnova/framat

Please report any issues with FramAT or this wrapper here:

* https://github.com/airinnova/framat/issues

Python version: >=3.6

| Author: Aaron Dettmann
| Creation: 2019-08-26
| Last modifiction: 2019-08-26
"""

import os
from importlib import import_module

from ceasiompy.utils.ceasiomlogger import get_logger
from ceasiompy.utils.moduleinterfaces import check_cpacs_input_requirements
from ceasiompy.ModuleTemplate.__specs__ import cpacs_inout

log = get_logger(__file__.split('.')[0])

# ===== Paths =====
DIR_MODULE = os.path.dirname(os.path.abspath(__file__))

if __name__ == '__main__':
    log.info("Running FramAT...")

    try:
        framat = import_module('framat.stdfun')
    except ModuleNotFoundError:
        err_msg = """\n
        | FramAT was not found. CEASIOMpy cannot run an analysis.
        | Make sure that FramAT is correctly installed. Please refer to:
        |
        | * https://github.com/airinnova/framat
        """
        log.error(err_msg)
        raise ModuleNotFoundError(err_msg)

    # ===== Setup =====
    cpacs_in_path = DIR_MODULE + '/ToolInput/ToolInput.xml'
    cpacs_out_path = DIR_MODULE + '/ToolOutput/ToolOutput.xml'
    # check_cpacs_input_requirements(cpacs_in_path, cpacs_inout, __file__)

    # ===== FramAT analysis =====
    print("=== PLACEHOLDER ===")

    # ===== End =====
    log.info("FramAT analysis completed")
