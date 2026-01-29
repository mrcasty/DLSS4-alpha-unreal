# DLSS4-alpha-unreal: DLSS 4 Alpha Upscaling Fix for UE5

This repository contains a modified version of the NVIDIA DLSS Plugin for Unreal Engine 5, patching critical temporal stability issues in the alpha channel.

---

**The Problem**: In recent UE DLSS plugins based on DLSS 4, the alpha channel appears to be ignored even when `r.NGX.DLSS.EnableAlphaUpscaling` is configured correctly. This leads to visual artifacts such as jittering or ghosting on alpha chanel (alpha-holdouts, post-process alpha). This repository provides a patch to restore proper alpha channel support, ensuring compatibility with advanced compositing workflows.

**Performance Note**: Scaling the alpha channel requires a second DLSS pass, effectively doubling the inference cost compared to RGB-only upscaling.

**Fix Description**: This implementation uses a "Dual Pass" architecture:
1.  **Extract**: The Alpha channel is extracted to a temporary texture where `AAA = Alpha`.
2.  **Upscale (Alpha)**: DLSS processes this texture using a dedicated history buffer to ensure temporal stability.
3.  **Upscale (Color)**: DLSS processes the Scene Color normally.
4.  **Combine**: The upscaled results are merged into the final `RGBA` image.

---

## Contents

*   **`5.6/DLSSA/Plugins/DLSS/`**: The modified C++ plugin source code.
*   **`5.6/DLSSA/`**: Sample project with a test map demonstrating the fix.
*   **Future Versions**: A `5.7/` folder supports upcoming engine updates.

## Prerequisites

1.  **Unreal Engine 5.6+**: Required for module compatibility.
2.  **NVIDIA DLSS 4 Plugin**: This repository contains only the source modifications. The official NVIDIA DLSS Plugin must be installed in the Engine to provide the necessary binaries (`nvngx_dlss.dll`) and libraries. You only need the `DLSS` and `StreamlineNGXCommon` modules at the project level to build this modification.

## Installation

1.  Copy the `Plugins/DLSS` folder from this repository into your project's `Plugins` directory.
2.  Add the `DLSS` plugin to your `.uproject` file.
3.  Re-generate Visual Studio project files.
4.  Recompile the plugin.

## Usage

### Configuration
The fix utilizes the standard console variable for alpha upscaling.

**Console Commands**:
```bash
r.NGX.DLSS.EnableAlphaUpscaling 1  # Enable Alpha Upscaling (Supported via Dual-Pass)
r.NGX.DLSS.EnableAlphaUpscaling 0  # Disable Alpha Upscaling (Standard DLSS)
r.NGX.DLSS.EnableAlphaUpscaling -1 # Auto (Enable if project has Alpha Output enabled)
```

### Verification
1.  Open the provided sample project.
2.  Load the test map (contains an alpha holdout plane with an opaque plane in front).
3.  Adjust `r.NGX.DLSS.EnableAlphaUpscaling` to observe the difference.

## Contributing

Contributions are welcome. If you have a more efficient method for handling alpha upscaling in DLSS 4, please open a Pull Request.
