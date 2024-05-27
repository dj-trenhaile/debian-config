#!/bin/bash

active() {
    pkill -f audio-visualizer/idle
}

idle() {
    pkill -f cava
}

