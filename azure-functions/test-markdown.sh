#!/bin/bash

# Test script dla Markdown to HTML Azure Function
# Użycie: ./test-markdown.sh [local|azure]

MODE=${1:-local}

if [ "$MODE" = "local" ]; then
    ENDPOINT="http://localhost:7071/api/markdown-to-html"
    echo "Testing LOCAL endpoint: $ENDPOINT"
else
    # Zmień na swój endpoint
    FUNCTION_KEY="${AZURE_FUNCTION_KEY:-YOUR_FUNCTION_KEY}"
    ENDPOINT="https://func-schoolopinions-markdown-prod.azurewebsites.net/api/markdown-to-html?code=$FUNCTION_KEY"
    echo "Testing AZURE endpoint: $ENDPOINT"
fi

echo ""
echo "=========================="
echo "Test 1: Basic Markdown"
echo "=========================="

curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "## Ocena zachowania\n\nUczeń wykazuje **bardzo dobre** zachowanie.\n\n### Mocne strony\n\n- Aktywny udział w lekcjach\n- Sumienność w wykonywaniu zadań\n- Kultura osobista\n\n### Obszary do rozwoju\n\n- Większa pewność siebie podczas odpowiedzi",
    "options": {
      "markedOptions": {
        "gfm": true,
        "breaks": true
      }
    }
  }' | python3 -m json.tool

echo ""
echo ""
echo "=========================="
echo "Test 2: Complex Markdown with table"
echo "=========================="

curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "# Raport ucznia\n\n## Oceny\n\n| Przedmiot | Ocena | Uwagi |\n|-----------|-------|-------|\n| Matematyka | 5 | Wzorowy |\n| Polski | 4 | Dobry |\n| WF | 5 | Bardzo aktywny |\n\n## Komentarz\n\nUczeń wykazuje **znakomite** postępy w nauce.",
    "options": {}
  }' | python3 -m json.tool

echo ""
echo ""
echo "=========================="
echo "Test 3: XSS Protection Test"
echo "=========================="

curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "markdown": "<script>alert(\"XSS\")</script>\n## Normalny nagłówek\n<img src=x onerror=alert(1)>\n\nBezpieczny **tekst**.",
    "options": {}
  }' | python3 -m json.tool

echo ""
echo ""
echo "=========================="
echo "Test 4: Empty input (should fail)"
echo "=========================="

curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "options": {}
  }' | python3 -m json.tool

echo ""
echo ""
echo "=========================="
echo "Test 5: Very long text"
echo "=========================="

LONG_TEXT=$(printf '=%.0s' {1..100})

curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "{
    \"markdown\": \"## Bardzo długi tekst\n\n$LONG_TEXT\n\nKoniec tekstu.\",
    \"options\": {}
  }" | python3 -m json.tool

echo ""
echo "Tests completed!"
