#!/bin/bash

function quicktunnel(){
echo "正在初始化环境..."
cd ~
rm -rf xray cloudflared-linux xray.zip argo.log v2ray.txt
case "$(uname -m)" in
    x86_64 | x64 | amd64 ) ARCH_XRAY="Xray-linux-64.zip"; ARCH_CF="cloudflared-linux-amd64" ;;
    arm64 | aarch64 ) ARCH_XRAY="Xray-linux-arm64-v8a.zip"; ARCH_CF="cloudflared-linux-arm64" ;;
    * ) echo "错误：不支持的架构"; exit 1 ;;
esac

echo "正在获取网络信息..."
trace_raw=$(curl -s --connect-timeout 5 https://www.cloudflare.com/cdn-cgi/trace)
loc=$(echo "$trace_raw" | grep "loc=" | cut -d= -f2)
ip_addr=$(echo "$trace_raw" | grep "ip=" | cut -d= -f2)
isp="${loc:-Argo}-${ip_addr:-Node}"

echo "正在全速下载核心组件 (Xray & Cloudflared)..."
mkdir -p xray
curl -L -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/${ARCH_XRAY}
unzip -j xray.zip xray -d xray && rm -f xray.zip
curl -L -o cloudflared-linux https://github.com/cloudflare/cloudflared/releases/latest/download/${ARCH_CF}
chmod +x cloudflared-linux xray/xray

uuid=$(cat /proc/sys/kernel/random/uuid)
urlpath=$(echo $uuid | awk -F- '{print $1}')
port=$[$RANDOM+10000]

cat > xray/config.json <<EOF
{"log":{"level":"none"},"inbounds":[{"port":$port,"listen":"127.0.0.1","protocol":"vless","settings":{"decryption":"none","clients":[{"id":"$uuid"}]},"streamSettings":{"network":"ws","wsSettings":{"path":"/$urlpath"}}}],"outbounds":[{"protocol":"freedom"}]}
EOF

echo "正在建立隧道连接，请稍候..."
./xray/xray run -c xray/config.json >/dev/null 2>&1 &
./cloudflared-linux tunnel --url http://127.0.0.1:$port --no-autoupdate --protocol http2 >argo.log 2>&1 &

n=0
while true; do
    n=$[$n+1]
    echo -ne "\r已等待: ${n}s (通常 5-15s 成功)..."
    
    argo=$(grep -o 'https://[-a-z0-9.]*trycloudflare.com' argo.log | awk -F// '{print $2}')
    
    if [ $n -eq 15 ] && [ -z "$argo" ]; then
        n=0
        echo -e "\n连接超时，正在尝试重启隧道..."
        pkill -9 cloudflared-linux
        ./cloudflared-linux tunnel --url http://127.0.0.1:$port --no-autoupdate --protocol http2 >argo.log 2>&1 &
    elif [ -n "$argo" ]; then
        rm -rf argo.log
        echo -e "\n\n🚀 部署成功！"
        # 1. 生成不经过优选的原链接 (使用 Argo 原始域名)
        L_ORIGIN="vless://$uuid@$argo:443?encryption=none&security=tls&type=ws&host=$argo&path=%2F$urlpath#${isp}"

        # 2. 生成优选订阅链接 (按照你提供的格式拼接)
        # 注意：path 部分需要进行 URL 编码，这里的 %2F 对应 /
        SUB_URL="https://sub.xinyitang.dpdns.org/sub?uuid=$uuid&encryption=none&security=tls&sni=$argo&fp=chrome&insecure=0&allowInsecure=0&type=ws&host=$argo&path=%2F$urlpath"

        echo -e "----------------------------------------------------------------"
        echo -e "🔗 Argo 原链接 (不带优选):"
        echo -e "$L_ORIGIN\n"
        echo -e "🛠️ 优选订阅链接 (可以直接导入):"
        echo -e "$SUB_URL"
        echo -e "----------------------------------------------------------------"
        
        # 保存到本地文件
        echo -e "Origin_Link:\n$L_ORIGIN\n\nSub_Link:\n$SUB_URL" > v2ray.txt
        echo -e "配置已保存至: v2ray.txt"
        break
    fi
    sleep 1
done
}

quicktunnel
