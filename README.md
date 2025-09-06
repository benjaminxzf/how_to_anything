# How-To-Anything App

An AI-powered tutorial generator that creates interactive, multimedia how-to guides using Google's Gemini APIs.

## Features

- **Structured Tutorial Generation**: Uses Gemini 2.5 Pro to create detailed step-by-step tutorials with tips, warnings, and time estimates
- **Photorealistic Images**: Generates consistent, instructional images for each step using Gemini 2.5 Flash Image (Nano Banana)
- **Voice Narration**: Creates voice-over instructions using Gemini 2.5 Pro Preview TTS with multiple voice options
- **Interactive HTML Viewer**: Beautiful web interface to view tutorials with images and audio

## Installation

```bash
# Install dependencies
pip3 install -r requirements.txt
```

## Usage

```bash
python3 how_to_anything.py "how to [your topic]"
```

Examples:
```bash
python3 how_to_anything.py "how to tie a tie"
python3 how_to_anything.py "how to replace car batteries"
python3 how_to_anything.py "how to make coffee"
```

## Output Structure

Each tutorial creates a folder with:
```
tutorials/
└── [tutorial_name_timestamp]/
    ├── tutorial.json       # Structured tutorial data
    ├── images/            # Step-by-step images
    │   ├── step_1.png
    │   ├── step_2.png
    │   └── ...
    ├── audio/             # Voice narrations
    │   ├── step_1.wav
    │   ├── step_2.wav
    │   └── ...
    └── index.html         # Interactive viewer
```

## Features Breakdown

### 1. Tutorial Generation
- Uses Gemini 2.5 Pro with structured output (Pydantic models)
- Generates comprehensive tutorials with:
  - Step-by-step instructions
  - Time estimates
  - Required tools and materials
  - Safety warnings
  - Helpful tips

### 2. Image Generation
- Uses Gemini 2.5 Flash Image (Nano Banana) for photorealistic images
- Maintains visual consistency by using previous images as context
- Each image shows the specific action or state for that step

### 3. Voice Narration
- Uses Gemini 2.5 Pro Preview TTS
- Rotates through 8 different voices for variety
- Clear, instructional tone for easy following
- WAV format for universal browser support

### 4. HTML Viewer
- Clean, responsive design
- Audio controls for each step
- Visual hierarchy with numbered steps
- Tips and warnings highlighted
- Tools and materials clearly listed

## API Configuration

The app uses the Gemini API key embedded in the script. For production use, consider:
- Setting the API key as an environment variable
- Using the `--api-key` command-line argument

## Performance Notes

- Tutorial generation: ~10-20 seconds
- Image generation: ~10-15 seconds per image
- Voice generation: ~5-30 seconds per step (depending on text length)
- Total time: 3-5 minutes for a typical 6-8 step tutorial

## Requirements

- Python 3.8+
- Gemini API access
- Internet connection for API calls

## License

This project uses the Gemini API with the provided API key for demonstration purposes.