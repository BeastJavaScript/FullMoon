#include Placeholder.coffee
class If extends Placeholder
  constructor:->
    super("@if\\((.+)\\)","<?php if($1): ?>","")

exports.If=If