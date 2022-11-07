#!/usr/bin/env bash

wget --header="accept-encoding: gzip" -p -k https://www.pole-emploi.fr/accueil/
cd www.pole-emploi.fr

rm -r work-img-optim/*
mkdir -p work-img-optim/{jpg,gif,png}

# Copie des fichiers dans leur répertoire respectif
find . -iname *.jpg | xargs -i cp '{}' work-img-optim/jpg/
find . -iname *.png | xargs -i cp '{}' work-img-optim/png/
find . -iname *.gif | xargs -i cp '{}' work-img-optim/gif/
mkdir work-img-optim/tout-en-jpg
mkdir work-img-optim/tout-en-webp
mkdir work-img-optim/tout-en-avif

# Copie des fichiers dans le même répertoire et convertion
  # copie jpg
find work-img-optim/jpg/ -name *.jpg | xargs -i cp '{}' work-img-optim/tout-en-jpg/
  # convertion jpg -> webp
for filename in work-img-optim/jpg/*.jpg; do
    basename="$(basename "$filename" .jpg)"
    cwebp -q 84 -af $filename -o work-img-optim/tout-en-webp/$basename.webp
    avifenc -j all --codec aom --yuv 420 --min 20 --max 25 $filename work-img-optim/tout-en-avif/$basename.avif
done
  # convertion png
for filename in work-img-optim/png/*.png; do
    basename="$(basename "$filename" .png)"
    convert "work-img-optim/png/$basename.png" "work-img-optim/tout-en-jpg/$basename.jpg"
    cwebp -q 84 -af $filename -o work-img-optim/tout-en-webp/$basename.webp
    avifenc -j all --codec aom --yuv 420 --min 20 --max 25 $filename work-img-optim/tout-en-avif/$basename.avif
done
  # convertion gif vers jpg vers webp
for filename in work-img-optim/gif/*.gif; do
    basename="$(basename "$filename" .gif)"
    if [ `identify "$filename" | wc -l` -eq 1 ] ; then
        convert "work-img-optim/gif/$basename.gif" "work-img-optim/tout-en-jpg/$basename.jpg"
        cwebp -q 84 -af "work-img-optim/tout-en-jpg/$basename.jpg" -o work-img-optim/tout-en-webp/$basename.webp
        avifenc -j all --codec aom --yuv 420 --min 20 --max 25 "work-img-optim/tout-en-jpg/$basename.jpg" work-img-optim/tout-en-avif/$basename.avif
    fi
done

# Optimisation des jpg à 84% max
find work-img-optim/tout-en-jpg/ -type f -name '*.jpg' -print0 \
  | xargs -0n10 -P$(nproc) jpegoptim --max=84 --all-progressive --strip-all

# Affichage gain
printf "|%4s|%4s|%4s|%60s|\n" "---------" "---------" "---------" "------------------------------------------------------------"
printf "|%4s|%4s|%4s|%60s|\n" "Gain jpeg" "Gain webp" "Gain avif" "Nom"
printf "|%4s|%4s|%4s|%60s|\n" "---------" "---------" "---------" "------------------------------------------------------------"
for filename in work-img-optim/jpg/*.jpg; do
  basename="$(basename "$filename" .jpg)"
  orig=$(stat --format %s $filename)
  newjpeg=$(stat --format %s work-img-optim/tout-en-jpg/$basename.jpg )
  newwebp=$(stat --format %s work-img-optim/tout-en-webp/$basename.webp )
  newavif=$(stat --format %s work-img-optim/tout-en-avif/$basename.avif )
  gainjpeg=$((100-(newjpeg*100/orig)))
  gainwebp=$((100-(newwebp*100/orig)))
  gainavif=$((100-(newavif*100/orig)))
  printf "|   %4d%% |   %4d%% |   %4d%% |%60s|\n" $gainjpeg $gainwebp $gainavif "$basename.jpg"
done
printf "|%4s|%4s|%4s|%50s|\n" "---------" "---------" "---------" "------------------------------------------------------------"
for filename in work-img-optim/png/*.png; do
  basename="$(basename "$filename" .png)"
  orig=$(stat --format %s $filename)
  newjpeg=$(stat --format %s work-img-optim/tout-en-jpg/$basename.jpg )
  newwebp=$(stat --format %s work-img-optim/tout-en-webp/$basename.webp )
  gainjpeg=$((100-(newjpeg*100/orig)))
  gainwebp=$((100-(newwebp*100/orig)))
  printf "|   %4d%% |   %4d%% |   %4d%% |%60s|\n" $gainjpeg $gainwebp $gainavif "$basename.png"
done
printf "|%4s|%4s|%4s|%50s|\n" "---------" "---------" "---------" "------------------------------------------------------------"
for filename in work-img-optim/gif/*.gif; do
    if [ `identify "$filename" | wc -l` -eq 1 ] ; then
        basename="$(basename "$filename" .gif)"
        orig=$(stat --format %s $filename)
        newjpeg=$(stat --format %s work-img-optim/tout-en-jpg/$basename.jpg )
        newwebp=$(stat --format %s work-img-optim/tout-en-webp/$basename.webp )
        gainjpeg=$((100-(newjpeg*100/orig)))
        gainwebp=$((100-(newwebp*100/orig)))
        printf "|   %4d%% |   %4d%% |   %4d%% |%60s|\n" $gainjpeg $gainwebp $gainavif "$basename.gif"
    fi
done
printf "|%4s|%4s|%4s|%60s|\n" "---------" "---------" "---------" "------------------------------------------------------------"
