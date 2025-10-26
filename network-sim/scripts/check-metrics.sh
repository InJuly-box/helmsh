#!/bin/bash

echo "=== 检查监控指标 ==="

# 获取 Prometheus Pod
PROM_POD=$(kubectl get pods -n monitoring -l app=prometheus -o name | head -1)

echo "1. 查询网络带宽指标:"
kubectl exec -n monitoring $PROM_POD -- curl -s "http://localhost:9090/api/v1/query?query=network_bandwidth_up" | jq '.data.result[] | {device: .metric.device, value: .value[1]}'

echo -e "\n2. 查询所有设备指标:"
kubectl exec -n monitoring $PROM_POD -- curl -s "http://localhost:9090/api/v1/query?query=network_bandwidth_up" | jq '.data.result[] | .metric.device'

echo -e "\n3. 检查指标数量:"
kubectl exec -n monitoring $PROM_POD -- curl -s "http://localhost:9090/api/v1/query?query=count(network_bandwidth_up)" | jq '.data.result[].value[1]'
