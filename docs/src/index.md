# pals.jl

Documentation for pals.jl.

## Installation
```julia
# Install from local directory
using Pkg
Pkg.add(path="/path/to/pals.jl")
```

## Quick Example
```julia
using pals.jl

# Parse YAML
config = parse_yaml("""
server:
  host: localhost
  port: 8080
features:
  - auth
  - logging
""")

# Access values
host = String(config["server"]["host"])  # "localhost"
port = Int(config["server"]["port"])     # 8080

# Create YAML
new_config = create_map()
new_config["name"] = "MyApp"
write_yaml(new_config, "config.pals.yaml")
```
