# Code----Feedback-control-bounds-variability-in-large-scale-electrochemical-systems

This repository contains the code used in the paper **'Feedback control bounds variability in large scale electrochemical systems'**.

---

## System Requirements

### Software dependencies
- **MATLAB 2024b** or newer (this is the version the software was developed and tested on)
- No additional non-standard hardware is required

### Supported operating systems
This code can run on any operating system that supports MATLAB 2024b or newer, including:
- Windows 10/11
- macOS 12 (Monterey) or later
- Linux (Ubuntu 20.04 or later)

---

## Installation Guide

### Instructions
1. Download MATLAB 2024b (or newer) from the MathWorks website.
2. Install following the official MathWorks guidelines:
   https://www.mathworks.com/help/install/ug/install-products-with-internet-connection.html
3. Clone or download this repository and place it in a directory of your choice.
4. No additional toolbox installation is required beyond a standard MATLAB installation.

### Typical install time
Installation of MATLAB can take up to **15 minutes** on a normal desktop computer. Downloading this repository takes less than 1 minute.

---

## Demo

### Repository structure
The repository contains the following files and folders:

| File / Folder | Description |
|---|---|
| `Fig2_plots.m` | Runner script that generates Figure 2 from the paper |
| `Fig3_plots.m` | Runner script that generates Figure 3 from the paper |
| `Fig4_plots.m` | Runner script that generates Figure 4 from the paper |
| `Fig5_plots.m` | Runner script that generates Figure 5 from the paper |
| `functions/` | Folder containing helper functions used by the runner scripts |
| `variables/` | Folder containing processed data from the dataset used by the runners |

### Instructions to run on the demo dataset
1. Open MATLAB 2024b or newer.
2. Navigate to the repository folder in the MATLAB file browser or set it as your working directory:
   ```matlab
   cd('/path/to/repository')
   ```
3. Open any of the runner scripts (e.g., `Fig2_plots.m`) and press the **Run** button in the script submenu, or type the script name in the MATLAB command window:
   ```matlab
   Fig2_plots
   ```

### Expected output
Each runner script produces the subfigures matching the corresponding figures in the paper:
- `Fig2_plots.m` → Figure 2 subfigures
- `Fig3_plots.m` → Figure 3 subfigures
- `Fig4_plots.m` → Figure 4 subfigures
- `Fig5_plots.m` → Figure 5 subfigures

### Expected run time
Each script is expected to complete in under **1 minute** on a normal desktop computer.

---
