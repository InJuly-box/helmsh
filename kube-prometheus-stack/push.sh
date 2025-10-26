cat > pull-all-images.sh << 'EOF'
#!/bin/bash

set -e

echo "开始拉取所有 Prometheus Stack 镜像..."

# 镜像列表 - 基于你提供的配置
IMAGES=(
  # prometheus-operator (使用 appVersion v0.66.0)
  "quay.io/prometheus-operator/prometheus-operator:v0.66.0"
  
  # alertmanager
  "quay.io/prometheus/alertmanager:v0.25.0"
  
  # prometheus
  "quay.io/prometheus/prometheus:v2.45.0"
  
  # prometheus-config-reloader (使用与 operator 相同的版本)
  "quay.io/prometheus-operator/prometheus-config-reloader:v0.66.0"
  
  # thanos
  "quay.io/thanos/thanos:v0.31.0"
  
  # 之前已经推送的 webhook-certgen
  # "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6"
  
  # node-exporter (通常也需要)
  "quay.io/prometheus/node-exporter:v1.5.0"
  
  # kube-state-metrics
  "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.8.2"
  
  # grafana
  "docker.io/grafana/grafana:9.5.3"
)

for image in "${IMAGES[@]}"; do
  echo "处理镜像: $image"
  
  # 提取镜像名和标签
  if [[ $image == *"/"* ]]; then
    image_name=$(echo $image | awk -F/ '{print $NF}')
  else
    image_name=$image
  fi
  
  base_name=$(echo $image_name | awk -F: '{print $1}')
  tag=$(echo $image | awk -F: '{print $2}')
  
  echo "拉取: $image"
  nerdctl pull $image
  
  echo "打标签: ccr.ccs.tencentyun.com/lmimage/${base_name}:${tag}"
  nerdctl tag $image ccr.ccs.tencentyun.com/lmimage/${base_name}:${tag}
  
  echo "推送: ccr.ccs.tencentyun.com/lmimage/${base_name}:${tag}"
  nerdctl push ccr.ccs.tencentyun.com/lmimage/${base_name}:${tag}
  
  echo "完成: $image"
  echo "----------------------------------------"
done

echo "所有镜像已成功推送到腾讯云 CCR"
EOF

chmod +x pull-all-images.sh
./pull-all-images.sh
