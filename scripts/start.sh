#!/bin/bash

which svelte-kit
if [[ $PORT ]]; then
	echo "Starting on port: $PORT"
	svelte-kit start --port $PORT --host 0.0.0.0
else
	svelte-kit start
fi