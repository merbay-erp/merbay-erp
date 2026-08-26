<!--
  PROFILE SYSTEM
  - Visual assets: .github/workflows/scripts/gen-stats.sh
  - Latest writing: .github/workflows/update-readme.yml
  Only the BLOG-POST-LIST block is replaced automatically.
-->

<div align="center">

[![Mustafa Erbay — Systems Architect, Infrastructure Engineer and Indie Hacker](https://raw.githubusercontent.com/merbay-erp/merbay-erp/output/svg-cache/hero.svg)](https://mustafaerbay.com.tr)

[![Website](https://img.shields.io/badge/Website-mustafaerbay.com.tr-0ea5e9?style=for-the-badge&logo=astro&logoColor=white)](https://mustafaerbay.com.tr)
[![English](https://img.shields.io/badge/Blog-English-10b981?style=for-the-badge&logo=googletranslate&logoColor=white)](https://mustafaerbay.com.tr/en/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-2563eb?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mustafa-e-6a891370/)
[![Email](https://img.shields.io/badge/Email-Say_Hello-ef4444?style=for-the-badge&logo=protonmail&logoColor=white)](mailto:mustafa@mustafaerbay.com.tr)

[![Profile assets](https://github.com/merbay-erp/merbay-erp/actions/workflows/cache-svgs.yml/badge.svg)](https://github.com/merbay-erp/merbay-erp/actions/workflows/cache-svgs.yml)
[![Latest writing](https://github.com/merbay-erp/merbay-erp/actions/workflows/update-readme.yml/badge.svg)](https://github.com/merbay-erp/merbay-erp/actions/workflows/update-readme.yml)

[Dashboard](#engineering-dashboard) · [Capabilities](#capability-matrix) · [Architecture](#architecture-map) · [Products](#independent-products) · [Writing](#latest-field-notes)

</div>

---

## Engineering dashboard

![Mustafa Erbay engineering dashboard](https://raw.githubusercontent.com/merbay-erp/merbay-erp/output/svg-cache/dashboard.svg)

> I own the whole path: architecture, networking, Linux, deployment, observability, product code, data and the postmortem after something catches fire.

## Capability matrix

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>🛰️ Systems &amp; Network</h3>
      Linux operations<br>
      Network architecture<br>
      Nginx · WireGuard · nftables<br>
      Performance &amp; capacity<br>
      Incident response
    </td>
    <td width="33%" valign="top">
      <h3>⚙️ Platform &amp; SRE</h3>
      Docker · Kubernetes<br>
      Self-hosted infrastructure<br>
      CI/CD · GitHub Actions<br>
      Prometheus · Grafana<br>
      Reliability engineering
    </td>
    <td width="33%" valign="top">
      <h3>🧩 Product Engineering</h3>
      Rust · Axum<br>
      TypeScript · Node.js<br>
      Astro · React · Next.js<br>
      C · Win32 · WinHTTP<br>
      PostgreSQL · PL/pgSQL<br>
      Redis · Meilisearch
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <h3>🛡️ Production Mindset</h3>
      Root-cause analysis<br>
      Security by default<br>
      Privacy-first systems<br>
      Resource efficiency<br>
      Zero-managed-service bias
    </td>
    <td width="33%" valign="top">
      <h3>🚀 Independent Builder</h3>
      Multi-tenant platforms<br>
      Data products<br>
      Browser-first utilities<br>
      Android security tools<br>
      Solo product operations
    </td>
    <td width="33%" valign="top">
      <h3>✍️ Technical Publishing</h3>
      730+ technical articles<br>
      Turkish + English<br>
      Production postmortems<br>
      Hands-on tutorials<br>
      Automated distribution
    </td>
  </tr>
</table>

## Architecture map

![Full-stack infrastructure map](https://raw.githubusercontent.com/merbay-erp/merbay-erp/output/svg-cache/architecture.svg)

<div align="center">
  <sub>One operator, one self-hosted platform, the complete path from packet to product.</sub>
</div>

---

## Independent products

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>🐢 <a href="https://burncpu.com">BurnCPU</a></h3>
      <p>Self-hosted social network with AI-assisted moderation and federation-ready foundations.</p>
      <sub>Rust · Axum · SolidJS · PostgreSQL · Redis · Meilisearch</sub>
    </td>
    <td width="33%" valign="top">
      <h3>⏱️ <a href="https://hrmarge.com">HRMarge</a></h3>
      <p>Multi-tenant time and attendance platform: multiple companies, one operating panel.</p>
      <sub>Workforce operations · Multi-tenant SaaS</sub>
    </td>
    <td width="33%" valign="top">
      <h3>📊 <a href="https://gercekveri.com">GerçekVeri</a></h3>
      <p>Anonymous, real-world salary, rent and living-cost data for Türkiye.</p>
      <sub>Data product · Privacy-first · TypeScript</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <h3>🧮 <a href="https://hesapciyiz.com">Hesapçıyız</a></h3>
      <p>34 practical calculators that run in the browser without an account.</p>
      <sub>Browser-first · No sign-up · Fast</sub>
    </td>
    <td width="33%" valign="top">
      <h3>✅ <a href="https://islistesi.com">İş Listesi</a></h3>
      <p>Free and privacy-first task management for web and mobile.</p>
      <sub>Productivity · Web + mobile</sub>
    </td>
    <td width="33%" valign="top">
      <h3>🛡️ <a href="https://spamkalkani.com">Spam Kalkanı</a></h3>
      <p>On-device Android spam-call protection designed for Türkiye.</p>
      <sub>Android · On-device · Privacy-first</sub>
    </td>
  </tr>
</table>

<div align="center">
  <b>Independent. Self-hosted. Privacy-first. Built and operated solo.</b>
</div>

### Public engineering labs

| Repository | Engineering focus |
| --- | --- |
| [SQLazy ERP Allocation POC](https://github.com/merbay-erp/sqlazy-erp-allocation-poc) | Reproducible SQLazy vs native PostgreSQL allocation benchmark with real compiler output and cross-version tests |
| [TurkM2 Launcher](https://github.com/merbay-erp/turkm2-launcher) | Native Win32 launcher and updater using WinHTTP/TLS with SHA-256 verified patching |

---

## How I operate

| 01 — Diagnose deeply | 02 — Own the platform | 03 — Automate the repeatable | 04 — Publish the lesson |
| --- | --- | --- | --- |
| Kernel, network, runtime and data—not just the symptom. | Infrastructure is part of the product, not somebody else's problem. | CI/CD, monitoring, backups and publishing pipelines become code. | Incidents turn into bilingual field notes and reusable knowledge. |

<details>
<summary><b>Battle-tested production stories</b></summary>
<br>

- OOM kills caused by 5–7 GB heaps on a 7.6 GB system.
- Docker disk pressure from 33 GB build cache and 23 GB unused images.
- `kcompactd` consuming 92% CPU and making SSH nearly unreachable.
- A self-inflicted CI runner cleanup that removed the runner itself.

</details>

## Latest field notes

<!-- BLOG-POST-LIST:START -->
- **[CrowdSec ile Davranış Tabanlı Saldırı Engelleme](https://mustafaerbay.com.tr/blog/tutorials/crowdsec-ile-davranis-tabanli-saldiri-engelleme/)** <sub>— Aug 26, 2026</sub>
- **[Yerel LLM İçin VRAM Hesabı: Model Boyutu ve Quantization Rehberi](https://mustafaerbay.com.tr/blog/tutorials/yerel-llm-icin-vram-hesabi-model-boyutu-ve-quantization-rehberi/)** <sub>— Aug 26, 2026</sub>
- **[Trivy ile Container İmaj Taraması: CI&#39;da Kırılma Eşiği](https://mustafaerbay.com.tr/blog/tutorials/trivy-ile-container-imaj-taramasi-cida-kirilma-esigi/)** <sub>— Aug 26, 2026</sub>
- **[nftables ile Modern Linux Firewall: iptables&#39;tan Geçiş](https://mustafaerbay.com.tr/blog/tutorials/nftables-ile-modern-linux-firewall-iptablestan-gecis/)** <sub>— Aug 25, 2026</sub>
- **[WireGuard ile Site-to-Site VPN: Anahtar ve Rota Tasarımı](https://mustafaerbay.com.tr/blog/tutorials/wireguard-ile-site-to-site-vpn-anahtar-ve-rota-tasarimi/)** <sub>— Aug 25, 2026</sub><!-- BLOG-POST-LIST:END -->

<div align="center">

[Türkçe yazılar](https://mustafaerbay.com.tr/blog/) · [English articles](https://mustafaerbay.com.tr/en/blog/) · [DEV](https://dev.to/merbayerp) · [Bluesky](https://bsky.app/profile/mustafaerbay.bsky.social) · [X](https://x.com/merbay86)

</div>

---

## Current operating state

| Signal | Current state |
| --- | --- |
| 🟢 **Operating** | Astro SSR, Mailcow, Umami and 26 Docker containers on a self-hosted platform |
| 🔵 **Building** | Product systems and a publishing pipeline spanning six platforms |
| 🟣 **Writing** | Bilingual production stories, tutorials and postmortems |
| 🟡 **2026 target** | A 1,000+ article technical knowledge base with full publishing autonomy |

<details>
<summary><b>Türkçe kısa profil</b></summary>
<br>

2006'dan beri üretim sistemleri, Linux, ağ ve altyapı alanlarında çalışıyorum. Tasarladığım sistemleri kendim işletiyor; Rust ve TypeScript ile bağımsız ürünler geliştiriyor; gerçek production sorunlarını Türkçe ve İngilizce teknik yazılara dönüştürüyorum. Yönetilen servis bağımlılığını azaltan, mahremiyet odaklı ve sürdürülebilir sistemleri seviyorum.

</details>

<div align="center">

### Let's build systems that survive production.

[![Follow](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github)](https://github.com/merbay-erp)
[![Email](https://img.shields.io/badge/Email-mustafa%40mustafaerbay.com.tr-ef4444?style=for-the-badge&logo=protonmail&logoColor=white)](mailto:mustafa@mustafaerbay.com.tr)

[![Build, operate, learn, share](https://raw.githubusercontent.com/merbay-erp/merbay-erp/output/svg-cache/footer.svg)](https://mustafaerbay.com.tr)

</div>
