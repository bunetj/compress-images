# compress images

i hope it works.

made for the case of hoarding - many similar or replaceable images - and limited cloud storage.

see # rational compression below to not compress valuable stuff.

## dependencies

- ffmpeg
- magick

## commands

```
-s n    files > n MB
-r n    files > n * 1000 px in resolution
-resize 50% by default
-p n    resize by percent
-jpg
-q  quality for jpg

-replace    overwrites. otherwise backs up
-recurse    looks in subfolders
```

another compression method is a slideshow. options:

1. a video editor, eg shotcut

2. screen-recording a slideshow, eg: xnview > slideshow (can display specified metadata) + obs

3. slideshow.ps1 (if same resolution)

## efficiency

jpg: a no-minder for useless images, up to 95%

resize: for large images (>2-3k)

slideshow: somth. like 1gb to 200mb

## rational compression

commands let you select only those files that are optimal for compression. make backups.

find heavy images in the system, eg in everything app search `image: size:>2mb`

sizes.md shows optimal sizes

⚠⚠⚠ these types of images must not be compressed:

- small or handwritten text, drawn lines --> pixelated to less readable or fine
- transparent background or elements - jpg -> colored
- fine or valuable images -> pixelated shades and image
- small resolution -> pixelated to lower quality

## typical commands

```
.\cmpr_IMGs.ps1 -jpg
.\cmpr_IMGs.ps1 -jpg -recurse
.\cmpr_IMGs.ps1 -jpg -s 1
.\cmpr_IMGs.ps1 -jpg -s 1 -recurse
.\cmpr_IMGs.ps1 -resize
.\cmpr_IMGs.ps1 -resize -r 2
.\cmpr_IMGs.ps1 -bit8
```


## alternatives

apps like caesium overload my computer.

i didn't search scripts like this and didn't find a similar script quickly.

## other media

video, audio, pdf. (not elaborated options.)
