#!/bin/bash


# Test if there's how many images to download (must have)

if [ "$#" -ne 1 ];  then
    echo "You need to specify how many images to download!"
    exit 
fi

# Get random images

echo Downloading $1 images

rm -rf origine
mkdir origine
for (( i=1; i<=$1; i++ )) 
do
#  curl -L https://placeimg.com/900/600 > origine/img$i.jpg
#  curl -L https://placebeard.it/900/600 > origine/img$i.jpg
  curl -L https://loremflickr.com/900/600 > origine/img$i.jpg
done

# Convert/resize images jpg, webp and avif

echo Converting/resizing images

rm -rf img
mkdir img
for file in origine/*.jpg 
do
  echo -n .
  basename=$(basename "$file" .jpg)
  extension="${file##*.}"
  convert -resize 50% $file img/$basename-l.$extension
  convert -resize 50% $file img/$basename-l.webp
  convert -resize 50% $file img/$basename-l.avif
  convert -resize 25% $file img/$basename-m.$extension
  convert -resize 25% $file img/$basename-m.webp
  convert -resize 25% $file img/$basename-m.avif
  convert -resize 10% $file img/$basename-s.$extension
  convert -resize 10% $file img/$basename-s.webp
  convert -resize 10% $file img/$basename-s.avif
done

# Generate html page

echo
echo Generate html page

cat << EOF > index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <style>
        * {
            padding: 0;
            margin: 0;
        }
        
        img {
            width: 100%;
            height: auto;
        }
    </style>
</head>
<body>
EOF
cat << EOF >> index.html
<img src="img/img1-l.jpg">
<p>JPEG</p>
<img src="img/img1-l.webp">
<p>WEBP</p>
<img src="img/img1-l.avif">
<p>AVIF</p>
<hr>
<p>.</p>
EOF
for (( i=1; i<=$1; i++ ))
do
cat << EOF >> index.html
<picture>
        <source type="image/avif" media="(max-width: 599px)" srcset="img/img$i-s.avif">
        <source type="image/avif" media="(min-width: 600px) and (max-width: 1024px)" srcset="img/img$i-m.avif">
        <source type="image/avif" media="(min-width: 1025px)" srcset="img/img$i-l.avif">

        <source type="image/webp" media="(max-width: 599px)" srcset="img/img$i-s.webp">
        <source type="image/webp" media="(min-width: 600px) and (max-width: 1024px)" srcset="img/img$i-m.webp">
        <source type="image/webp" media="(min-width: 1025px)" srcset="img/img$i-l.webp">
<!--
        <img src="img/img$i-m.jpg" loading="lazy" decoding="async" width="2032" height="1076" alt="image $1 balise accessible">
-->
        <img srcset="img/img$i-s.jpg 150w, img/img$i-m.jpg 375w, img/img$i-l.jpg 750w"
            sizes="(max-width: 599px) 150px,(max-width: 1025px) 375px, 750px"
            src="img/img$i-l.jpg" loading="lazy" decoding="async" width="2032" height="1076"
            alt="image $1 balise accessible">


</picture>
EOF
done
cat << EOF >> index.html
</body>
</html>
EOF
echo open your web browser http://localhost:8080
python -m SimpleHTTPServer 8080 0.0.0.0 
