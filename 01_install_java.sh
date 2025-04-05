#!/bin/bash
set -e

echo "[*] Installing Java 17 JDK..."
sudo apt update
sudo apt install -y openjdk-17-jdk

echo "[✓] Java 17 Installed"
java -version
