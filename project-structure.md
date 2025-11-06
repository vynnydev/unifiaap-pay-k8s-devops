# 📁 Estrutura Completa do Projeto - UniFIAP Pay com EKS

## Estrutura Final com Terraform

```
unifiaap-pay-eks/
│
├── 📄 README.md                           # Documentação principal
├── 📄 .gitignore                          # Ignorar arquivos sensíveis
├── 📄 Makefile                            # Comandos automatizados
│
├── 📂 src/                                # Código da aplicação
│   ├── app.py
│   └── requirements.txt
│
├── 📂 docker/                             # Docker configs
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── init-db.sql
│   └── nginx.conf
│
├── 📂 terraform/                          # ⭐ INFRAESTRUTURA AWS
│   ├── main.tf                           # Configuração principal
│   ├── variables.tf                      # Variáveis de entrada
│   ├── outputs.tf                        # Outputs (endpoints, etc)
│   ├── versions.tf                       # Versões do Terraform/Providers
│   ├── terraform.tfvars                  # Valores das variáveis
│   │
│   ├── 📂 modules/                       # Módulos Terraform
│   │   ├── 📂 vpc/                       # VPC e Networking
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── 📂 eks/                       # Cluster EKS
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── 📂 rds/                       # PostgreSQL RDS
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── 📂 ecr/                       # Container Registry
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   └── 📂 environments/                  # Ambientes
│       ├── dev.tfvars                    # Desenvolvimento
│       └── prod.tfvars                   # Produção
│
├── 📂 k8s/                                # Manifests Kubernetes
│   ├── 01-namespace.yaml
│   ├── 02-configmap.yaml
│   ├── 03-secrets.yaml
│   ├── 04-pv-pvc.yaml                    # (Usar EBS no EKS)
│   ├── 05-postgres-deployment.yaml       # (Ou usar RDS)
│   ├── 06-api-deployment.yaml
│   ├── 07-job-cronjob.yaml
│   ├── 08-daemonset.yaml
│   ├── 09-rbac.yaml
│   ├── 10-network-policy.yaml
│   ├── 11-hpa-quotas.yaml
│   ├── deploy.sh
│   └── verify.sh
│
├── 📂 scripts/                            # Scripts de automação
│   ├── setup-aws.sh                      # Configurar credenciais AWS
│   ├── build-and-push-ecr.sh            # Build e push para ECR
│   ├── deploy-eks.sh                     # Deploy no EKS
│   ├── destroy-infra.sh                  # Destruir infraestrutura
│   └── test-api.sh                       # Testar API
│
└── 📂 docs/                               # Documentação
    ├── AWS-SETUP.md                      # Como configurar AWS
    ├── TERRAFORM-GUIDE.md                # Guia Terraform
    ├── EKS-DEPLOY.md                     # Deploy no EKS
    └── evidencias/                       # Screenshots
        └── README.md
```