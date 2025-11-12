# Grafana Dashboards

This directory is for storing custom Grafana dashboard configurations.

## Dashboard Provisioning

Grafana automatically loads dashboard configurations from this directory on startup.

## Creating Custom Dashboards

1. Create dashboards in Grafana UI ([http://localhost:3001](http://localhost:3001))
2. Export as JSON (Dashboard settings → JSON Model)
3. Save JSON file to this directory
4. Restart Grafana to load: `make restart`

## Recommended Dashboards

### Import from Grafana.com

These dashboards can be imported by ID in Grafana:

**PostgreSQL Monitoring**:
- Dashboard ID: 9628
- URL: https://grafana.com/grafana/dashboards/9628
- Description: PostgreSQL Database monitoring

**Redis Monitoring**:
- Dashboard ID: 11835
- URL: https://grafana.com/grafana/dashboards/11835
- Description: Redis monitoring dashboard

**Node Exporter**:
- Dashboard ID: 1860
- URL: https://grafana.com/grafana/dashboards/1860
- Description: System metrics (CPU, RAM, Disk, Network)

**Docker Monitoring**:
- Dashboard ID: 893
- URL: https://grafana.com/grafana/dashboards/893
- Description: Docker container metrics

**Go Applications**:
- Dashboard ID: 10826
- URL: https://grafana.com/grafana/dashboards/10826
- Description: Go application metrics

### Custom Dashboard Examples

**Application Performance Dashboard**:
```json
{
  "dashboard": {
    "title": "Hosting Platform - Application Performance",
    "panels": [
      {
        "title": "API Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      },
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      }
    ]
  }
}
```

**Business Metrics Dashboard**:
- Active customers count
- Monthly Recurring Revenue (MRR)
- Churn rate
- New signups per day
- Failed payments
- Support ticket volume

**Infrastructure Dashboard**:
- Server resource usage (CPU, RAM, Disk)
- Database connections
- Cache hit rate
- Backup status
- SSL certificate expiry

## Dashboard Configuration Format

Create a YAML file for automatic provisioning:

```yaml
apiVersion: 1

providers:
  - name: 'Hosting Platform'
    orgId: 1
    folder: 'Hosting'
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /etc/grafana/provisioning/dashboards
```

## Alerts

Configure alerting rules in dashboards:

**Critical Alerts**:
- Database connection failures
- Disk space > 90%
- Memory usage > 90%
- API response time > 2 seconds
- Failed backups

**Warning Alerts**:
- Disk space > 80%
- Memory usage > 80%
- High error rate (> 1%)
- Slow queries

## Testing Dashboards

1. Create/edit dashboard in Grafana
2. Export JSON
3. Validate JSON syntax
4. Save to this directory
5. Reload Grafana: `docker compose restart grafana`
6. Verify dashboard loads correctly

---

**Last Updated**: 2025-11-11
