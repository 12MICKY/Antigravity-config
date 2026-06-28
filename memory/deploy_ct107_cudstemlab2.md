---
name: deploy-ct107-cudstemlab2
description: Deploy pattern for PROJECT-SERVER-CUDSTEMLAB2 (Next.js standalone) to CT107 on hypervisor — static nesting bug and fix
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 60e3a9dd-00f6-4713-bfd4-088d385d64f2
---

**Never use `cp -r src dst` when dst already exists for .next/static and public — causes nested directories.**

Correct deploy steps for PROJECT-SERVER-CUDSTEMLAB2 → CT107:

1. Build locally: `cd ~/PROJECT-SERVER-CUDSTEMLAB2 && npm run build`
2. Tar: `tar -czf /tmp/cudstemlab2-build.tar.gz .next/standalone/ .next/static/ public/`
3. SCP to hypervisor: `sshpass ... scp -P 2222 /tmp/cudstemlab2-build.tar.gz root@10.100.0.50:/tmp/`
4. Push into CT107: `pct push 107 /tmp/cudstemlab2-build.tar.gz /tmp/cudstemlab2-build.tar.gz`
5. Extract: `pct exec 107 -- mkdir -p /tmp/x && pct exec 107 -- tar -xzf /tmp/cudstemlab2-build.tar.gz -C /tmp/x`
6. Deploy — **delete target dirs first, then copy**:
   ```
   pct exec 107 -- rm -rf /opt/cudstemlab2/.next/static /opt/cudstemlab2/public
   pct exec 107 -- cp -r /tmp/x/.next/standalone/. /opt/cudstemlab2/
   pct exec 107 -- cp -r /tmp/x/.next/static /opt/cudstemlab2/.next/static
   pct exec 107 -- cp -r /tmp/x/public /opt/cudstemlab2/public
   ```
7. `pct exec 107 -- pm2 restart cudstemlab2`
8. Cleanup: `pct exec 107 -- rm -rf /tmp/x /tmp/cudstemlab2-build.tar.gz`

**Why:** `cp -r src dst` when dst exists copies src *into* dst → `.next/static/static/` nesting → JS chunks 404 → site breaks.

**How to apply:** Always delete `.next/static` and `public` on target before copying on every deploy to CT107.

Related: [[hypervisor-172-16-0-20]], [[infra-servers]]
