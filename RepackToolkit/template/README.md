# Template .msapp Location

Place your template `.msapp` file here as `BlankApp.msapp`.

The repack script will automatically use this file if no other template is specified.

## How to Create a Template

1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Create a **Blank canvas app** (any layout)
3. **File** > **Save as** > **This computer**
4. Save as `BlankApp.msapp`
5. Copy to this folder

## Why This is Needed

PAC CLI 1.51+ requires `CanvasManifest.json` in the source folder. Our CanvasSource uses an older format that doesn't have this file. The template provides the correct structure.

## Note

The actual template file (`BlankApp.msapp`) is gitignored because:
- It's a binary file
- It may contain environment-specific metadata
- Users should create their own from their Power Apps environment
