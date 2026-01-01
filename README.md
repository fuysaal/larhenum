# La'Rhen Recon Tool

Advanced reconnaissance tool for subdomain enumeration and analysis.

## Features
- AssetFinder integration
- SubFinder integration
- Samoscout integration
- CRT.sh certificate search
- HTTPX live checking
- JSON output support
- Automatic result merging
- Colorful console output
- Progress animations
- Organized output directories

## Installation
```bash
git clone https://github.com/fuysaal/larhenum.git && chmod +x install.sh && chmod +x larhenum.py
pip3 install -r requirements.txt
./install.sh
python3 larhenum.py
```
If don't start install.sh 
```bash
cd larhenum 
python3 -m venv venv
source venv/bin/activae
./install.sh
```

### Quick Install
```bash
chmod +x install.sh

./install.sh
```
## Manual Install

### Install dependencies:
```bash
sudo apt update
sudo apt install -y python3 python3-pip golang jq curl
pip3 install colorama
```
### Install Go tools:
```bash
go install github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/tomnomnom/anew@latest
go install github.com/samogod/samoscout@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
```
### Make script executable:
```bash
chmod +x larhenum.py
```

## Usage
```bash
python3 larhenum.py
```
Enter target domain when prompted.

## Output Files

all_subs.txt - All unique subdomains

live_subs.txt - Live subdomains (if HTTPX enabled)

httpx_results.json - Detailed HTTPX results in JSON format

## Tools Used

AssetFinder - Fast subdomain enumeration

SubFinder - Advanced subdomain discovery

Samoscout - Additional enumeration sources

CRT.sh - Certificate transparency logs

HTTPX - Live host verification and technology detection

Anew - Unique result filtering

## Requirements

Python 3.6+

Go 1.16+

jq and curl (for CRT.sh)

Internet connection

## Legal Disclaimer

This tool is for authorized security testing and educational purposes only.
Use only on systems you own or have permission to test.

## License

MIT License

Copyright (c) 2026 FatihUYSAL

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



