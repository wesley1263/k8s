# Ansible Kubernetes Setup

Este projeto Ansible configura um cluster Kubernetes e o `kubectl` para se conectar a ele. A estrutura do projeto segue as melhores práticas para facilitar a manutenção e a escalabilidade.

## Estrutura de Diretórios

```
ansible-project/
├── ansible.cfg
├── hosts
├── group_vars/
│   └── all.yml
├── roles/
│   └── kubernetes/
│       ├── tasks/
│       │   └── main.yml
│       ├── templates/
│       ├── files/
│       ├── vars/
│       │   └── main.yml
│       ├── defaults/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       ├── meta/
│       │   └── main.yml
│       └── README.md
├── vars.yml
├── kubernetes_setup.yml
└── README.md
```

## Arquivos e Diretórios

### `ansible.cfg`

Arquivo de configuração do Ansible.

```ini
[defaults]
inventory = hosts
```

### `hosts`

Arquivo de inventário contendo os hosts a serem gerenciados.

```ini
[kubernetes]
kubernetes-master ansible_host=34.173.118.176

[kubernetes:vars]
kubernetes_cluster_name=devops-cluster
kubernetes_cluster_endpoint=34.173.118.176
```

### `group_vars/all.yml`

Variáveis globais aplicáveis a todos os hosts.

```yaml
# Este arquivo pode conter variáveis globais adicionais
```

### `roles/`

Diretório contendo as funções do Ansible. Cada função é um conjunto de tarefas relacionadas.

#### `roles/kubernetes/`

Função para configurar Kubernetes.

##### `tasks/main.yml`

Contém as tarefas que a função executará.

```yaml
---
- name: Ensure kubectl is installed
  apt:
    name: kubectl
    state: present
  become: yes

- name: Configure kubectl to connect to the cluster
  command: >
    kubectl config set-cluster {{ kubernetes_cluster_name }} 
    --server=https://{{ kubernetes_cluster_endpoint }}
    --insecure-skip-tls-verify=true

- name: Configure kubectl to use context
  command: >
    kubectl config set-context {{ kubernetes_cluster_name }} 
    --cluster={{ kubernetes_cluster_name }} 
    --user=default

- name: Use the new context
  command: >
    kubectl config use-context {{ kubernetes_cluster_name }}
```

##### `templates/`

Contém arquivos de template (Jinja2) usados na função.

##### `files/`

Contém arquivos estáticos usados pela função.

##### `vars/main.yml`

Variáveis específicas para a função.

##### `defaults/main.yml`

Variáveis padrão para a função.

##### `handlers/main.yml`

Manipuladores de eventos (notificações).

##### `meta/main.yml`

Metadados da função.

##### `README.md`

Documentação da função.

### `vars.yml`

Arquivo de variáveis globais adicionais.

```yaml
# Adicione outras variáveis aqui, se necessário
```

### `kubernetes_setup.yml`

Playbook principal que executa as tarefas.

```yaml
---
- hosts: kubernetes
  vars_files:
    - vars.yml
  roles:
    - kubernetes
```

## Executar o Playbook

Para executar o playbook, use o seguinte comando:

```bash
ansible-playbook kubernetes_setup.yml
```

Isso configurará o `kubectl` para se conectar ao seu cluster Kubernetes no GCP usando o arquivo de inventário `hosts`.

## Passos Adicionais

### Instalar o Google Cloud SDK

Se ainda não instalou o Google Cloud SDK, faça isso seguindo as instruções [aqui](https://cloud.google.com/sdk/docs/install).

### Autenticar no GCP

Autentique-se na sua conta do Google Cloud:

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Obter Credenciais para o Cluster GKE

Obtenha as credenciais do cluster GKE:

```bash
gcloud container clusters get-credentials YOUR_CLUSTER_NAME --zone YOUR_CLUSTER_ZONE
```

Substitua `YOUR_CLUSTER_NAME` pelo nome do seu cluster e `YOUR_CLUSTER_ZONE` pela zona onde seu cluster está localizado (por exemplo, `us-central1-a`).

### Verificar a Conexão com o Cluster

Verifique se o `kubectl` está configurado corretamente e conectado ao cluster:

```bash
kubectl get nodes
```

Com esses passos, você terá configurado o `kubectl` para se conectar ao seu cluster Kubernetes no GCP usando um arquivo `hosts` de inventário do Ansible.