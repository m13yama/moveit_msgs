#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANTUML_JAR="${SCRIPT_DIR}/plantuml.jar"
PU_FILE="${SCRIPT_DIR}/PlanningScene.pu"
PNG_FILE="${SCRIPT_DIR}/PlanningScene.png"
PLANTUML_URL="https://github.com/plantuml/plantuml/releases/download/v1.2024.3/plantuml-1.2024.3.jar"

if [[ ! -f "${PU_FILE}" ]]; then
  echo "PlantUML source not found at ${PU_FILE}" >&2
  exit 1
fi

for cmd in java mogrify curl; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Required command '${cmd}' is not available in PATH." >&2
    exit 1
  fi
done

if [[ ! -f "${PLANTUML_JAR}" ]]; then
  echo "PlantUML jar missing. Downloading..."
  curl -L -o "${PLANTUML_JAR}" "${PLANTUML_URL}"
fi

echo "Rendering PlantUML diagram..."
java -Djava.awt.headless=true -DPLANTUML_LIMIT_SIZE=12000 -jar "${PLANTUML_JAR}" -tpng "${PU_FILE}"

echo "Setting PNG resolution metadata to 600 dpi..."
mogrify -units PixelsPerInch -density 600 "${PNG_FILE}"

echo "PNG exported at ${PNG_FILE}"
