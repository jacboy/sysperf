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
2. Merge to `master`. Cloudflare Pages rebuilds the site; the page shows the new version and checksum, and `/bench` serves the new script.

## Test deployment: sysperf.jf-l.de (Cloudron Surfer)

`.github/workflows/deploy-test.yml` builds the site with `SITE_URL=https://sysperf.jf-l.de` (so the commands on the page point to the test instance) and publishes it with `surfer deploy`, which replaces the whole site. It runs on every push to `master` that changes `bench`, `site/` or the workflow, and can be started by hand under *Actions → Deploy test site → Run workflow*. After deploying it checks that the live `/bench` is byte-identical to the build and that the page shows the new version.

One-time setup:

1. In the Cloudron dashboard, *Profile → App passwords*: create an app password for the Surfer app.
2. In GitHub, *Settings → Secrets and variables → Actions → New repository secret*, add:
   - `SURFER_USERNAME`: the Cloudron username
   - `SURFER_APP_PASSWORD`: the app password from step 1

Differences from Cloudflare Pages: Surfer doesn't read `_headers` (the workflow leaves it out), so the test site doesn't get the custom CSP and `/bench` isn't necessarily served as `text/plain`. `curl … | bash` works either way.

## Cloudflare Pages setup (one-time)

The DNS for getsysperf.com is already on Cloudflare, so everything happens in the same account.

1. **Remove old records.** In *DNS → Records*, delete the existing `A` and `AAAA` records for `getsysperf.com` that point to the old Hetzner server, if that server is no longer yours.
2. **Create the project.** *Workers & Pages → Create → Pages → Connect to Git*, choose `jacboy/sysperf`.
   - Production branch: `master`
   - Framework preset: *None*
   - Build command: `bash site/build.sh`
   - Build output directory: `dist`
3. **Check the preview.** After the first deploy, open `https://<project>.pages.dev/` and test:
   ```bash
   curl -fsSL https://<project>.pages.dev/bench | head -5
   curl -sI https://<project>.pages.dev/bench | grep -i content-type
   ```
4. **Add the domain.** In the project, *Custom domains → Set up a custom domain → `getsysperf.com`*. Cloudflare creates the DNS record itself. Optionally add `www.getsysperf.com` and redirect it to the apex domain (*Rules → Redirect Rules*).
5. **Force HTTPS.** *SSL/TLS → Edge Certificates*: enable *Always Use HTTPS*.

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

  and remove the old `MX` record.

## After the domain is live

Switch the commands in the main [README](../README.md) from `raw.githubusercontent.com/jacboy/sysperf/master/bench` to `https://getsysperf.com/bench`.
