#!/bin/sh
set -e

# ถ้าต่อกับ docker.sock ให้เอา GID แล้วเพิ่ม user jenkins เข้าใน group นั้น
if [ -S /var/run/docker.sock ]; then
  GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || stat -f '%g' /var/run/docker.sock 2>/dev/null || true)
  if [ -n "$GID" ]; then
    EXISTING_GROUP=$(getent group "$GID" | cut -d: -f1 || true)
    if [ -n "$EXISTING_GROUP" ]; then
      # เพิ่ม jenkins ไปยังกลุ่มที่มี GID นั้น
      echo "Adding jenkins to existing group: $EXISTING_GROUP (GID=$GID)"
      /usr/sbin/usermod -aG "$EXISTING_GROUP" jenkins || true
    else
      # ถ้าไม่มี group ชื่อไว้ สร้างชื่อ dockersock แล้วเพิ่ม
      echo "Creating group 'dockersock' with GID $GID and adding jenkins"
      /usr/sbin/groupadd -g "$GID" dockersock || true
      /usr/sbin/usermod -aG dockersock jenkins || true
    fi
  fi
fi

# ให้สิทธิ์ /var/jenkins_home เป็น jenkins เพื่อป้องกันไฟล์ที่เกิดจาก root
chown -R jenkins:jenkins /var/jenkins_home || true

# เรียก entrypoint ของ image ดั้งเดิม (เสมือนรัน Jenkins ปกติ)
exec /usr/local/bin/jenkins.sh "$@"
