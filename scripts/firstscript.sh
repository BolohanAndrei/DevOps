#!/bin/bash
# ------------------------------------------------------------------
# Script Name: firstscript.sh
# ------------------------------------------------------------------

echo "### Welcome to System Monitoring Script ###"
echo

echo "--> System Uptime & Load Average:"
uptime
echo

echo "--> Memory Utilization (MB):"
free -m
echo

echo "--> Disk Space Utilization:"
df -h
echo
