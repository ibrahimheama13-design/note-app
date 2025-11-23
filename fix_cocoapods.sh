#!/bin/bash

echo "========================================="
echo "  اصلاح مشكلة CocoaPods للايفون"
echo "========================================="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "⏳ جاري تثبيت Homebrew..."
    echo "📝 ملحوظة: هيطلب منك كلمة السر"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [ -d "/opt/homebrew" ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    echo "✅ تم تثبيت Homebrew بنجاح!"
else
    echo "✅ Homebrew مثبت بالفعل"
fi

echo ""
echo "⏳ جاري تثبيت CocoaPods..."
brew install cocoapods

echo ""
echo "⏳ جاري تثبيت dependencies للمشروع..."
cd ios
pod install

echo ""
echo "========================================="
echo "✅ تم اصلاح المشكلة بنجاح!"
echo "========================================="
echo ""
echo "🎉 دلوقتي تقدر تشغل التطبيق على الايفون بتاعك!"
echo ""
