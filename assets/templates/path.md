# 项目路径清单

> ⚠️ 此文档记录项目所有固定路径和配置。部署、配置相关操作必须先读此文档。

## 环境地址

| 环境 | 地址 | 备注 |
|------|------|------|
| 本地开发 | `http://localhost:3000` | |
| 预发环境 | `https://staging.example.com` | |
| 生产环境 | `https://www.example.com` | |

## 服务器路径

| 项目 | 路径 |
|------|------|
| 项目部署目录 | `/var/www/项目名` |
| 日志目录 | `/var/log/项目名` |
| 配置文件 | `/etc/项目名/config.json` |
| 数据目录 | `/var/data/项目名` |
| 备份目录 | `/var/backups/项目名` |

## Nginx 配置

| 项目 | 路径/值 |
|------|---------|
| 配置文件 | `/etc/nginx/sites-available/项目名.conf` |
| SSL 证书 | `/etc/letsencrypt/live/域名/` |
| 访问日志 | `/var/log/nginx/项目名-access.log` |
| 错误日志 | `/var/log/nginx/项目名-error.log` |

### 常用 Nginx 配置项

```nginx
# 示例配置
server {
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Git 配置

| 项目 | 值 |
|------|-----|
| 远程仓库 (origin) | `git@github.com:用户名/仓库名.git` |
| 备用仓库 (gitee) | `git@gitee.com:用户名/仓库名.git` |
| 主分支 | `main` |
| 开发分支 | `dev` |

### 分支策略

- `main`: 生产环境代码，只接受 PR 合并
- `dev`: 开发分支，日常开发在此
- `feature/*`: 功能分支，开发完成后合并到 dev
- `hotfix/*`: 紧急修复分支，修复后同时合并到 main 和 dev

### Commit 规范

```
类型: 一句话描述

- 改动1
- 改动2
```

类型: `feat` | `fix` | `refactor` | `perf` | `docs` | `chore`

## 数据库

| 项目 | 值 |
|------|-----|
| 类型 | SQLite / MySQL / PostgreSQL |
| 本地路径 | `./data/database.db` |
| 生产路径 | `/var/data/项目名/database.db` |
| 备份路径 | `/var/backups/项目名/db/` |

### 连接字符串模板

```
# SQLite
sqlite:./data/database.db

# MySQL
mysql://user:password@localhost:3306/dbname

# PostgreSQL
postgresql://user:password@localhost:5432/dbname
```

## 第三方服务

| 服务 | 控制台/端点 | 文档 |
|------|------------|------|
| 阿里云 OSS | `https://oss.console.aliyun.com` | [文档](https://help.aliyun.com/product/31815.html) |
| 有赞开放平台 | `https://console.youzanyun.com` | [文档](https://doc.youzanyun.com/) |
| Let's Encrypt | - | [文档](https://letsencrypt.org/docs/) |

## 常用命令速查

```bash
# 部署
ssh user@server "cd /var/www/项目名 && git pull && npm install && pm2 restart all"

# 查看日志
ssh user@server "tail -f /var/log/项目名/app.log"

# 重启服务
ssh user@server "pm2 restart 项目名"

# 备份数据库
ssh user@server "/var/www/项目名/scripts/backup-db.sh"

# SSL 证书续期
ssh user@server "certbot renew --quiet"
```

---
*最后更新: YYYY-MM-DD*
*更新者: [功能/原因]*
