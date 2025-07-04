#!/bin/bash

export LC_NUMERIC="en_US.UTF-8"  # Force dot as decimal separator

# Parameters
url="http://127.0.0.1:8080/generate/100000000"
echo "Testing download from: $url"

# Run curl and get time and size
read time_taken bytes_downloaded <<< $(curl -s -o /dev/null -w "%{time_total} %{size_download}" "$url")

# Check if curl returned valid numbers
if [[ -z "$time_taken" || -z "$bytes_downloaded" ]]; then
  echo "Error: Failed to get time or size from curl."
  exit 1
fi

# Convert to float
time_taken=$(printf "%.3f" "$time_taken")
bytes_downloaded=$(printf "%.0f" "$bytes_downloaded")

# Avoid division by zero
if [[ "$time_taken" == "0.000" || "$bytes_downloaded" == "0" ]]; then
  echo "Error: Time or data was zero, cannot calculate speeds."
  exit 1
fi

# Calculate minutes and seconds
minutes=$(echo "$time_taken / 60" | bc)
seconds=$(echo "$time_taken - ($minutes * 60)" | bc -l)

# Size conversions
kb=$(echo "$bytes_downloaded / 1024" | bc -l)
mb=$(echo "$bytes_downloaded / 1048576" | bc -l)
gb=$(echo "$bytes_downloaded / 1073741824" | bc -l)

# Speed calculations
bytes_per_sec=$(echo "$bytes_downloaded / $time_taken" | bc -l)
bits_per_sec=$(echo "$bytes_per_sec * 8" | bc -l)

mbytes_per_sec=$(echo "$bytes_per_sec / 1048576" | bc -l)
mbits_per_sec=$(echo "$bits_per_sec / 1048576" | bc -l)

gbytes_per_sec=$(echo "$bytes_per_sec / 1073741824" | bc -l)
gbits_per_sec=$(echo "$bits_per_sec / 1073741824" | bc -l)

# Output the results
echo ""
echo "Time Taken:"
printf "\t%.2f seconds\n" "$time_taken"
printf "\t%d min %.2f sec\n" "$minutes" "$seconds"

echo ""
echo "Download size:"
printf "\t%.2f KB\n" "$kb"
printf "\t%.2f MB\n" "$mb"
printf "\t%.4f GB\n" "$gb"

echo ""
echo "Download speed:"
printf "\t%.2f Bytes/sec\n" "$bytes_per_sec"
printf "\t%.2f Bits/sec\n" "$bits_per_sec"
printf "\t%.2f MBytes/sec\n" "$mbytes_per_sec"
printf "\t%.2f MBits/sec\n" "$mbits_per_sec"
printf "\t%.4f GBytes/sec\n" "$gbytes_per_sec"
printf "\t%.4f GBits/sec\n" "$gbits_per_sec"