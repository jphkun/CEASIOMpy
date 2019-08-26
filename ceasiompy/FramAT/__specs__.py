#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from ceasiompy.utils.moduleinterfaces import CPACSInOut

cpacs_inout = CPACSInOut()

# ===== RCE integration =====

RCE = {
    "name": "FramAT",
    "description": "Frame Analysis Tool (3D beam FEM)",
    "exec": "pwd\npython runframat.py",
    "author": "Aaron Dettmann",
}
