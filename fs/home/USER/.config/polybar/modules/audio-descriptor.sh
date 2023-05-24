#!/bin/bash

echo $(pacmd list-sink-inputs | tr '\n' '\r' | perl -pe 's/.*? *index: ([0-9]+).+?application\.name = "([^\r]+)"\r.+?(?=index:|$)/\2:\1\r/g' | tr '\r' ' ')
