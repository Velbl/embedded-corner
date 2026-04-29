# Keep notes on important repo changes.

# Day 1 (29.04.2026.):
- Design initial repo structure.
    - Link modern-embedded-programming-course submodule from QuantumLeaps to be in sync with latest course updates. 
    - Create folder for build environment to separate build/setup environment from course materials and other stuff (notes, docs, etc...).
    - Create doc and notes folders for all the relevant documentation and lessons learned, also for tracking the solutions for issues that occured.
    - Add initial .gitignore to avoid unnecessary gen and temp files from builds.
    - Create changelog file to track all the important changes and decisions to track thought process.
- Setup initial build environment.
    - Add minimal Keil Studio build environment in lesson-runner solution.
    - Add scripts for automatic build selection to ease the process of building different lessons.
    - Build code and flash it successfully to STM32 C031C6 board to validate that everything is done properly.