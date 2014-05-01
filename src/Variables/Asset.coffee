#include Placeholder.coffee
class Asset extends Placeholder
  constructor:->
    super("{{ *?asset[*](.*?)[*] *?}}","<?php echo assets(\"$1\") ?>","../application/assets/$1")

exports.Asset=Asset