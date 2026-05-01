# GhostEye 👁️
**GhostEye** is a stealthy, modular Bash script designed for automated system reconnaissance and privilege escalation auditing on Linux environments. 

Developed as part of my Software Engineering and Cybersecurity studies, this tool helps identify potential vulnerabilities after gaining initial access to a target system.

## 🚀 Key Modules
GhostEye automates the collection of critical security data through 5 specialized modules:

*   **System Reconnaissance:** Gathers OS version, kernel details, architecture, and current user identity[cite: 1].
*   **SUID Hunter:** Scans for binaries with the SUID bit set and highlights high-priority targets listed on GTFOBins (e.g., find, vim, nano, bash)[cite: 1].
*   **Writable Directory Hunter:** Identifies globally writable directories like `/tmp`, excluding system-heavy paths to keep results clean[cite: 1].
*   **Network Information Hunter:** Discovers local network interfaces, IP addresses, and active listening ports using `netstat` or `ss`[cite: 1].
*   **Security Protection Audit:** Checks the status of system defenses like IPTables rules, SELinux, and AppArmor[cite: 1].

## 🛠️ Installation & Usage
To run GhostEye, ensure you are in a Linux environment (or using Git Bash for testing)[cite: 1].

1. **Clone or Download the script:**
   ```bash
   # If you use git
   git clone [https://github.com/Dilshan-99/GhostEye.git](https://github.com/Dilshan-99/GhostEye.git)
   cd GhostEye
Give execution permissions:

Bash
chmod +x ghosteye.sh
Run the tool:

Bash
./ghosteye.sh
Tip: For best results and stealth, you can run this script from the /tmp directory[cite: 1].

📊 Sample Output
The tool provides a professional UI with a custom "Cyan Eye" banner and color-coded results for easy analysis[cite: 1].

🛡️ Disclaimer
This tool is for educational and authorized security testing purposes only. The developer (Dilshan-99) is not responsible for any misuse or damage caused by this program.
