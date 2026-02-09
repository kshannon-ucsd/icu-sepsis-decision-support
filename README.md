# ICU Sepsis Decision Support

An interpretable early warning system for Adult ICU sepsis risk, focusing on trend analysis and 6-hour prediction windows.

## Local development

- Copy `.env.example` to `.env` and set your database credentials.
- Install dependencies: `pip install -r requirements.txt`
- Test DB connection: `python test_connection.py`
- Run migrations: `python manage.py migrate`
- Start server: `python manage.py runserver` → http://127.0.0.1:8000/patients/

## Database on AWS

The app runs locally; only the database is on AWS. Use the Terraform config in `terraform/` to create an RDS PostgreSQL instance and load MIMIC-IV. See **[terraform/README.md](terraform/README.md)** for setup and usage.
