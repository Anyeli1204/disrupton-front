#!/usr/bin/env python3
import re

# Leer el archivo
with open('ios/Runner.xcodeproj/project.pbxproj', 'r', encoding='utf-8') as f:
    content = f.read()

# Reemplazar todas las instancias del Bundle ID incorrecto
content = re.sub(r'com\.example\.disruptonApp', 'com.disrupton.app', content)

# Escribir el archivo corregido
with open('ios/Runner.xcodeproj/project.pbxproj', 'w', encoding='utf-8') as f:
    f.write(content)

print("Bundle ID corregido en todas las instancias")
