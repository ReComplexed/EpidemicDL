# EpidemicDL
Downloader for all Epidemic Sound Titles

This Tool can be used to Download Infinite 128 kb/s MP3 Files of Epidemic Sound Titles, with stems, without a limit.
### NOTE: You can still get copyright striked if you don't pay for a license  for all the channels where you use the Music at epidemicsound.com. This is for personal use only.

The Android Version only has some slight changes so that it will run on Termux without issues.

## Dependencies:
- zsh (can't be replaced with bash because zparseopts is used)
- python-eyed3 (only needed for metadata changes)
- jq (for JSON parsing)
- curl (for JSON downloading)
- wget (for Audio downloading)

## Usage

### URL Mode

You can either enter a Track URL, an Artist URL, or even a Search URL.

#### Track URL
```
./EpidemicDownload.sh https://www.epidemicsound.com/track/S15Cy93bIj/
```
