#!/bin/bash

# Script to generate Word document from markdown
# Requires pandoc to be installed

set -e

echo "🔄 Generating Word document from architecture documentation..."

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ pandoc is not installed. Installing..."
    
    # Install pandoc based on OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y pandoc
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install pandoc
    else
        echo "Please install pandoc manually: https://pandoc.org/installing.html"
        exit 1
    fi
fi

# Create output directory
mkdir -p ../docs

# Convert markdown to Word document
pandoc ../ARCHITECTURE_DOCUMENT.md \
    -o ../docs/Secure_Bedrock_Chatbot_Architecture.docx \
    --from markdown \
    --to docx \
    --reference-doc=../docs/reference.docx \
    --toc \
    --toc-depth=3 \
    --highlight-style=github \
    --metadata title="Secure Bedrock Chatbot - Architecture Documentation" \
    --metadata author="AWS Solutions Architecture Team" \
    --metadata date="$(date '+%B %d, %Y')"

echo "✅ Word document generated: ../docs/Secure_Bedrock_Chatbot_Architecture.docx"

# Also generate PDF version
pandoc ../ARCHITECTURE_DOCUMENT.md \
    -o ../docs/Secure_Bedrock_Chatbot_Architecture.pdf \
    --from markdown \
    --to pdf \
    --toc \
    --toc-depth=3 \
    --highlight-style=github \
    --metadata title="Secure Bedrock Chatbot - Architecture Documentation" \
    --metadata author="AWS Solutions Architecture Team" \
    --metadata date="$(date '+%B %d, %Y')" \
    --geometry margin=1in

echo "✅ PDF document generated: ../docs/Secure_Bedrock_Chatbot_Architecture.pdf"

# Generate HTML version for web viewing
pandoc ../ARCHITECTURE_DOCUMENT.md \
    -o ../docs/Secure_Bedrock_Chatbot_Architecture.html \
    --from markdown \
    --to html5 \
    --standalone \
    --toc \
    --toc-depth=3 \
    --highlight-style=github \
    --css=styles.css \
    --metadata title="Secure Bedrock Chatbot - Architecture Documentation" \
    --metadata author="AWS Solutions Architecture Team" \
    --metadata date="$(date '+%B %d, %Y')"

echo "✅ HTML document generated: ../docs/Secure_Bedrock_Chatbot_Architecture.html"

echo ""
echo "📄 Documentation generated in multiple formats:"
echo "   - Word: docs/Secure_Bedrock_Chatbot_Architecture.docx"
echo "   - PDF:  docs/Secure_Bedrock_Chatbot_Architecture.pdf"
echo "   - HTML: docs/Secure_Bedrock_Chatbot_Architecture.html"
echo ""
echo "🎉 Documentation generation complete!"
