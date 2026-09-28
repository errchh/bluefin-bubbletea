# bluefin-bubbletea

[Bluefin DX](https://github.com/ublue-os/bluefin) with Traditional Chinese input methods for Hong Kong. Built by GitHub Actions and published to GHCR, signed with cosign.

## What's added on top of Bluefin DX

- IBus input methods: Cangjie 5, Quick, Stroke5, Canton HK, Jyutping
- Defaults: US keyboard + Cangjie 5, UI language English (United Kingdom), dates/currency Hong Kong (HK$)
- Traditional Chinese fonts (Noto Sans/Serif CJK, HKSCS coverage) plus the `en_GB`, `en_HK` and `zh_HK` locales
- `podman.socket` enabled

## Switch from Bluefin

```bash
sudo bootc switch ghcr.io/errchh/bluefin-bubbletea:latest
sudo reboot
```

Your system then tracks this image (rebuilt daily at 10:05 UTC). To go back to stock Bluefin DX:

```bash
sudo bootc switch ghcr.io/ublue-os/bluefin-dx:stable
sudo reboot
```

## Verify the signature

```bash
cosign verify --pubkey cosign.pub ghcr.io/errchh/bluefin-bubbletea:latest
```
