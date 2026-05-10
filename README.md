# Quick-Argo-Xray

一个极致轻量化的全自动网络穿透部署脚本。专为 **64MB** 内存的廉价 VPS（支持 Alpine Linux, Debian, Ubuntu）量身定制。通过 Xray-core 与 Cloudflare Argo Tunnel 的组合，实现无公网 IP、无域名环境下的接入。

## 🌟 项目亮点

*   **内存压榨**：深度优化 Xray 配置，关闭所有非必要日志
    *   自动生成适配优选订阅器的链接，直接获取高速体验。

## 🚀 快速开始

在你的终端执行以下命令（建议以 root 身份运行）：

```bash
bash <(curl -fsSL https://github.com/clerzg/quick-argo-xray/raw/refs/heads/main/quick-argo-xray.sh)
```

## 📂 目录结构

*   `~/xray/`：存放 Xray 核心及配置文件 `config.json`。
*   `~/cloudflared-linux`：Cloudflare Argo 隧道主程序。
*   `~/v2ray.txt`：部署成功后自动保存的节点信息副本。

## 📝 运行示例

脚本执行完成后，你将获得如下输出：

```text
----------------------------------------------------------------
🛠️ 优选订阅链接:
https://sub.xxx/sub?uuid=...&host=your-argo-domain...
----------------------------------------------------------------
```

## ⚠️ 注意事项

*   **权限说明**：脚本会自动切换至 `~` (用户主目录) 运行，以确保在不同环境下均拥有读写权限。
*   **环境依赖**：对于 Alpine Linux 用户，请确保已预装 `curl` 和 `unzip`。
*   **免责声明**：本项目仅供网络技术研究与学习使用，请遵守当地相关法律法规。

---
**如果这个项目对你有帮助，欢迎点个 Star ⭐！**
