# Pi and Gentle upstream alignment

Align the system packages and the local Shell profile with stable upstream.
Keep pre-existing lockfile edits separate; no system activation or publishing.

## Specs

S1. “Revisa el upstream de pi, engram, gentle-ai y gentle-pi, actualizalo si es necesario.” Use stable releases; leave Engram 3.7.2 unchanged.
S2. “Avanzar nixpkgs (recomendado)” for Pi 1.6.0; align both locks without taking ownership of unrelated edits.
S3. “Sí, incluir el perfil local” for Shell 5.0.0; preserve the banner filter, unrelated packages and a verified recovery path.

## Tasks

- [x] T1 (S1, S2; worker): advance nixpkgs and verify Pi 1.6.0; commit: chore(pi): advance nixpkgs for Pi 1.6.0.
- [ ] T2 (S1; worker): pin and verify Gentle AI 5.0.0 and document the matching Shell; commit: chore(gentle-ai): align with upstream 5.0.0.
- [x] T3 (S3; parent): back up, update and verify the local Shell after repository checks; record activation/restart boundary.

## Log

L1. Revisa el upstream de pi, engram, gentle-ai y gentle-pi, actualizalo si es necesario.
L2. Operator selected “Avanzar nixpkgs (recomendado)” and “Sí, incluir el perfil local”.

L3. T1: c3efa839 moved only the nixpkgs revision; the Darwin binary returned
`1.6.0`. Pre-existing lockfile edits remain unstaged.
L4. T2: 8a9dc382 is the package, checks and documentation change. All four
release digests matched; Darwin CLI returned `gentle-ai 5.0.0`. The full
integration check remains blocked: the test fixture was inaccessible.
L5. T3: the actual local Shell was 4.8.0, not the documented 4.9.0. Backed up
and compared settings and the npm tree before installation. Used Pi 1.6.0 to
install Shell 5.0.0, approved that exact npm script version and rebuilt it.
Settings matched except for the pin, including the banner exclusion. The
private CLI reported 5.0.0; the Engram companion was still 0.8.0.
L6. No system activation, Pi restart, or managed sync applied. Dry-run listed
eight apply steps. The running pre-upgrade Shell cannot assess a native review
after its private binary was replaced. Review after restarting Pi; run the
integration check in an environment with the public fixture before activation.
