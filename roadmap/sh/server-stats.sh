#! /usr/bin/env bash

# Total CPU usage
cpu_usage() {
  # With fallback version.
  # local lines=${1:-10} # default value of 10

  # awk -v n="$lines" 'BEGIN { print n }'

  # ps -eo pcpu,pid,args | awk -v n="$lines" '
  #   NR==1 {print; next}
  #   { print | "sort -k 1 -r | head -" n }
  # '

  local lines=$1
  if [[ -z $lines ]]; then
    ps -eo pid,comm,pcpu
  else
    ps -eo pid,comm,pcpu | awk 'NR==1'
    ps -eo pid,comm,pcpu | awk 'NR>1' | sort -k3 -rn | head -n "$lines"
  fi

  printf "\n\n"
}

# Total memory usage (Free vs Used including percentage)
memory_usage() {
  local lines=$1
  local os=$(uname)

  if [[ $os == "Darwin" ]]; then
    # macOS
    if [[ -z $lines ]]; then
      vm_stat
    else
      vm_stat | head -n "$lines"
    fi
    # ps -eo rss,vsz,command | awk '
    # NR==1 {print "RSS(M)", "VSZ(M)", "COMMAND"; next }
    # {
    #   $1=int($1/1024)"M";
    #   $2=int($2/1024)"M";
    #   print | "sort -k 1 -rn | head -10"
    # }
    # '
  elif [[ $os == "Linux" ]]; then
    # Linux
    if [[ -z $lines ]]; then
      free -h
    else
      free -h | head -n "$lines"
    fi
  else
    echo "Unsupported OS: $os"
  fi
  printf "\n\n"
}

# Total disk usage (Free vs Used including percentage)
disk_usage() {
  df -ah
  printf "\n\n"
}

# Top 5 processes by CPU usage
top_mem() {
  local lines=${1:-5}

  ps -axo pid,comm,%mem | awk 'NR==1'
  ps -axo pid,comm,%mem | awk 'NR>1' | sort -k3 -rn | head -n "$lines"

  printf "\n\n"
}

# Top 5 processes by memory usage

cpu_usage
memory_usage
disk_usage
cpu_usage 5
top_mem 10
