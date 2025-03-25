# PingStormProject
# PingStorm.sh - TCP | TechCyberPoint
# Members: Yosi + Ofir + 

## 🎯 Project Overview

**PingStorm** is a professional Bash script developed as part of a collaborative project by the **TechCyberPoint (TCP)** team.  
It serves as the **first function** in a toolchain designed for automated network diagnostics.

This script performs ICMP `ping` tests to a predefined list of well-known domains and logs the results for further processing.

---

## 🧰 What the Script Does

- Reads domains from `TargetPing.txt`
- Sends 5 ICMP `ping` requests to each domain
- Logs structured results to `PingResults.txt`
- Outputs execution logs to `ping_log.txt`
- Displays logs in the terminal **with color-coded messages**
- Summarizes each domain scan with:
  - Total Success / Failures
  - Average response time (ms)
- Supports running as **regular user** or **root**

---

## 🧠 Technologies Used

| Component         | Description                                 |
|------------------|---------------------------------------------|
| **Bash**          | Script language                             |
| **ping**          | Native network response tool                |
| **getent**        | DNS resolver (to fetch IP address)          |
| **bc**            | Command-line calculator (for averages)      |
| **ANSI Colors**   | Colored log output via terminal             |
| **Redirection**   | Standard I/O (`>>`) used for file outputs   |

---

## 📁 Project Structure

📂 /project-folder/ ├── PingStorm.sh # Main Bash script ├── TargetPing.txt # List of target domains ├── PingResults.txt # Structured ping test results └── ping_log.txt # Execution and error logs

---

## 🚀 How to Use

1. **Create the domain target file**:
    ```bash
    echo -e "google.com\nfacebook.com\nyoutube.com\nlinkedin.com\ntiktok.com" > TargetPing.txt
    ```

2. **Make the script executable**:
    ```bash
    chmod +x PingStorm.sh
    ```

3. **Run the script**:
    ```bash
    ./PingStorm.sh
    ```

---

## 📄 Output Files Description

### 🔹 `PingResults.txt`
A clean structured file containing:
- Domain and resolved IP
- ICMP sequence ID
- Response time (ms)
- Error codes (if any)
- Status: Success / Failed
- Summary block after each domain

### 🔸 `ping_log.txt`
Internal activity log of the script with timestamped messages using the format:

[2025-03-25 12:30:12] | INFO | PingStorm.sh/init | Script started

---

## 🔔 Log Types & Colors

| Type     | Color     | Description                          |
|----------|-----------|--------------------------------------|
| INFO     | Blue      | General process info                |
| SUCCESS  | Green     | Completed operations                 |
| ERROR    | Red       | DNS issues, connection failures      |
| WARN     | Yellow    | Warnings and recoverable problems    |

---

## 👨‍💻 For Developers

- **Clean, readable Bash code** with inline comments.
- **Modular structure**: separate functions for logging and ping logic.
- Ready for integration into:
  - Automation pipelines
  - Monitoring tools
  - CSV generation modules (in future stages)
- Supports both file logging and live terminal feedback.

---

## 🔮 Future Enhancements

- CSV format support (via next script/module in the chain)
- Multi-threaded scanning with `parallel` or `xargs`
- Logging response history per domain
- Integration with dashboards or reporting tools

---

## 📞 Contact

This project is developed by the **TCP – TechCyberPoint** team.

For questions, collaboration, or contributions, feel free to reach out via [LinkedIn]([https://www.linkedin.com](https://www.linkedin.com/groups/9897560/)) or your preferred platform.

---














