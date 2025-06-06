# Insta360 MediaSDK Server

🚀 **Professional-grade 360° panorama conversion server using official Insta360 MediaSDK**

Convert `.insp` files from Insta360 cameras (X4, X3, ONE X2, etc.) to high-quality equirectangular panoramas with automatic leveling and stabilization - all running in Docker on cloud servers.

## ✨ Features

- **🎯 Official MediaSDK**: Uses Insta360's professional MediaSDK 3.0.1 (same engine as Insta360 Studio)
- **📐 Auto-Leveling**: FlowState stabilization and DirectionLock for perfectly horizontal panoramas
- **⚡ Multiple Algorithms**: Template, Dynamic, and AI stitching options
- **🖥️ Headless Server**: Runs on EC2/cloud instances without display requirements
- **🐳 Docker Ready**: One-command deployment with all dependencies included
- **📏 Multi-Resolution**: 2K, 4K, and custom output sizes
- **🚀 Fast Processing**: 2-5 minutes per conversion (vs 40+ minutes with emulation)
- **🔄 Batch Ready**: Process multiple files efficiently

## 🎯 Why This Exists

Converting Insta360 `.insp` files properly requires the official MediaSDK, but:
- ❌ MediaSDK doesn't work on Apple Silicon (M1/M2/M3 Macs)
- ❌ Docker emulation causes 40+ minute hangs
- ❌ Alternative tools lack proper stitching algorithms
- ❌ Manual FFmpeg approaches produce poor quality

**✅ This project solves all of these issues** by running MediaSDK natively on x86 cloud servers.

## 🏗️ Architecture

```
Insta360 Camera → .insp file → EC2 Server → MediaSDK → Leveled 360° Panorama
                                    ↓
                              Docker Container
                                    ↓
                           Virtual Display (Xvfb)
                                    ↓
                            Software OpenGL (Mesa)
```

## 🚀 Quick Start

### Prerequisites

- AWS EC2 instance (x86_64, Ubuntu 22.04+)
- Docker and Docker Compose installed
- Insta360 MediaSDK package (download from Insta360 Developer Portal)

### 1. Clone and Setup

```bash
git clone https://github.com/yourusername/insta360-mediasdk-server.git
cd insta360-mediasdk-server

# Download MediaSDK from Insta360 and extract to:
# ./libMediaSDK-dev-3.0.1-20250418-amd64/

# Create input/output directories
mkdir -p input output
```

### 2. Build Container

```bash
docker compose build
```

### 3. Convert Your First Image

```bash
# Upload your .insp file to ./input/
# Then run conversion:

docker compose run --rm insta360-converter /app/stitcher_demo \
    -inputs /app/input/your_file.insp \
    -output /app/output/result.jpg \
    -stitch_type template \
    -output_size 2048x1024 \
    -enable_flowstate ON \
    -enable_directionlock ON \
    -disable_cuda true
```

### 4. Download Results

```bash
# Copy results to local machine
scp -i your-key.pem "ubuntu@your-ec2-ip:~/mediasdk-server/output/*.jpg" ./
```

## 🎛️ Configuration Options

### Stitching Algorithms

| Algorithm       | Speed             | Quality | Use Case                         |
| --------------- | ----------------- | ------- | -------------------------------- |
| `template`      | Fast (2-3 min)    | Good    | Quick previews, batch processing |
| `dynamicstitch` | Medium (5-10 min) | Better  | Balanced quality/speed           |
| `aistitch`      | Slow (10+ min)    | Best    | Maximum quality                  |

### Output Resolutions

| Size        | Dimensions | File Size | Use Case           |
| ----------- | ---------- | --------- | ------------------ |
| `1920x960`  | 2K         | ~1-2MB    | Web preview        |
| `2048x1024` | 2K+        | ~1-3MB    | Standard output    |
| `4096x2048` | 4K         | ~3-8MB    | High quality       |
| `8192x4096` | 8K         | ~10-20MB  | Maximum resolution |

### Stabilization Features

- **`-enable_flowstate ON`**: Insta360's signature stabilization using gyroscope data
- **`-enable_directionlock ON`**: Locks horizon to prevent tilt/roll
- **Both together**: Maximum leveling and orientation correction

## 📋 Complete Usage Examples

### Basic Conversion
```bash
docker compose run --rm insta360-converter /app/stitcher_demo \
    -inputs /app/input/image.insp \
    -output /app/output/basic.jpg \
    -stitch_type template \
    -output_size 2048x1024 \
    -disable_cuda true
```

### High-Quality Leveled Conversion
```bash
docker compose run --rm insta360-converter /app/stitcher_demo \
    -inputs /app/input/image.insp \
    -output /app/output/professional.jpg \
    -stitch_type dynamicstitch \
    -output_size 4096x2048 \
    -enable_flowstate ON \
    -enable_directionlock ON \
    -disable_cuda true
```

### Batch Processing
```bash
# Process multiple files
for file in input/*.insp; do
    basename=$(basename "$file" .insp)
    docker compose run --rm insta360-converter /app/stitcher_demo \
        -inputs "/app/input/$basename.insp" \
        -output "/app/output/$basename.jpg" \
        -stitch_type template \
        -output_size 2048x1024 \
        -enable_flowstate ON \
        -disable_cuda true
done
```

## 🔧 Advanced Configuration

### All Available Parameters

```bash
# View all MediaSDK options
docker compose run --rm insta360-converter /app/stitcher_demo -help
```

Key parameters:
- `-stitch_type`: `template | optflow | dynamicstitch | aistitch`
- `-output_size`: `WIDTHxHEIGHT` (e.g., `4096x2048`)
- `-enable_flowstate`: `ON | OFF`
- `-enable_directionlock`: `ON | OFF`
- `-enable_h265_encoder`: `h264 | h265`
- `-bitrate`: Video bitrate (for video files)
- `-enable_denoise`: `ON | OFF`
- `-enable_colorplus`: `ON | OFF`

### Environment Variables

```bash
# docker-compose.yml
environment:
  - DISPLAY=:99
  - LIBGL_ALWAYS_SOFTWARE=1
  - MESA_GL_VERSION_OVERRIDE=3.3
```

## 🐛 Troubleshooting

### Common Issues

**"Cannot load libcudart.so.8.0.61" / "vulkan runtime init error"**
- ✅ **Normal behavior** on headless servers
- MediaSDK automatically falls back to CPU processing
- No action needed - conversions will still work

**"glfwDisplayMgr: failed to setup GLFW!"**
- Virtual display (Xvfb) not running
- Rebuild container: `docker compose build`

**Conversions hang/timeout**
- Ensure you're on x86_64 EC2 instance (not ARM)
- Check available memory (recommend 4GB+ RAM)
- Try smaller output resolution first

**Empty output files**
- Verify input `.insp` file is valid
- Check MediaSDK logs for specific errors
- Ensure sufficient disk space

### Performance Optimization

**For faster processing:**
- Use `template` stitching algorithm
- Lower output resolution (2048x1024)
- Disable advanced features for batch jobs

**For better quality:**
- Use `dynamicstitch` or `aistitch` algorithms
- Enable FlowState and DirectionLock
- Higher resolution (4096x2048+)

## 📁 Project Structure

```
insta360-mediasdk-server/
├── docker-compose.yml          # Container orchestration
├── Dockerfile                  # Container build instructions
├── README.md                   # This file
├── libMediaSDK-dev-3.0.1-*/   # MediaSDK package (download separately)
├── input/                      # Place .insp files here
├── output/                     # Converted images output here
└── examples/                   # Sample scripts and configs
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Legal Notes

- **MediaSDK**: Download separately from [Insta360 Developer Portal](https://developer.insta360.com/)
- **Usage**: Respect Insta360's MediaSDK license terms
- **Camera Files**: Only process files from cameras you own

## 🎯 Related Projects

- [Insta360 Studio](https://www.insta360.com/download) - Official desktop software
- [Insta360 Developer Portal](https://developer.insta360.com/) - MediaSDK downloads
- [FFmpeg](https://ffmpeg.org/) - General video processing (not recommended for .insp files)

## 🙏 Acknowledgments

- Insta360 for providing the MediaSDK
- Docker community for containerization tools
- MESA project for software OpenGL rendering

---

**⭐ Star this repo if it helped you process your 360° images!** 

**💬 Questions? Open an issue!**