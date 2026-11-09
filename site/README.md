# getsysperf.com

The landing page for sysperf. It serves the page at `https://getsysperf.com/` and the script at `https://getsysperf.com/bench`, both built from the same commit of this repository.

## Files

| File | Purpose |
|---|---|
| `index.html`, `style.css`, `copy.js`, `favicon.svg` | The page. No external fonts, scripts, analytics or cookies. |
| `_headers` | Response headers for Cloudflare Pages: HSTS, a strict Content-Security-Policy, and `text/plain` + `no-cache` for `/bench`. |
| `build.sh` | Builds the site into `dist/`: copies the page, copies `../bench` to `/bench`, writes `/bench.sha256`, and fills in the version and checksum. Fails if `bench` has a syntax error or no `SYSPERF_VERSION`. |

Build and preview locally:

```bash
bash site/build.sh
python3 -m http.server -d dist 8000
```

## Releasing a new version

1. Change `bench` and raise `SYSPERF_VERSION` in it.
2. Merge to `master`. The *Deploy site* GitHub Action (`.github/workflows/deploy.yml`) builds the site, uploads it to Cloudflare Pages and checks that the live `/bench` matches the build. The page then shows the new version and checksum.

## How it's hosted

- **Cloudflare Pages project `sysperf`** (Direct Upload) in "Iandavid2000@googlemail.com's Account", which also holds the `getsysperf.com` zone. It's served at `https://sysperf.pages.dev` and, as custom domain, `https://getsysperf.com`.
- **Deployments come only from GitHub Actions** (`.github/workflows/deploy.yml`), on every push to `master` that changes `bench`, `site/` or the workflow, or by hand under *Actions → Deploy site → Run workflow*.
- **GitHub secret `CLOUDFLARE_API_TOKEN`:** an account API token with only *Account · Cloudflare Pages · Edit* for that account. No DNS or zone permissions.
- **DNS:** `getsysperf.com CNAME sysperf.pages.dev`, proxied. The Pages API doesn't create this record by itself; the dashboard does when you add the domain there.

## Securing the domain

Everyone who runs the one-liner trusts whoever controls this domain, the Cloudflare account and the GitHub repository. Before announcing the URL:

- **2FA** on the Cloudflare account, the registrar account (Registrar.eu / Openprovider) and the GitHub account.
- **DNSSEC:** *DNS → Settings → Enable DNSSEC* in Cloudflare, then add the shown DS record at the registrar.
- **Branch protection** for `master` on GitHub (require a pull request), so nothing reaches `/bench` unreviewed.
- **No mail on this domain:** if no e-mail is sent from it, add these records so nobody can send e-mail in its name:

  | Type | Name | Content |
  |---|---|---|
  | TXT | `@` | `v=spf1 -all` |
  | TXT | `_dmarc` | `v=DMARC1; p=reject;` |

  (The old `A`, `AAAA` and `MX` records have already been removed.)

## After the domain is live

Switch the commands in the main [README](../README.md) from `raw.githubusercontent.com/jacboy/sysperf/master/bench` to `https://getsysperf.com/bench`.
