\# Sumo Logic AWS Auto-Remediation



Automated monitoring and remediation system using Sumo Logic, AWS Lambda, and Terraform with least privilege IAM policies.



\## 🎯 Project Overview



This project demonstrates an end-to-end cloud security monitoring and automated remediation system that:

\- Monitors AWS EC2 instances using Sumo Logic

\- Detects high CPU utilization events

\- Automatically triggers AWS Lambda for remediation

\- Implements least privilege IAM security policies

\- Deploys infrastructure as code using Terraform



\## 🏗️ Architecture

```

Sumo Logic Query → AWS Lambda Function → EC2 Instance Restart → SNS Notification

```



\## 📂 Project Structure

```

sumo-aws-project/

├── .gitignore                      # Git ignore rules

├── README.md                       # This file

├── sumo\_logic\_query.txt           # Sumo Logic monitoring query

├── lambda\_function/

│   └── lambda\_function.py         # AWS Lambda restart function

└── terraform/

&nbsp;   ├── main.tf                    # Main infrastructure configuration

&nbsp;   ├── variables.tf               # Terraform variables

&nbsp;   └── outputs.tf                 # Terraform outputs

```



\## 🎬 Video Demonstrations



\- \*\*Part 1:\*\* \[Sumo Logic Query Setup](https://drive.google.com/file/d/1SETavWo2HCQJasL2xcEpJKUyQ6DMyp5x/view?usp=sharing)

\- \*\*Part 2:\*\* \[AWS Lambda Function](https://drive.google.com/file/d/1rO-nqhuBrpk936daZMoaTDvLFrNE5DgC/view?usp=sharing)

\- \*\*Part 3:\*\* \[Terraform Infrastructure](https://drive.google.com/file/d/1jiF7r1f-OHNFhmIp2u1q4iu-YT0aVj1J/view?usp=sharing)



\## 🔒 Security Features



\- \*\*Least Privilege IAM\*\*: Lambda function has minimal permissions (only EC2 restart and SNS publish)

\- \*\*Secure Credentials\*\*: No hardcoded AWS credentials

\- \*\*Terraform State\*\*: Infrastructure managed as code



\## 🚀 Deployment Instructions



\### Prerequisites

\- AWS Account

\- Sumo Logic Free Trial Account

\- Terraform installed

\- AWS CLI configured



\### Deploy Infrastructure

```bash

cd terraform

terraform init

terraform plan

terraform apply

```



\### Configure Sumo Logic

1\. Create a Sumo Logic free trial account

2\. Import the query from `sumo\_logic\_query.txt`

3\. Configure webhook to trigger Lambda function



\## 📊 AWS Resources Created



\- \*\*EC2 Instance\*\*: Test instance for monitoring

\- \*\*Lambda Function\*\*: `restart-ec2-terraform`

\- \*\*IAM Role\*\*: Least privilege role for Lambda

\- \*\*SNS Topic\*\*: Alert notifications

\- \*\*Region\*\*: us-east-1



\## 🧹 Cleanup



To avoid AWS charges:

```bash

cd terraform

terraform destroy

```



\## 📧 Contact



\*\*GitHub\*\*: \[rohitmk2](https://github.com/rohitmk2)



---



\*\*Project Completion Date\*\*: January 2026

