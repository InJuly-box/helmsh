# 新增代理
1. 为 Containerd 配置代理
bash
# 创建 containerd 代理配置
sudo mkdir -p /etc/systemd/system/containerd.service.d/
sudo cat > /etc/systemd/system/containerd.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://192.168.1.2:7897"
Environment="HTTPS_PROXY=http://192.168.1.2:7897"
Environment="NO_PROXY=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.svc.cluster.local,ccr.ccs.tencentyun.com"
EOF
2. 应用配置并重启服务
bash
# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 重启 containerd
sudo systemctl restart containerd

# 检查代理设置是否生效
sudo systemctl show containerd --property=Environment

# 检查 containerd 状态
sudo systemctl status containerd
3. 启动命令
helm install prometheus prometheus-community/kube-prometheus-stack   --namespace monitoring   --version 48.1.1   --set prometheus.prometheusSpec.retention="14d"   --set prometheus.prometheusSpec.retentionSize="15GB"   --set grafana.enabled=true
4. 设置nodeport访问
# Grafana - 用于访问监控仪表板
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec": {"type": "NodePort"}}'

# Prometheus - 用于访问 Prometheus Web UI
kubectl patch svc prometheus-kube-prometheus-prometheus -n monitoring -p '{"spec": {"type": "NodePort"}}'

# Alertmanager - 用于访问 Alertmanager Web UI
kubectl patch svc prometheus-kube-prometheus-alertmanager -n monitoring -p '{"spec": {"type": "NodePort"}}'

# 创建包含网络监控的 values 文件
cat > network-values.yaml << 'EOF'
prometheus:
  prometheusSpec:
    retention: 14d
    retentionSize: 15GB
    additionalScrapeConfigs:
      - job_name: 'network-simulator'
        scrape_interval: 10s
        static_configs:
          - targets: ['bandwidth-simulator.network-sim.svc.cluster.local:5000']
        metrics_path: /metrics

grafana:
  enabled: true
EOF

# 使用 values 文件升级
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 48.1.1 \
  -f network-values.yaml
