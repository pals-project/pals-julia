"""
pals-julia

A Julia wrapper around yaml-cpp's YAML::Node.
"""

module PALS

using Libdl 

# -----------------------------
# Library loading (CORRECT WAY)
# -----------------------------

const LIBYAML = Ref{Ptr{Cvoid}}(C_NULL)

function __init__()
    base_path = joinpath(@__DIR__, "..", "pals-cpp", "build")

    lib_name =
        Sys.isapple()   ? "libyaml_c_wrapper.dylib" :
        Sys.islinux()   ? "libyaml_c_wrapper.so" :
        Sys.iswindows() ? "libyaml_c_wrapper.dll" :
        error("Unsupported operating system")

    lib_path = joinpath(base_path, lib_name)

    @assert isfile(lib_path) "Library not found: $lib_path"

    LIBYAML[] = Libdl.dlopen(lib_path)
end

# -----------------------------
# Opaque handle type
# -----------------------------

mutable struct YAMLNode
    handle::Ptr{Cvoid}

    function YAMLNode(handle::Ptr{Cvoid})
        handle == C_NULL && error("Invalid YAML node handle")
        node = new(handle)
        finalizer(yaml_delete_node, node)
        return node
    end
end

# -----------------------------
# Creation
# -----------------------------

create_node() =
    YAMLNode(@ccall LIBYAML[].yaml_create_node()::Ptr{Cvoid})

create_map() =
    YAMLNode(@ccall LIBYAML[].yaml_create_map()::Ptr{Cvoid})

create_sequence() =
    YAMLNode(@ccall LIBYAML[].yaml_create_sequence()::Ptr{Cvoid})

create_scalar() =
    YAMLNode(@ccall LIBYAML[].yaml_create_scalar()::Ptr{Cvoid})

function yaml_delete_node(node::YAMLNode)
    if node.handle != C_NULL
        @ccall LIBYAML[].yaml_delete_node(node.handle::Ptr{Cvoid})::Cvoid
        node.handle = C_NULL
    end
end

# -----------------------------
# Parsing
# -----------------------------

function parse_yaml(yaml_str::String)
    handle = @ccall LIBYAML[].yaml_parse(yaml_str::Cstring)::Ptr{Cvoid}
    YAMLNode(handle)
end

function parse_file(filename::String)
    isfile(filename) || error("File not found: $filename")

    handle = @ccall LIBYAML[].yaml_parse_file(filename::Cstring)::Ptr{Cvoid}
    handle == C_NULL && error("Failed to parse YAML file")

    YAMLNode(handle)
end

# -----------------------------
# Type checks
# -----------------------------

is_scalar(node::YAMLNode) =
    @ccall LIBYAML[].yaml_is_scalar(node.handle::Ptr{Cvoid})::Bool

is_sequence(node::YAMLNode) =
    @ccall LIBYAML[].yaml_is_sequence(node.handle::Ptr{Cvoid})::Bool

is_map(node::YAMLNode) =
    @ccall LIBYAML[].yaml_is_map(node.handle::Ptr{Cvoid})::Bool

is_null(node::YAMLNode) =
    @ccall LIBYAML[].yaml_is_null(node.handle::Ptr{Cvoid})::Bool

# -----------------------------
# Access
# -----------------------------

function Base.getindex(node::YAMLNode, key::String)
    handle = @ccall LIBYAML[].yaml_get_key(
        node.handle::Ptr{Cvoid}, key::Cstring
    )::Ptr{Cvoid}

    handle == C_NULL && error("Key not found: $key")
    YAMLNode(handle)
end

function Base.getindex(node::YAMLNode, index::Int)
    handle = @ccall LIBYAML[].yaml_get_index(
        node.handle::Ptr{Cvoid}, (index - 1)::Cint
    )::Ptr{Cvoid}

    handle == C_NULL && error("Index out of bounds: $index")
    YAMLNode(handle)
end

Base.haskey(node::YAMLNode, key::String) =
    @ccall LIBYAML[].yaml_has_key(node.handle::Ptr{Cvoid}, key::Cstring)::Bool

Base.length(node::YAMLNode) =
    @ccall LIBYAML[].yaml_size(node.handle::Ptr{Cvoid})::Cint

# -----------------------------
# Conversions
# -----------------------------

function Base.String(node::YAMLNode)
    ptr = @ccall LIBYAML[].yaml_as_string(node.handle::Ptr{Cvoid})::Cstring
    ptr == C_NULL && error("Cannot convert node to string")
    str = unsafe_string(ptr)
    @ccall LIBYAML[].yaml_free_string(ptr::Cstring)::Cvoid
    return str
end

Base.Int(node::YAMLNode) =
    @ccall LIBYAML[].yaml_as_int(node.handle::Ptr{Cvoid})::Cint

Base.Float64(node::YAMLNode) =
    @ccall LIBYAML[].yaml_as_float(node.handle::Ptr{Cvoid})::Cdouble

Base.Bool(node::YAMLNode) =
    @ccall LIBYAML[].yaml_as_bool(node.handle::Ptr{Cvoid})::Bool

# -----------------------------
# Emit / write
# -----------------------------

function emit_yaml(node::YAMLNode; indent::Int = 2)
    ptr = @ccall LIBYAML[].yaml_emit(
        node.handle::Ptr{Cvoid},
        indent::Cint
    )::Cstring

    ptr == C_NULL && error("Failed to emit YAML")

    str = unsafe_string(ptr)
    @ccall LIBYAML[].yaml_free_string(ptr::Cstring)::Cvoid
    return str
end

# -----------------------------
# Utilities
# -----------------------------

clone(node::YAMLNode) =
    YAMLNode(@ccall LIBYAML[].yaml_clone(node.handle::Ptr{Cvoid})::Ptr{Cvoid})

yaml_expand(node::YAMLNode) =
    YAMLNode(@ccall LIBYAML[].yaml_expand(node.handle::Ptr{Cvoid})::Ptr{Cvoid})

Base.show(io::IO, ::YAMLNode) = print(io, "YAMLNode(...)")

end # module
