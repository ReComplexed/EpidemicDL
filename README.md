# EpidemicDL
Downloader for all Epidemic Sound Titles

This Zsh Script can be used to Download Infinite 128 kb/s MP3 Files of Epidemic Sound Titles, with stems, without a limit.
### NOTE: You can still get copyright striked if you don't pay for a license  for all the channels where you use the Music at epidemicsound.com. This is for personal use only.

The Android Version only has some slight changes so that it will run on Termux without issues.

## Dependencies:
- zsh (can't be replaced with bash because zparseopts is used)
- python-eyed3 (only needed for metadata changes)
- jq (for JSON parsing)
- curl (for JSON downloading)
- wget (for Audio downloading)

# Usage
## URL Mode

You can either enter a Track URL, an Artist URL, or even a Search URL.
If you want me to add Playlist Download (Like for example the Genre Playlists like ```https://www.epidemicsound.com/music/genres/electronica-dance/```), you can tell me by creating an Issue requesting that.
```
./EpidemicDownload.sh [Options] <URL>
```

### Example Usage:
#### Track URL
```
./EpidemicDownload.sh https://www.epidemicsound.com/track/S15Cy93bIj/
```

#### Artist URL
```
./EpidemicDownload.sh https://www.epidemicsound.com/artists/agst/
```

#### Search URL
```
./EpidemicDownload.sh "https://www.epidemicsound.com/music/search/?term=agst"
```

## Manual Mode

You can search for Songs directly in this Downloader, or you can enter the complete Artist name, if you know it.
In Manual Search you will be first asked if the found Song is correct and if you want to continue downloading. This can be skipped with ```--skip-confirm / -C```

```
./EpidemicDownload.sh [Options] <Search Option> <Search Term>"
```
#### Search Options
```
--search / -S               Search for the Music Name"
--artist / -A               Enter an Artist Name"
```

### Example Usage:
#### Search
```
./EpidemicDownload.sh --search "AGST False"
```
```
./EpidemicDownload.sh --skip-confirm --search "AGST False"
```

#### Artist
```
./EpidemicDownload.sh --artist AGST
```

## Download Options
```
--help / -h                 Prints out this help
--full-search / -F          Dowloads all Search Results
--no-stems / -N             Skip Stem Downloads
--no-metadata / -M          Do not write additional Metadata
--remove-metadata / -R      Remove Metadata already added by Epidemic (Mostly used together with --no-metadata / -M)
--top-result / -T           Download only Top Result
--skip-confirm / -C         Skip Asking the User if Search Result is correct, like mentioned above
--no-picture / -P           Skip Downloading and Adding the Picture to the Metadata
--keep-picture / -K         Do not Delete Picture after adding it to the Audio Metadata
```