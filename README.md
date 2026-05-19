# mhp3rd-audio_converter-linux

Converter mp3 to at3 for mhp3rd

## Guide

### Dependencies

1. Install `ffmpeg`
2. Install `at3tool` from "bin/"

### File Name Matching

Example from dump:
5816.wav

Example mp3:
guild_hall_5816.mp3

Convert hex:
5816 - 1 = 5815 = 0x16B7
5816 = 16B7

### How to

1. Run `./converter.sh` to auto create dir
2. Place raw audio from dump to "audio_raw/" (ex: audio_raw/5816.wav)
3. Place mp3 audio to "audio_mp3/" (ex: audio_mp3/guild_hall_5816.mp3)
4. Run `./converter.sh` to convert audio
5. Check "audio_at3/" (ex: audio_at3/16B7)

Use [Mod Manager](https://gamebanana.com/tools/19380) enable mod File Replacer.
Put the converted audio from "audio_at3/" into ".../P3RDHDML/FILES".

### References

[Kurogami2134/MHP3rd-Game-FIle-List](https://github.com/Kurogami2134/MHP3rd-Game-FIle-List/blob/main/guide/guide.md)

```text
Devuan GNU/Linux 6 (excalibur)
20260519
```
