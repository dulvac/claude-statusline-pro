#!/bin/bash

# Claude Statusline Pro - A rich status bar for Claude Code
# Shows: project dir, git branch, session time, model name, context usage bar

# Read JSON input from stdin
input=$(cat)

# Extract data using jq
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Get git branch if in a git repo
branch=""
if [ -n "$project_dir" ] && [ -d "$project_dir/.git" ]; then
  branch=$(cd "$project_dir" && git branch --show-current 2>/dev/null)
fi

# Calculate time spent in this session
time_spent=""
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    start_time=$(stat -f %B "$transcript_path" 2>/dev/null)
  else
    start_time=$(stat -c %W "$transcript_path" 2>/dev/null)
  fi

  if [ -n "$start_time" ] && [ "$start_time" -gt 0 ] 2>/dev/null; then
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    hours=$((elapsed / 3600))
    minutes=$(( (elapsed % 3600) / 60 ))

    if [ $hours -gt 0 ]; then
      time_spent="${hours}h ${minutes}m"
    else
      time_spent="${minutes}m"
    fi
  fi
fi

# ANSI color codes
RST=$'\033[0m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
MAGENTA=$'\033[35m'
RED=$'\033[31m'
DIM=$'\033[2m'

SEP="${DIM} │ ${RST}"

# Build status line components
components=()

if [ -n "$project_dir" ]; then
  dir_name=$(basename "$project_dir")
  components+=("${CYAN}📁 ${dir_name}/${RST}")
fi

if [ -n "$branch" ]; then
  components+=("${GREEN}🌿 ${branch}${RST}")
fi

if [ -n "$time_spent" ]; then
  components+=("${YELLOW}⏱️  ${time_spent}${RST}")
fi

if [ -n "$model_name" ]; then
  components+=("${MAGENTA}${model_name}${RST}")
fi

# Default to 100% remaining (0% used) when no messages have been sent yet
if [ -n "$remaining" ]; then
  remaining_int=$(printf "%.0f" "$remaining")
else
  remaining_int=100
fi
used=$((100 - remaining_int))

# Pick bar color based on usage
if [ "$used" -lt 50 ]; then
  BAR_COLOR="$GREEN"
elif [ "$used" -lt 75 ]; then
  BAR_COLOR="$YELLOW"
else
  BAR_COLOR="$RED"
fi

bar_len=10
filled=$(( used * bar_len / 100 ))
empty=$(( bar_len - filled ))
bar=""
[ "$filled" -gt 0 ] && bar=$(printf '%0.s█' $(seq 1 $filled))
[ "$empty" -gt 0 ] && bar+=$(printf '%0.s░' $(seq 1 $empty))

# Extract context window size
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

# Calculate total tokens used from remaining percentage and context window size
if [ -n "$remaining" ] && [ "$context_size" -gt 0 ]; then
  total_tokens=$(echo "$remaining $context_size" | awk '{printf "%d", $2 * (100 - $1) / 100}')
else
  total_tokens=0
fi

# Abbreviate token counts (e.g., 150000 -> "150k", 1200000 -> "1.2m")
abbreviate_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    local whole=$((n / 1000000))
    local frac=$(( (n % 1000000) / 100000 ))
    if [ "$frac" -gt 0 ]; then
      echo "${whole}.${frac}m"
    else
      echo "${whole}m"
    fi
  elif [ "$n" -ge 1000 ]; then
    local whole=$((n / 1000))
    local frac=$(( (n % 1000) / 100 ))
    if [ "$frac" -gt 0 ]; then
      echo "${whole}.${frac}k"
    else
      echo "${whole}k"
    fi
  else
    echo "$n"
  fi
}

total_tokens_fmt=$(abbreviate_tokens $total_tokens)
context_size_fmt=$(abbreviate_tokens $context_size)

components+=("${BAR_COLOR}${bar} ${total_tokens_fmt} / ${context_size_fmt}${RST}")

# Join with colored separator
output=""
for i in "${!components[@]}"; do
  if [ $i -gt 0 ]; then
    output+="${SEP}"
  fi
  output+="${components[$i]}"
done

echo "$output"
