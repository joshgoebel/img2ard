img2ard
=======

Meant for usage with [Arduboy](http://community.arduboy.com) and drawImage.  This tool compiles a full folder of `png` files into a single `assets.h` file of character arrays in PROGMEM suitable for passing to the core libraries drawBitmap function.

## Installation

Requires Ruby 2.0+.

```
gem install chunky_png
# clone git repository and put img2ard.rb in your path
```

Yes, I need to convert this to a Ruby gem, but so much to do.

## Usage

```
cd source_folder
ls assets
./img2ard.rb
cat assets.h
```

After compiling all your `assets` will be locating in `assets.h` and ready for use in your sketch.
