# Visualization and Export Reference

Detailed code patterns for interactive viewing with OCP VSCode and exporting models to various formats.

## Interactive Viewing with OCP VSCode

```python
from ocp_vscode import show_object, show
from build123d import *

# Create geometry
part = Box(10, 10, 10)

# Display in VSCode
show_object(part, name="main_box")
show(part)  # Show all objects

# Configure display options
show_object(part, name="colored_box",
           options={"alpha": 0.8, "color": "blue"})
```

## Export Formats

```python
from build123d import *

part = Box(10, 10, 10)

# STL export (for 3D printing)
part.export_stl("model.stl")

# STEP export (for CAD interchange)
part.export_step("model.step")

# 3MF export (Microsoft 3D format)
part.export_3mf("model.3mf")

# BREP export (OpenCascade native)
part.export_brep("model.brep")
```
