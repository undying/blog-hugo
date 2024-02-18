---
title: "Creating PDF File From Multiple Images Of Different Sizes"
date: 2024-02-18T13:36:23+03:00
draft: false
---

```sh
export SIZE='4960x7014' && \
  convert image_* \
  -resize "${SIZE}"'^>' \
  -extent "${SIZE}" \
  -gravity center \
  -background white \
  -units PixelsPerInch \
  -density 600 result.pdf
```

`export SIZE='4960x7014'`:
  - export: This bash shell command sets the environment variable SIZE to be available to subsequent commands.
  - SIZE='4960x7014': This sets the value of the SIZE environment variable to the string 4960x7014, which represents the dimensions (width x height) for an image in pixels.

`convert image_*`:
  - convert: This is the actual ImageMagick command used for image conversion and manipulation.
  - image_*: This is a glob pattern that specifies all files in the current directory whose names start with "image_" (e.g., image_1, image_01.jpg, image_something.png, etc.).

`-resize "${SIZE}"'^>'`:
  - -resize: This is a flag that tells ImageMagick to resize the input images.
  - "${SIZE}"'^>': The environment variable SIZE is expanded here, and the outer double quotes prevent word splitting by the shell.
  - The resize parameter is followed by ^>, where the ^ modifier is used to resize the image so that it has at least one dimension (either width or height) meeting or exceeding the specified SIZE dimension, maintaining aspect ratio. The > modifier ensures that the resize operation is only performed if the original image is larger than the specified dimensions.

`-extent "${SIZE}"`:
  - -extent: This adjusts the canvas size of the image to the given dimensions. If the image is smaller, the extra canvas space will be filled with the color specified by the -background flag (see below).

`-gravity center`:
  - -gravity: This flag specifies how the image is placed relative to the canvas when -resize, -extent, or other operations that affect position are applied. center means that the image will be centered on both axes.

`-background white`:
  - -background: This sets the background color used when the canvas size is extended with the -extent flag. In this case, it's set to white.

`-units PixelsPerInch`:
  - -units: This defines the units of image resolution or density. Here it is set to PixelsPerInch which is used for setting the resolution in terms of PPI (pixels per inch).

`-density 600`:
  - -density: This option sets the image resolution or density (in this case, to 600 pixels per inch). This can affect the output size when converting to formats like PDF.

`result.pdf`:
  - This is the output filename. The convert command will compile all the matched and processed input images into a single PDF file named result.pdf.

