#!/bin/bash

echo "🚀 Insta360 MediaSDK Server Setup Verification"
echo "=============================================="

# Check if folders exist
echo "📁 Checking folder structure..."

if [ ! -d "mediasdk" ]; then
    echo "❌ Missing: ./mediasdk/ folder"
    echo "   Please create it and add your MediaSDK files"
    exit 1
fi

if [ ! -d "insp-files" ]; then
    echo "📁 Creating: ./insp-files/"
    mkdir -p insp-files
fi

if [ ! -d "panoramas" ]; then
    echo "📁 Creating: ./panoramas/"
    mkdir -p panoramas
fi

# Check MediaSDK files
echo "📦 Checking MediaSDK files..."

DEB_COUNT=$(find mediasdk -name "*.deb" | wc -l)
if [ $DEB_COUNT -eq 0 ]; then
    echo "❌ Missing: MediaSDK .deb files in ./mediasdk/"
    echo "   Download from: https://developer.insta360.com/"
    exit 1
fi

if [ ! -d "mediasdk/example" ]; then
    echo "❌ Missing: ./mediasdk/example/ folder"
    echo "   This should come with your MediaSDK download"
    exit 1
fi

if [ ! -f "mediasdk/example/main.cc" ]; then
    echo "❌ Missing: ./mediasdk/example/main.cc"
    echo "   This should come with your MediaSDK download"
    exit 1
fi

echo "✅ MediaSDK files found:"
ls -la mediasdk/*.deb

# Check .insp files
INSP_COUNT=$(find insp-files -name "*.insp" 2>/dev/null | wc -l)
if [ $INSP_COUNT -eq 0 ]; then
    echo "⚠️  No .insp files found in ./insp-files/"
    echo "   Add your Insta360 camera files before converting"
else
    echo "✅ Found $INSP_COUNT .insp files"
fi

echo ""
echo "🎯 Setup Status:"
echo "✅ Folder structure correct"
echo "✅ MediaSDK files present"
echo "✅ Ready to build Docker container"
echo ""
echo "Next steps:"
echo "1. docker compose build"
echo "2. Add .insp files to ./insp-files/"
echo "3. Run conversion commands"
echo ""
echo "🚀 You're ready to go!"