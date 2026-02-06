# Project Path Registry

> ⚠️ All fixed paths and configs. Read before any deployment or config operation.

## Environment URLs

| Environment | URL | Notes |
|-------------|-----|-------|
| Local Dev | `http://localhost:3000` | |
| Staging | `https://staging.example.com` | |
| Production | `https://www.example.com` | |

## Server Paths

| Item | Path |
|------|------|
| Deployment directory | `/var/www/project-name` |
| Log directory | `/var/log/project-name` |
| Config file | `/etc/project-name/config.json` |
| Data directory | `/var/data/project-name` |
| Backup directory | `/var/backups/project-name` |

## Nginx Configuration

| Item | Path/Value |
|------|------------|
| Config file | `/etc/nginx/sites-available/project-name.conf` |
| SSL certificate | `/etc/letsencrypt/live/domain/` |
| Access log | `/var/log/nginx/project-name-access.log` |
| Error log | `/var/log/nginx/project-name-error.log` |

### Common Nginx Config Directives

```nginx
# Example configuration
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

## Git Configuration

| Item | Value |
|------|-------|
| Remote (origin) | `git@github.com:username/repo-name.git` |
| Mirror (gitee) | `git@gitee.com:username/repo-name.git` |
| Main branch | `main` |
| Dev branch | `dev` |

### Branch Strategy

- `main`: Production — merges via PR only
- `dev`: Daily development
- `feature/*`: Feature branches — merge into dev when complete
- `hotfix/*`: Hotfix branches — merge into main and dev after fix

### Commit Convention

```
type: one-line description

- change 1
- change 2
```

Types: `feat` | `fix` | `refactor` | `perf` | `docs` | `chore`

## Database

| Item | Value |
|------|-------|
| Type | SQLite / MySQL / PostgreSQL |
| Local path | `./data/database.db` |
| Production path | `/var/data/project-name/database.db` |
| Backup path | `/var/backups/project-name/db/` |

### Connection String Templates

```
# SQLite
sqlite:./data/database.db

# MySQL
mysql://user:password@localhost:3306/dbname

# PostgreSQL
postgresql://user:password@localhost:5432/dbname
```

## Third-Party Services

| Service | Console/Endpoint | Docs |
|---------|-----------------|------|
| Aliyun OSS | `https://oss.console.aliyun.com` | [Docs](https://help.aliyun.com/product/31815.html) |
| Youzan Open Platform | `https://console.youzanyun.com` | [Docs](https://doc.youzanyun.com/) |
| Let's Encrypt | - | [Docs](https://letsencrypt.org/docs/) |

## Quick Commands

```bash
# Deploy
ssh user@server "cd /var/www/project-name && git pull && npm install && pm2 restart all"

# View logs
ssh user@server "tail -f /var/log/project-name/app.log"

# Restart service
ssh user@server "pm2 restart project-name"

# Backup database
ssh user@server "/var/www/project-name/scripts/backup-db.sh"

# Renew SSL certificate
ssh user@server "certbot renew --quiet"
```

---
*Last updated: YYYY-MM-DD*
*Updated by: [Feature/Reason]*
