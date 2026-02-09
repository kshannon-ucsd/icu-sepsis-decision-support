# Terraform: RDS PostgreSQL for MIMIC-IV

This folder creates an RDS PostgreSQL instance for the ICU Sepsis Decision Support app. The app runs **locally**; only the database is on AWS.

---

## Prerequisites

- **AWS CLI** configured: `aws configure`
- **Terraform** >= 1.0: [install](https://www.terraform.io/downloads) (e.g. Windows: `choco install terraform`)

---

## Setup

1. **Copy the example variables file**
   ```bash
   cd terraform
   copy terraform.tfvars.example terraform.tfvars   # Windows
   # cp terraform.tfvars.example terraform.tfvars  # Linux/macOS
   ```

2. **Edit `terraform.tfvars`**
   - `db_password` – strong password for RDS
   - `allowed_cidr_blocks` – your IP so your local machine can reach RDS (e.g. `["YOUR_IP/32"]`). Avoid `["0.0.0.0/0"]` in production.

3. **Create the database**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
   Type `yes` when prompted.

4. **Get connection details**
   ```bash
   terraform output
   ```
   Set in your local `.env`: `DB_HOST=<db_address>`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_PORT`, `DB_SCHEMA=mimiciv_derived`.

---

## Outputs

| Output | Description |
|--------|-------------|
| `db_endpoint` | Hostname:port |
| `db_address` | Hostname only (use for `DB_HOST`) |
| `db_port` | 5432 |
| `db_name` | Database name |
| `security_group_id` | For updating who can connect |

---

## Load MIMIC-IV

After RDS is created:

- **From a local dump**: `pg_dump` your existing MIMIC-IV DB, then `pg_restore` to the RDS endpoint (use the same user/password from `terraform.tfvars`).
- **From CSV**: Upload MIMIC-IV CSVs to S3 or a machine that can reach RDS, then run the MIT-LCP mimic-code Postgres load scripts. Create the `mimiciv_derived` schema and your materialized views (`fisi9t_unique_patient_profile`, etc.) as in your current setup.

---

## Restrict access

To allow only your IP:

- Set `allowed_cidr_blocks` in `terraform.tfvars` to e.g. `["YOUR_IP/32"]`.
- Run `terraform apply` to update the security group.

---

## Destroy (deletes RDS and all data)

```bash
cd terraform
terraform destroy
```

---

## Cost (rough)

- **Free tier (12 months)**: db.t4g.micro + 20 GB → $0/month
- **After**: ~$18–25/month (small instance + ~50 GB)

---

## Troubleshooting

- **No default VPC**: Create a VPC or reference an existing one in the Terraform config.
- **Insufficient permissions**: Ensure AWS credentials have RDS, EC2, and VPC permissions.
- **DB instance already exists**: Check for an existing instance with the same identifier in the same region.

---

## Later: full cloud deployment

When you want to run the app on AWS too:

1. Create a **Lightsail** instance (or small EC2).
2. Attach a **Lightsail static IP** (or Elastic IP on EC2) so the URL doesn’t change.
3. On the instance: install Python, clone repo, set env vars (or SSM), run Django with **gunicorn + nginx**.
4. Update the RDS security group so the Lightsail/EC2 instance can reach PostgreSQL (add its IP or security group to `allowed_cidr_blocks` or an ingress rule).

Detailed steps for Lightsail + gunicorn + nginx can be added here when you’re ready.
