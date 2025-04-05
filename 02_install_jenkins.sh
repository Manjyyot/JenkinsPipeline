#!/bin/bash
set -e

echo "[*] Creating Jenkins directory..."
mkdir -p ~/jenkins
cd ~/jenkins

echo "[*] Downloading Jenkins WAR..."
wget https://get.jenkins.io/war-stable/2.492.1/jenkins.war

echo "[✓] Jenkins WAR downloaded"
