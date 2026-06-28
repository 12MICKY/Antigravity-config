---
name: workflow-patterns
description: "Recurring patterns and gotchas learned from working with Thiraphat's infra"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f39abe6d-5c79-429f-8b8d-77c106836446
---

## Deploy new web service on .34
1. `docker run -d --name <n> --restart unless-stopped -p <port>:80 <image>`
2. Add entry to `/etc/cloudflared/config.yml` (via sudo python3)
3. `docker restart cloudflared`
4. Add DNS: `docker run --rm -v ~/.cloudflared:/home/nonroot/.cloudflared:ro cloudflare/cloudflared tunnel route dns <tunnel-id> <sub>.thiraphat.work`

## Remove a service completely
1. `docker stop <name> && docker rm <name>`
2. `docker rmi <image>` (if no other containers use it)
3. `rm -rf` any data directories
4. Remove entry from `/etc/cloudflared/config.yml`
5. `docker restart cloudflared`
6. (Optionally) delete DNS record from Cloudflare dashboard

## Cloudflared config editing pattern
```python
echo '200152' | sudo -S python3 -c "
with open('/etc/cloudflared/config.yml', 'r') as f:
    content = f.read()
# modify content
with open('/etc/cloudflared/config.yml', 'w') as f:
    f.write(content)
"
```

## Docker Swarm config immutability
Swarm configs cannot be updated in-place. Use SHA-versioned names:
```bash
sed "s/_v[0-9]*/_${SHA}/g" swarm-stack.yml > stack-deploy.yml
docker stack deploy -c stack-deploy.yml <stack>
```

## GitHub Actions workflow_dispatch
```bash
curl -X POST "https://api.github.com/repos/12MICKY/<repo>/actions/workflows/deploy.yml/dispatches" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{"ref":"main"}'
```

## ntopng password reset
ntopng uses MD5 hash in Redis:
```bash
redis-cli set 'ntopng.user.admin.password' "$(python3 -c "import hashlib; print(hashlib.md5('admin'.encode()).hexdigest())")"
```

## Port conflicts on .34
Port 8083 is occupied by dockerd (veth interfaces). Use 8084+ for new services.

## shellcheck on Ubuntu focal (old 0.7.0)
- SC1007 false positive on `CDPATH=` — add `# shellcheck disable=SC1007`
- SC2012 false positive on `ls` in pipelines — add `# shellcheck disable=SC2012`

**Why:** These patterns come up repeatedly. Knowing them in advance avoids debugging cycles.
