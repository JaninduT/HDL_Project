@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.2 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Sat Jul 25 19:58:21 +0530 2020
REM SW Build 2708876 on Wed Nov  6 21:40:23 MST 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
echo "xelab -wto ccdf379727fe4932bb326a01d57c67eb --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip -L xpm --snapshot ram_input_mux_test_behav xil_defaultlib.ram_input_mux_test -log elaborate.log"
call xelab  -wto ccdf379727fe4932bb326a01d57c67eb --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip -L xpm --snapshot ram_input_mux_test_behav xil_defaultlib.ram_input_mux_test -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0