#!/bin/bash

which svelte-kit
if [[ $PORT ]]; then
	echo "Starting on port: $PORT"
	svelte-kit start -p $PORT
else
	svelte-kit start
fi