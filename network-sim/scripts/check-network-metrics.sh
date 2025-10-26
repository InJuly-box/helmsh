#!/bin/bash

echo "=== 网络指标详细检查 ==="

PROM_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus -o name | head -1)

echo "1. 所有网络指标:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/label/__name__/values" | jq '.data[]' | grep network
echo ""

echo "2. 所有监控的设备:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/label/device/values" | jq '.data[]'
echo ""

echo "3. 各设备上行带宽:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/query?query=network_bandwidth_up" | jq -r '.data.result[] | "设备: \(.metric.device) | 角色: \(.metric.role) | 上行带宽: \(.value[1]) Mbps"'
echo ""

echo "4. 各设备下行带宽:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/query?query=network_bandwidth_down" | jq -r '.data.result[] | "设备: \(.metric.device) | 角色: \(.metric.role) | 下行带宽: \(.value[1]) Mbps"'
echo ""

echo "5. 带宽使用率:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/query?query=network_bandwidth_usage_up" | jq -r '.data.result[] | "设备: \(.metric.device) | 上行使用率: \(.value[1])%"'
echo ""

echo "6. 网络延迟:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/query?query=network_latency" | jq -r '.data.result[] | "设备: \(.metric.device) | 延迟: \(.value[1]) ms"' | head -10
echo ""

echo "7. 数据包丢失:"
kubectl exec -n monitoring $PROM_POD -- wget -q -O - "http://localhost:9090/api/v1/query?query=network_packet_loss" | jq -r '.data.result[] | "设备: \(.metric.device) | 丢包率: \(.value[1])%"' | head -10
