#!/bin/bash

echo "手动导入网络拓扑仪表板到 Grafana..."

# 启动 port-forward
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
PORT_FORWARD_PID=$!
echo "Port-forward 启动，PID: $PORT_FORWARD_PID"
sleep 5

# 从 ConfigMap 提取仪表板 JSON
echo "提取仪表板配置..."
DASHBOARD_JSON=$(kubectl get configmap -n monitoring network-topology-dashboard -o jsonpath='{.data.network-topology\.json}')

echo "导入仪表板到 Grafana..."
RESPONSE=$(curl -s -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -u "admin:admin123" \
  "http://localhost:3000/api/dashboards/db" \
  -d "{
    \"dashboard\": $(echo "$DASHBOARD_JSON" | jq '.dashboard'),
    \"folderId\": 0,
    \"overwrite\": true
  }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n1)

echo "HTTP 状态码: $HTTP_CODE"
echo "响应: $RESPONSE_BODY"

if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ 仪表板导入成功！"
else
  echo "❌ 仪表板导入失败"
  echo "详细错误: $RESPONSE_BODY"
fi

# 停止 port-forward
echo "停止 port-forward..."
kill $PORT_FORWARD_PID

echo "导入完成！"
