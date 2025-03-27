# PingStormProject

## 🚀 PingStorm.sh – TechCyberPoint

## 🎯 Project Overview

**PingStorm** is a modular and collaborative Bash toolkit developed by the **TechCyberPoint (TCP)** team. It performs structured `ping` diagnostics, generates logs, and serves as the **first step** in a multi-stage network analysis pipeline.

It enables teams to:
- Diagnose latency issues
- Record structured ping data
- Automate monitoring scripts
- Visualize performance across domains

---

## 🧰 Core Features

- ✅ Reads target domains from (`TargetPing.txt`)
- ✅ Sends 5 ICMP ping requests per domain
- ✅ Resolves IP address using `getent`
- ✅ Logs results in clean tabular format (`PingResults.txt`)
- ✅ Analyze the data and extract statistics into ordered text file (`ResultsAnalysis.txt`)
- ✅ Visualize the extracted ordered data
- ✅ Displays colored logs in terminal and saves them (`pingstorm.log`)
- ✅ Calculates and appends average response time per domain
- ✅ Fully modular and ready for scripting pipelines

---

## 🧠 Technologies Used

| Component       | Description                                     |
|----------------|-------------------------------------------------|
| **Bash**        | Primary scripting language                      |
| **ping**        | ICMP-based connectivity checks                  |
| **getent**      | Resolves domains to IP addresses                |
| **bc**          | Used for calculating floating point averages    |
| **ANSI Colors** | Terminal formatting for log types              |
| **Redirection** | Structured output via `>>` append operators    |

---

## 📁 Project Structure

```
PingStormProject/
├── PingStorm.sh           # Main execution script
├── ResultsAnalysis.sh     # Analyzer module (phase 2)
├── visualization.sh       # Final visualization report
├── Control.sh             # Full system control menu
├── TargetPing.txt         # List of domains to scan
├── PingResults.txt        # Ping test raw results
├── ResultsAnalysis.txt    # Analysis summary output
├── pingstorm.log           # Unified execution log
```

---

## 🧪 How to Use (Basic Flow)

```bash
# 1. Make scripts executable
chmod +x PingStorm.sh ResultsAnalysis.sh visualization.sh Control.sh

# 2. Run Control Panel Menu (recommended)
./Control.sh
```

Inside the menu you’ll see options to:
- Start ping
- Analyze results
- Show last logs
- Run full cycle

Alternatively, run manually:
```bash
./PingStorm.sh          # Ping domains
./ResultsAnalysis.sh    # Analyze the output
./visualization.sh      # Show report
```

---

## 📄 Output Files Explained

### 📘 `PingResults.txt`
- Format: `domain t1 t2 t3 t4 t5 avg`
- Each row represents a domain
- Used later by analyzer and report scripts

### 📙 `ResultsAnalysis.txt`
- Output summary of the analysis phase
- Includes:
  - Fastest / Slowest domain
  - Full ranking by latency
  - Overall average

### 📕 `pingstorm.log`
- Full logs of all scripts
- Uses format:

  ```
  [YYYY-MM-DD HH:MM:SS] | TYPE | ScriptName/Function | Message
  ```
- Includes `INFO`, `SUCCESS`, `ERROR`, `WARN`

---

## 🔔 Log Types & Colors

| Type     | Color     | Description                          |
|----------|-----------|--------------------------------------|
| INFO     | Blue      | General process status               |
| SUCCESS  | Green     | Completed operations                 |
| ERROR    | Red       | Failures (e.g. DNS, ping failure)    |
| WARN     | Yellow    | Warnings or recoverable issues       |

---

## 🖥 Report Example (From `visualization.sh`)
```
🌐 PINGSTORM REPORT
========================================
📊 Average Latency: 21.47 ms
✅ Fastest: google.com (7.21 ms)
🐢 Slowest: facebook.com (84.55 ms)
========================================
Latency Ranking Visual:
facebook.com     | ████████████████████████████████████ 84.55 ms
google.com       | ██████                             7.21 ms
youtube.com      | ██████████                         25.00 ms
```

---

## 👨‍💻 Developer Notes

- Modular: each script is standalone, chainable, or replaceable
- Easy to debug: logs + colors + errors
- Ready for:
  - CSV conversion
  - Crontab integration
  - CI pipelines

---

## 🔮 Future Roadmap

- [ ] Export results directly to CSV/JSON
- [ ] Add domain response history per day
- [ ] Web dashboard (future stage)
- [ ] Run scans in parallel (`xargs`, `parallel`)

---

