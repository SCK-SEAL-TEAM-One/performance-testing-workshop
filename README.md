# Performance Testing Workshop

## ขั้นตอนการเตรียม Server 

### Prerequisite
- [terraform (v0.12.20)](https://www.terraform.io/downloads.html) รายละเอียดสำหรับการติดตั้งเพิ่มเติม [คลิกที่นี่](https://learn.hashicorp.com/terraform/getting-started/install)
- aws account [สมัครที่นี่](https://portal.aws.amazon.com/billing/signup)

### 1. สร้าง Access Key สำหรับใช้ในการสร้าง instance โดยไม่ต้องสร้างผ่าน UI ของ AWS  

### 2. สร้าง SSH Key ไว้ใช้สำหรับ access instance ต่างๆ 
แล้วเก็บไว้ใน directory ชื่อ deploy


### 3. Replace YOUR_ACCESS_KEY กับ YOUR_SECRET_KEY ในไฟล์ instance.tf 

```
provider "aws" {
  access_key = "<YOUR_ACCESS_KEY>"
  secret_key = "<YOUR_SECRET_KEY>"
  region     = "ap-southeast-1"
}
```

### 4. Setup Server ขึ้นมา

ทำการสั่ง terraform init เพื่อกำหนดค่าเริ่มต้นให้กับ working directory ที่ใช้งาน

```bash
terraform init
```

Output
```bash

```

### 5. Setup K8S Cluster

#### SSH to kube master

```bash
export KUBE_MASTER=<YOUR_KUBE_MASTER>
cd deploy
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER
```

#### Kubernetes Master
```bash
sudo ufw disable
sudo systemctl disable ufw
sudo kubeadm init --kubernetes-version v1.13.0 --ignore-preflight-errors=all
```

Output
```bash
```

#### Kubernetes Slave

```bash
export KUBE_SLAVE=<YOUR_KUBE_SLAVE>
ssh -i shoppingcart_key.pem ubuntu@$KUBE_SLAVE
```

```bash
sudo kubeadm join 10.0.1.122:6443 --token <token> --discovery-token-ca-cert-hash <sha256:hash_key>
```

#### Kubernetes Master

```bash
source /home/ubuntu/.bashrc

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/etcd.yaml

kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml
```

### 6. Deploy 

```bash
cd deploy/
./deploy.sh
```

### 7. J-meter setup

แก้ IP Jmeter ใน script jmeter.sh
```bash
./jmeter.sh
```
replace <KUBE_MASTER> ในไฟล์ jmeter script ที่ลงท้ายด้วย .jmx

### 8. ยิง Performance Test บน J-meter 

1) ssh เข้าไปในเครื่อง j meter

```
export JMETER=<KUBE_MASTER>
ssh -i deploy/shoppingcart_key.pem ubuntu@$JMETER
cd apache-jmeter-5.1.1/bin
```

2) รัน Performance Test

- 10 concurrent เป็นระยะเวลา 5 นาที

```
java -jar ApacheJMeter.jar -n -t concurrency-10-ramp-up-1-steps-with-in-5-min.jmx -l concurrency-10-ramp-up-1-steps-with-in-5-min.log -e -o concurrency-10-ramp-up-1-steps-with-in-5-min
```

- 100 concurrent เป็นระยะเวลา 2 นาที

```
java -jar ApacheJMeter.jar -n -t concurrency-100-ramp-up-1-steps-with-in-2-min.jmx -l concurrency-100-ramp-up-1-steps-with-in-2-min.log -e -o concurrency-100-ramp-up-1-steps-with-in-2-min
```

- 100 concurrent เป็นระยะเวลา 5 นาที

```
java -jar ApacheJMeter.jar -n -t concurrency-100-ramp-up-1-steps-with-in-5-min.jmx -l concurrency-100-ramp-up-1-steps-with-in-5-min.log -e -o concurrency-100-ramp-up-1-steps-with-in-5-min
```

### 9. Export Report
นำ report ออกมาดูในเครื่องตัวเอง

- 10 concurrent เป็นระยะเวลา 5 นาที

```
scp -i deploy/shoppingcart_key.pem ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-10-ramp-up-1-steps-with-in-5-min.log .
scp -i deploy/shoppingcart_key.pem -r ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-10-ramp-up-1-steps-with-in-5-min .
```

- 50 concurrent เป็นระยะเวลา 5 นาที

```
scp -i deploy/shoppingcart_key.pem ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-50-ramp-up-1-steps-with-in-5-min.log .
scp -i deploy/shoppingcart_key.pem -r ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-50-ramp-up-1-steps-with-in-5-min .
```

- 100 concurrent เป็นระยะเวลา 5 นาที

```
scp -i deploy/shoppingcart_key.pem ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-100-ramp-up-1-steps-with-in-5-min.log .
scp -i deploy/shoppingcart_key.pem -r ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-100-ramp-up-1-steps-with-in-5-min .
```

- 1000 concurrent โดยจะ ramp up 3 step ภายใน 5 นาที
```
scp -i deploy/shoppingcart_key.pem ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-1000-ramp-up-3-steps-arrivals-100-with-in-5-min-hold-2-min.log .
scp -i deploy/shoppingcart_key.pem -r ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin/concurrency-1000-ramp-up-3-steps-arrivals-100-with-in-5-min-hold-2-min .
```

### 10. ลบ server ทั้งหมดทิ้ง

```
terraform destroy
```