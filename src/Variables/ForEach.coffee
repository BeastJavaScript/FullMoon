#include Placeholder.coffee
class ForEach extends Placeholder
  constructor:->
    super("@foreach\\((.*)\\)","<?php foreach$1: ?>","")

exports.ForEach=ForEach