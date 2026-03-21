# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.


<!-- CLAWBOT_MOBILE_BEGIN -->
## Android Tools (Clawbot Mobile)

- Helper scripts live in `/root/.openclaw/workspace/mobile`. Start with `manage.sh`; docs are in `/root/.openclaw/workspace/mobile/README.md`.
- Termux entrypoints: `installer/termux/run.sh` (current) and `installer/termux/run.sh_reference` (backup).

<!-- CLAWBOT_MOBILE_END -->

