#!/usr/bin/env python3
import os
import sys
import time
import subprocess
import threading
import json
from colorama import init, Fore, Style

init(autoreset=True)

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def print_banner():
    banner = f"""
{Fore.RED}
$$\              $$\ $$$$$$$\  $$\                   
$$ |             $  |$$  __$$\ $$ |                  
$$ |      $$$$$$\\_/ $$ |  $$ |$$$$$$$\   $$$$$$\  $$$$$$$\
$$ |      \____$$\   $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$\
$$ |      $$$$$$$ |  $$  __$$< $$ |  $$ |$$$$$$$$ |$$ |  $$ |
$$ |     $$  __$$ |  $$ |  $$ |$$ |  $$ |$$   ____|$$ |  $$ |
$$$$$$$$\\$$$$$$$ |  $$ |  $$ |$$ |  $$ |\$$$$$$$\ $$ |  $$ |
\________|\_______|  \__|  \__|\__|  \__| \_______|\__|  \__|
                                                     
                                                     
{Style.RESET_ALL}
{Fore.YELLOW}
╔══════════════════════════════════════════╗
║         Advanced Reconnaissance Tool        ║
╚══════════════════════════════════════════╝
{Style.RESET_ALL}
"""
    print(banner)

def check_tools():
    required_tools = {
        'assetfinder': 'assetfinder --help',
        'subfinder': 'subfinder --help',
        'anew': 'anew --help',
        'samoscout': 'samoscout --help',
        'httpx': 'httpx --help'
    }

    print(f"\n{Fore.CYAN}[*] Checking tools...{Style.RESET_ALL}")

    missing_tools = []
    for tool, test_cmd in required_tools.items():
        try:
            result = subprocess.run(test_cmd, shell=True, stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL, timeout=3)
            if result.returncode != 0:
                missing_tools.append(tool)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            missing_tools.append(tool)

    return missing_tools

def run_tool(command, tool_name, output_file=None):
    print(f"\n{Fore.YELLOW}╔═══[{tool_name}]══════════════════════════════════════╗{Style.RESET_ALL}")
    print(f"{Fore.WHITE}Command: {command}{Style.RESET_ALL}")

    stop_animation = False
    animation_frames = ["[■□□□□□□□□□]", "[■■□□□□□□□□]", "[■■■□□□□□□□]",
                       "[■■■■□□□□□□]", "[■■■■■□□□□□]", "[■■■■■■□□□□]",
                       "[■■■■■■■□□□]", "[■■■■■■■■□□]", "[■■■■■■■■■□]",
                       "[■■■■■■■■■■]"]

    def animate():
        i = 0
        while not stop_animation:
            frame = animation_frames[i % len(animation_frames)]
            color = Fore.GREEN if i % 2 == 0 else Fore.YELLOW
            print(f"\r{color}{frame}{Style.RESET_ALL} Running...", end="", flush=True)
            time.sleep(0.1)
            i += 1

    anim_thread = threading.Thread(target=animate)
    anim_thread.daemon = True
    anim_thread.start()

    try:
        start_time = time.time()
        if output_file:
            with open(output_file, 'w') as f:
                result = subprocess.run(command, shell=True, stdout=f,
                                      stderr=subprocess.PIPE, text=True)
        else:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)

        stop_animation = True
        time.sleep(0.1)
        elapsed_time = time.time() - start_time

        if result.returncode == 0:
            if output_file and os.path.exists(output_file):
                with open(output_file, 'r') as f:
                    line_count = len(f.readlines())
            elif result.stdout:
                line_count = len(result.stdout.strip().split('\n'))
            else:
                line_count = 0

            print(f"\r{Fore.GREEN}[✓]{Style.RESET_ALL} {tool_name} completed! "
                  f"({line_count} results, {elapsed_time:.1f}s)")

            return True, line_count
        else:
            print(f"\r{Fore.RED}[✗]{Style.RESET_ALL} {tool_name} error: {result.stderr[:100]}")
            return False, 0

    except Exception as e:
        stop_animation = True
        print(f"\r{Fore.RED}[✗]{Style.RESET_ALL} {tool_name} exception: {str(e)[:100]}")
        return False, 0

def get_domain_input():
    input_box = f"""
{Fore.CYAN}
╔══════════════════════════════════════════════╗
║                                              ║
║  {Fore.WHITE}TARGET WILDCARD (e.g., target.com){Fore.CYAN}           ║
║                                              ║
╚══════════════════════════════════════════════╝
{Style.RESET_ALL}
"""
    print(input_box)

    while True:
        domain = input(f"{Fore.GREEN}[?]{Style.RESET_ALL} Domain: ").strip()

        if not domain:
            print(f"{Fore.RED}[!] No domain entered!{Style.RESET_ALL}")
            continue

        if ' ' in domain:
            print(f"{Fore.RED}[!] Domain cannot contain spaces!{Style.RESET_ALL}")
            continue

        if '.' not in domain:
            print(f"{Fore.YELLOW}[!] Warning: Does not look like a valid domain{Style.RESET_ALL}")
            proceed = input(f"{Fore.YELLOW}[?] Continue anyway? (y/n): {Style.RESET_ALL}")
            if proceed.lower() != 'y':
                continue

        return domain

def main():
    clear_screen()
    print_banner()
    time.sleep(0.5)

    missing_tools = check_tools()

    if missing_tools:
        print(f"\n{Fore.RED}[!] Missing tools:{Style.RESET_ALL}")
        for tool in missing_tools:
            print(f"  {Fore.YELLOW}•{Style.RESET_ALL} {tool}")

        print(f"\n{Fore.CYAN}[*] Installation commands:{Style.RESET_ALL}")
        install_commands = {
            'assetfinder': 'go install github.com/tomnomnom/assetfinder@latest',
            'subfinder': 'go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest',
            'anew': 'go install github.com/tomnomnom/anew@latest',
            'samoscout': 'go install github.com/samogod/samoscout@latest',
            'httpx': 'go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest'
        }

        for tool in missing_tools:
            if tool in install_commands:
                print(f"  {Fore.GREEN}›{Style.RESET_ALL} {install_commands[tool]}")

        print(f"\n{Fore.RED}[!] Please install missing tools and try again.{Style.RESET_ALL}")
        return

    print(f"\n{Fore.GREEN}[✓] All tools available!{Style.RESET_ALL}")

    print(f"\n{Fore.CYAN}[*] Initializing...{Style.RESET_ALL}")
    for i in range(3, 0, -1):
        print(f"\r{Fore.YELLOW}Starting in: {i}{Style.RESET_ALL}", end="", flush=True)
        time.sleep(1)
    print(f"\r{Fore.GREEN}Starting!{Style.RESET_ALL}")

    domain = get_domain_input()

    timestamp = time.strftime("%Y%m%d_%H%M%S")
    output_dir = f"recon_{domain}_{timestamp}"
    os.makedirs(output_dir, exist_ok=True)
    os.chdir(output_dir)

    print(f"\n{Fore.CYAN}[*] Output directory: {os.getcwd()}{Style.RESET_ALL}")

    recon_header = f"""
{Fore.RED}
╔══════════════════════════════════════════════╗
║                                              ║
║          R E C O N   S T A R T E D          ║
║           Target: {domain:^20}          ║
║                                              ║
╚══════════════════════════════════════════════╝
{Style.RESET_ALL}
"""
    print(recon_header)

    results = {}

    success, count = run_tool(
        f"assetfinder --subs-only {domain}",
        "AssetFinder",
        "assetfinder.txt"
    )
    if success:
        results['assetfinder'] = count

    success, count = run_tool(
        f"subfinder -d {domain} -recursive -all -silent",
        "SubFinder",
        "subfinder.txt"
    )
    if success:
        results['subfinder'] = count

    success, count = run_tool(
        f"samoscout -d {domain} -silent",
        "Samoscout",
        "samoscout.txt"
    )
    if success:
        results['samoscout'] = count

    success, count = run_tool(
        f"curl -s 'https://crt.sh/?q=%.{domain}&output=json' | jq -r '.[].name_value' | sed 's/\\*\\\\.//g' | sort -u",
        "CRT.sh",
        "crtsh.txt"
    )
    if success:
        results['crtsh'] = count

    print(f"\n{Fore.CYAN}[*] Merging results...{Style.RESET_ALL}")

    all_domains = set()
    txt_files = ["assetfinder.txt", "subfinder.txt", "samoscout.txt", "crtsh.txt"]

    for filename in txt_files:
        if os.path.exists(filename):
            try:
                with open(filename, 'r') as f:
                    for line in f:
                        domain_line = line.strip()
                        if domain_line and '.' in domain_line:
                            all_domains.add(domain_line)
            except:
                pass

    with open('all_subs.txt', 'w') as f:
        for domain_name in sorted(all_domains):
            f.write(f"{domain_name}\n")

    total_domains = len(all_domains)

    for filename in txt_files:
        if os.path.exists(filename):
            os.remove(filename)

    print(f"\n{Fore.GREEN}╔══════════════════════════════════════════════╗")
    print(f"║                                              ║")
    print(f"║      R E C O N   C O M P L E T E D !        ║")
    print(f"║                                              ║")
    print(f"║    Total Subdomains Found: {Fore.YELLOW}{total_domains:^6}{Fore.GREEN}        ║")
    print(f"║                                              ║")
    print(f"╚══════════════════════════════════════════════╝{Style.RESET_ALL}")

    if results:
        print(f"\n{Fore.CYAN}[*] Tool Statistics:{Style.RESET_ALL}")
        for tool, count in results.items():
            print(f"  {Fore.YELLOW}›{Style.RESET_ALL} {tool:20}: {count:4} subdomains")

    if all_domains:
        print(f"\n{Fore.CYAN}[*] First 10 Subdomains:{Style.RESET_ALL}")
        for i, domain_name in enumerate(sorted(all_domains)[:10]):
            print(f"  {Fore.GREEN}{i+1:2}.{Style.RESET_ALL} {domain_name}")

    if total_domains > 0:
        choice = input(f"\n{Fore.YELLOW}[?]{Style.RESET_ALL} Check live subdomains with HTTPX? (y/n): ")
        if choice.lower() == 'y':
            success, count = run_tool(
                f"httpx -l all_subs.txt -title -status-code -tech-detect -silent -o live_subs.txt",
                "HTTPX Live Check"
            )

            if success and os.path.exists('live_subs.txt'):
                with open('live_subs.txt', 'r') as f:
                    live_count = len(f.readlines())
                print(f"\n{Fore.GREEN}[*] {live_count} live subdomains found!{Style.RESET_ALL}")

            success, count = run_tool(
                f"httpx -l all_subs.txt -title -status-code -tech-detect -json -silent -o httpx_results.json",
                "HTTPX JSON Export"
            )

            if success and os.path.exists('httpx_results.json'):
                with open('httpx_results.json', 'r') as f:
                    json_data = json.load(f) if os.path.getsize('httpx_results.json') > 0 else []
                    if isinstance(json_data, list):
                        json_count = len(json_data)
                    else:
                        json_count = 1
                print(f"\n{Fore.GREEN}[*] JSON results saved: {json_count} entries{Style.RESET_ALL}")

    print(f"\n{Fore.CYAN}[*] Recon completed!{Style.RESET_ALL}")
    print(f"{Fore.GREEN}[*] Output directory: {os.getcwd()}{Style.RESET_ALL}")
    print(f"{Fore.GREEN}[*] Main file: all_subs.txt{Style.RESET_ALL}")

    if os.path.exists('httpx_results.json'):
        print(f"{Fore.GREEN}[*] JSON results: httpx_results.json{Style.RESET_ALL}")
    if os.path.exists('live_subs.txt'):
        print(f"{Fore.GREEN}[*] Live subdomains: live_subs.txt{Style.RESET_ALL}")

def print_footer():
    footer = f"""
{Fore.CYAN}
╔══════════════════════════════════════════════╗
║                                              ║
║  {Fore.WHITE}Created by: La'Rhen - Advanced Recon Tool{Fore.CYAN}   ║
║                                              ║
╚══════════════════════════════════════════════╝
{Style.RESET_ALL}
"""
    print(footer)

if __name__ == "__main__":
    try:
        main()
        print_footer()
    except KeyboardInterrupt:
        print(f"\n\n{Fore.RED}[!] Stopped by user{Style.RESET_ALL}")
        sys.exit(0)
    except Exception as e:
        print(f"\n\n{Fore.RED}[!] Critical Error: {e}{Style.RESET_ALL}")
        sys.exit(1)
