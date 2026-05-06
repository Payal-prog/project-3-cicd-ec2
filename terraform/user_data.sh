#!/bin/bash
dnf update -y
dnf install -y docker

systemctl start docker
systemctl enable docker

docker pull ${docker_image}

docker stop project-3-web || true
docker rm project-3-web || true

docker run -d \
  --restart unless-stopped \
  -p 8080:80 \
  --name project-3-web \
  ${docker_image}

sleep 10

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
http://169.254.169.254/latest/meta-data/instance-id)

PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
http://169.254.169.254/latest/meta-data/local-ipv4)

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
http://169.254.169.254/latest/meta-data/placement/availability-zone)

docker exec project-3-web sh -c "sed -i \
  -e \"s/__INSTANCE_ID__/$${INSTANCE_ID}/g\" \
  -e \"s/__PRIVATE_IP__/$${PRIVATE_IP}/g\" \
  -e \"s/__AZ__/$${AZ}/g\" \
  /usr/share/nginx/html/index.html /usr/share/nginx/html/health.html"