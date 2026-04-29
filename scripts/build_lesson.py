#!/usr/bin/env python3
"""
Lesson Builder Script
Allows users to select and build a specific lesson from the modern-embedded-programming-course.
"""

import os
import sys
import shutil
from pathlib import Path
from unittest import runner

def main():
    # Setup paths
    script_dir = Path(__file__).parent.absolute()
    lessons_base = script_dir.parent / "modern-embedded-programming-course"
    
    print("=" * 50)
    print("  CMSIS Lesson Builder")
    print("=" * 50)
    print()
    
    # Find all lessons with STM32C031 support, keyed by lesson id
    lessons_by_id = {}

    for lesson_dir in sorted(lessons_base.glob("lesson-*")):
        if not lesson_dir.is_dir():
            continue

        try:
            lesson_id = int(lesson_dir.name.split("-")[1])
        except (IndexError, ValueError):
            continue

        # Check for stm32c031-keil support
        stm32_keil_path = lesson_dir / "stm32c031-keil" / "main.c"
        if stm32_keil_path.exists():
            lessons_by_id[lesson_id] = {
                'name': lesson_dir.name,
                'path': lesson_dir / "stm32c031-keil",
                'main_c': stm32_keil_path
            }

    if not lessons_by_id:
        print("ERROR: No lessons with STM32C031 support found!")
        print(f"Searched in: {lessons_base}")
        return 1

    # Display available lessons
    print("Available lessons with STM32C031 support:")
    print()
    for lesson_id in sorted(lessons_by_id):
        print(f"{lesson_id:2d}) {lessons_by_id[lesson_id]['name']}")

    print()
    print(f"Total lessons found: {len(lessons_by_id)}")
    print()

    # Get user selection
    while True:
        try:
            user_input = input("Enter the lesson number (or 'q' to quit): ").strip()

            if user_input.lower() in ['q', 'quit']:
                print("Build cancelled.")
                return 0

            selection = int(user_input)
            if selection in lessons_by_id:
                break
            else:
                print(f"Invalid selection. Please enter a listed lesson number.")
        except ValueError:
            print(f"Invalid input. Please enter a listed lesson number or 'q' to quit")

    selected_lesson = lessons_by_id[selection]
    
    # Copy main.c
    dest_main_c = script_dir.parent / "lesson-runner" / "main.c"
    try:
        shutil.copy(str(selected_lesson['main_c']), str(dest_main_c))
        print()
        print(f"✓ Selected: {selected_lesson['name']}")
        print(f"✓ Copied main.c from: {selected_lesson['path']}")
        print()
        print("Ready to build.")
        print()
        return 0
    except Exception as e:
        print(f"ERROR: Failed to copy main.c: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
