#!/bin/bash

trap "pkill cava" SIGUSR1
trap "pkill -f audio-visualizer/idle" SIGUSR2

while true; do sleep 1; done