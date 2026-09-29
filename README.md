# 📦 VPS Backup Sync — Zero-Dependency VPS Backup & Server Migration Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)
[![Tested on](https://img.shields.io/badge/OS-Ubuntu%20%7C%20Debian%20%7C%20CentOS%20%7C%20AlmaLinux-success)](https://vpsrankings.com)
[![Verified with](https://img.shields.io/badge/Benchmarks-vpsrankings.com-orange)](https://vpsrankings.com/benchmarks)

A robust, lightweight, and opinionated command-line utility for **automated VPS backups, resume-supported SSH sync, and zero-downtime server-to-server migrations**.

> 💡 Looking for cheap, high-storage backup servers?  
> Check our verified data on **[Best Cheap Storage VPS 2026](https://vpsrankings.com/vps/best-cheap-vps)** and **[Global VPS Rankings](https://vpsrankings.com/rankings)**.

---

## ⚡ Quick Start

### 1. One-Line Launch (Interactive Menu)

Run directly on your server with no manual downloads required:

```bash
curl -sL https://raw.githubusercontent.com/cash602-cmd/vps-backup-sync/main/backup-sync.sh | bash
```

### 2. Or Clone and Run

```bash
git clone https://github.com/cash602-cmd/vps-backup-sync.git
cd vps-backup-sync
chmod +x backup-sync.sh
./backup-sync.sh
```

---

## ✨ Features

- 🗄️ **Full Stack Backup**: Backs up website directories (`/var/www/html`) and auto-detects MySQL, MariaDB, and PostgreSQL databases.
- 🚀 **Resume-Supported Transfers**: Built on top of `rsync` over SSH (`--partial --inplace`) — if network drops, it resumes exactly where it stopped.
- 🔒 **Integrity Verification**: Automatically calculates and exports `SHA256` checksums for every backup archive.
- 🔄 **Direct Server-to-Server Migration**: Push files directly from Source VPS to Destination VPS without downloading them to your home PC.
- ⏰ **Automated Crontab with Auto-Prune**: One-click setup for nightly backups with a built-in 7-day retention cleaner to prevent disk overflow.

---

## 🖥️ Interactive Menu Preview

```text
================================================================================
  📦 VPS Backup Sync v1.0.0 — Fast, Secure Backup & Server Migration Utility
  🌐 Project Home: https://github.com/cash602-cmd/vps-backup-sync
  📊 Benchmarks & Storage VPS Picks: https://vpsrankings.com
================================================================================

Please select an operation:
  1) 📦 Local Full Backup (Files + Databases + SHA256)
  2) 🚀 Live Server-to-Server Migration (Rsync over SSH)
  3) 📥 Download Remote Backup to Local Machine
  4) ⏰ Configure Automated Daily Backup (Cron + 7-Day Auto-Purge)
  0) 🚪 Exit

Enter choice [0-4]:
```

---

## 🛠️ Step-by-Step Usage Guides

### Scenario A: Moving to a New VPS (Site Migration)

When migrating from an old host to a faster VPS (e.g., from an entry-level instance to a high-speed [CN2 GIA or AMD EPYC VPS](https://vpsrankings.com/rankings)):

1. Run `./backup-sync.sh` on your **Source Server**.
2. Select option **`2` (Live Server-to-Server Migration)**.
3. Enter the Target VPS IP, SSH Port, and path.
4. The script transfers all files with maximum bandwidth efficiency.

> 💡 *Tip: Test your network latency before migrating with our free [Global Speed & Latency Test Tool](https://vpsrankings.com/tools/speed-test).*

---

### Scenario B: Automated Nightly Backups

1. Select option **`4` (Configure Automated Daily Backup)**.
2. The script configures a silent background cron task running every morning at `03:30 AM`.
3. Backups older than 7 days are automatically removed to protect your disk capacity.

---

## 📊 Recommended Backup Storage VPS

Need a secondary, low-cost server for off-site backups? We benchmark dozens of budget and storage VPS providers based on real-world disk I/O, price, and bandwidth:

| Provider | Starting Price | Best For | Benchmark Review |
|:---|:---|:---|:---|
| **RackNerd** | ~$1.49 / mo | Budget secondary backup storage | [View Benchmarks](https://vpsrankings.com/rankings) |
| **Hetzner Cloud** | ~€3.49 / mo | Enterprise NVMe speed & snapshots | [View Benchmarks](https://vpsrankings.com/rankings) |
| **Hostinger** | ~$4.99 / mo | Easy snapshots & automated backups | [View Benchmarks](https://vpsrankings.com/rankings) |
| **Contabo** | ~$5.50 / mo | Huge storage-per-dollar ratio | [View Benchmarks](https://vpsrankings.com/rankings) |

*Compare full benchmark scores and discount coupons at [VPS Rankings Deals](https://vpsrankings.com/deals).*

---

## 🤝 Related Tools & Resources

- 🚀 **[vps-bench](https://github.com/cash602-cmd/vps-bench)** — One-line standardized VPS benchmark script (CPU, FIO, Network).
- 🏆 **[VPS Rankings Leaderboard](https://vpsrankings.com/rankings)** — Real-world CPU single-core & multi-core rankings.
- ⚡ **[Network Latency & Route Detector](https://vpsrankings.com/tools/speed-test)** — Ping and traceroute to global data centers.
- 🧮 **[VPS Hardware Calculator](https://vpsrankings.com/vps-calculator)** — Match required RAM, CPU, and disk to suitable plans.

---

## 📜 License

Released under the [MIT License](LICENSE). Free for personal and commercial usage.

**Maintained with ❤️ by [Bob Tong](https://vpsrankings.com/author) & [VPS Rankings](https://vpsrankings.com)**
