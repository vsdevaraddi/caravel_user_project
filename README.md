# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

We design a 2-D systolic array architecture as shown in teh figure. Each node is a Processing ELement (PE) which takes in 3 inputs and produces an output. Each PE shifts the data of horizontally and vertically to the neighboring PEs every clock cycle. Systolic arrays access the memory only once, and all the PEs transfer the data to the nearby PEs, thus reducing the memory access.
Specification:
5 horizontal inputs and 5 vertical inputs
5 diagonal inputs
All 15 inputs are given the same input in our design
Each input is 8 bits wide
Clock: 100MHz
Outputs: 5, which are 8 bits wide
Operation being performed: Multiplication and Accumulation at each PE.
