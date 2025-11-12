# n8n Workflows

This directory contains example n8n workflow exports for the hosting platform.

## Importing Workflows

1. Access n8n at [http://localhost:5678](http://localhost:5678)
2. Go to Workflows
3. Click "Import from File"
4. Select a workflow JSON file from this directory
5. Activate the workflow

## Available Workflows

### example-invoice-workflow.json
**Purpose**: Automated invoice generation and email sending

**Trigger**: Webhook (POST /webhook/invoice-created)

**Flow**:
1. Receives webhook when invoice is created
2. Fetches invoice and customer details from PostgreSQL
3. Formats invoice data
4. Generates PDF using external API (example)
5. Sends email with PDF attachment
6. Updates invoice status to "sent"

**Setup Requirements**:
- Configure PostgreSQL connection in n8n
- Set up SMTP email sending
- Configure PDF generation service (or replace with alternative)

**Webhook URL**: `http://localhost:5678/webhook/invoice-created`

**Example payload**:
```json
{
  "invoice_id": 123
}
```

## Creating Your Own Workflows

Common use cases for the hosting platform:

### 1. Customer Onboarding
- Trigger: New customer created (webhook)
- Actions:
  - Send welcome email
  - Create default website
  - Notify admin via email/Slack
  - Add to CRM

### 2. Payment Reminders
- Trigger: Daily schedule (cron: 0 9 * * *)
- Actions:
  - Query overdue invoices
  - Send reminder emails
  - Escalate to admin if >30 days overdue

### 3. Backup Monitoring
- Trigger: Hourly schedule
- Actions:
  - Check backup status in database
  - Alert if backup failed
  - Send success summary daily

### 4. Resource Monitoring
- Trigger: Every 5 minutes
- Actions:
  - Check server resource usage
  - Alert if CPU/RAM/Disk > 80%
  - Log metrics to database

### 5. Support Ticket Routing
- Trigger: New support ticket (webhook)
- Actions:
  - Categorize ticket (AI/rules)
  - Assign to team member
  - Send confirmation email
  - Create ticket in external system

## Database Connection Setup

To connect n8n to your PostgreSQL database:

**Credentials**:
- Host: `postgres`
- Port: `5432`
- Database: `hosting_platform`
- User: `hosting_dev`
- Password: (from `.env` file)
- SSL: Disabled (development)

## SMTP Email Setup

Configure SMTP credentials in n8n:

**Settings** → **Credentials** → **New Credential** → **SMTP**

Example (using Gmail):
- Host: `smtp.gmail.com`
- Port: `587`
- User: your-email@gmail.com
- Password: App Password (not regular password)
- Secure: TLS

## Webhook Security

For production:
1. Use HTTPS only
2. Add webhook authentication (API key/secret)
3. Validate payload structure
4. Rate limit webhook calls
5. Log all webhook calls

## Exporting Workflows

To backup your workflows:

1. Open workflow in n8n
2. Click "..." menu
3. Select "Download"
4. Save JSON file to this directory
5. Commit to git

## Testing Workflows

Use the "Execute Workflow" button in n8n to test manually.

For webhook testing, use curl:
```bash
curl -X POST http://localhost:5678/webhook/invoice-created \
  -H "Content-Type: application/json" \
  -d '{"invoice_id": 123}'
```

## Monitoring

View workflow executions:
- n8n Dashboard → Executions
- Filter by status (success/error)
- View execution details and logs

## Best Practices

1. **Error Handling**: Add error handling nodes
2. **Logging**: Log important events to database
3. **Idempotency**: Make workflows safe to retry
4. **Testing**: Test with real data before activating
5. **Documentation**: Add notes to complex workflows
6. **Versioning**: Export and commit changes to git

---

**Last Updated**: 2025-11-11
