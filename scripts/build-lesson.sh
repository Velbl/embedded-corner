#!/bin/bash

# Script to select and build a specific lesson
# This script prompts the user to select a lesson and copies the appropriate main.c

LESSONS_DIR="../modern-embedded-programming-course"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build a sparse, lesson-id-indexed array of paths to stm32c031-keil dirs.
# Bash arrays allow gaps, so lesson_dirs[4] holds lesson-04 even if 1..3 are missing.
declare -a lesson_dirs=()
declare -i lesson_count=0

collect_lessons() {
    lesson_dirs=()
    lesson_count=0
    for lesson_dir in "$LESSONS_DIR"/lesson-*/; do
        if [ -d "$lesson_dir/stm32c031-keil" ] && [ -f "$lesson_dir/stm32c031-keil/main.c" ]; then
            local lesson_name
            lesson_name=$(basename "$lesson_dir")
            # Strip "lesson-" prefix and any leading zeros so "04" -> 4.
            local id_str="${lesson_name#lesson-}"
            local lesson_id=$((10#$id_str))
            lesson_dirs[$lesson_id]="$lesson_dir/stm32c031-keil"
            ((lesson_count++))
        fi
    done
}

# Function to display available lessons
show_available_lessons() {
    echo "Available lessons with STM32C031 support:"
    echo ""

    for lesson_id in "${!lesson_dirs[@]}"; do
        printf "%2d) %s\n" "$lesson_id" "$(basename "$(dirname "${lesson_dirs[$lesson_id]}")")"
    done | sort -n

    echo ""
    echo "Lessons with STM32C031 support found: $lesson_count"
    echo ""
}

# Function to get user selection
get_user_selection() {
    read -p "Enter the lesson number (or 'q' to quit): " selection

    if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
        echo "Build cancelled."
        exit 0
    fi

    # Validate input: must be a number that maps to a known lesson id.
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ -z "${lesson_dirs[$((10#$selection))]+x}" ]; then
        echo "Invalid selection. Please try again."
        get_user_selection
        return
    fi

    local selected_lesson="${lesson_dirs[$((10#$selection))]}"

    if [ -f "$selected_lesson/main.c" ]; then
        echo "Selected: $selected_lesson"
        cp "$selected_lesson/main.c" "$CURRENT_DIR/../lesson-runner/main.c"
        echo "✓ Copied main.c from selected lesson"
        return 0
    else
        echo "Error: main.c not found in selected lesson"
        return 1
    fi
}

# Main execution
echo "========================================="
echo "  CMSIS Lesson Builder"
echo "========================================="
echo ""

# Discover lessons once, then reuse for both display and selection.
collect_lessons

# Show available lessons
show_available_lessons

# Get user selection and copy the main.c
if get_user_selection; then
    echo ""
    echo "Ready to build."
    echo ""
else
    echo "Failed to select lesson"
    exit 1
fi
