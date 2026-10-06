# ⚡ 快速安装与使用

本文档介绍如何在 Linux 服务器上快速部署并运行 **VPS Backup Sync** 自动化运维脚本。

---

## 🛠️ 环境准备与支持系统

VPS Backup Sync 基于原生 POSIX Shell 编写，仅依赖系统中普遍自带的基础工具：`bash`, `tar`, `rsync`, `sha256sum`, `gzip`。

- **兼容操作系统**：
  - Ubuntu 20.04 / 22.04 / 24.04 LTS
  - Debian 10 / 11 / 12
  - AlmaLinux / Rocky Linux / CentOS 7/8/9

---

## 🚀 一键运行与启动

### 方法一：单行命令启动（无需手动下载）

直接在终端执行下列命令，脚本将实时获取最新版本并呼出交互式控制台：

```bash
curl -sL https://raw.githubusercontent.com/cash602-cmd/vps-backup-sync/main/backup-sync.sh | bash
```

### 方法二：克隆源码运行

若需要审计代码或加入公司内部自动化流水线：

```bash
git clone https://github.com/cash602-cmd/vps-backup-sync.git
cd vps-backup-sync
chmod +x backup-sync.sh
./backup-sync.sh
```

---

## 🖥️ 交互式控制台功能

运行后将呈现简洁的编号菜单：

```text
================================================================================
  📦 VPS Backup Sync v1.0.0 — Fast, Secure Backup & Server Migration Utility
  🌐 源码仓库: https://github.com/cash602-cmd/vps-backup-sync
  📊 性能监控与推荐榜单: https://vpsrankings.com
================================================================================

请选择要执行的操作:
  1) 📦 本地全量归档 (网站文件 + 数据库 + SHA256 校验和)
  2) 🚀 跨服务器无缝迁移 (基于 Rsync over SSH)
  3) 📥 拉取远端备份至当前节点
  4) ⏰ 配置每日定时自动备份 (Cron + 7天自动保留清理)
  0) 🚪 退出程序
```

### 1. 本地全量打包
自动归档 `/var/www`、Nginx/Caddy 配置，并调用 `mysqldump` 或 `pg_dump` 导出数据库，最后将归档文件打包成 `.tar.gz` 并计算 SHA256 存储在 `/opt/backups`。

### 2. 跨服务器直传迁移
输入目标机器的 IP、SSH 端口与账户路径，脚本自动通过 SSH 公钥/密码隧道执行断点续传。

---

## 💡 自动化定时备份建议

建议通过菜单选项 `4` 设置每晚自动执行备份，并配置异地传输。为保证数据安全性，建议将异地备份目的地选择在独立服务商提供的稳定存储节点上。关于低成本大容量存储型 VPS 的实时横向评测，可参考 [VPS Rankings 存储 VPS 选购实测](https://vpsrankings.com/vps/best-cheap-vps)。
