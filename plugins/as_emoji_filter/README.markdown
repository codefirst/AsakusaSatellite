as\_emoji\_filter
===================

This plugin enables you to use emojis in AS.

Setup
----------------

1. Set `AS_EMOJI_URL_ROOT` env variable.(e.g. `http://www.emoji-cheat-sheet.com/graphics/emojis` )

2. Restart AsakusaSatellite

Hosting on your server(Recommend)
---------------------------------

Download github emoji:

    cd /tmp
    git clone git://github.com/arvida/emoji-cheat-sheet.com.git
    mkdir -p /path/to/AsakusaSatellite/public/emoji
    mv emoji-cheat-sheet/public/graphics/*.png /path/to/AsakusaSatellite/public/emoji/

Set `http://your-domain.example.com/emoji` as `AS_EMOJI_URL_ROOT`.
