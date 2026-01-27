"""
    get_library_path()

Returns the correct path to the YAML C wrapper library based on the platform.
Handles both local development and CI environments.
"""
function get_library_path()
    base_path = joinpath(@__DIR__, "..", "..", "pals-cpp", "build")
    
    # Determine library name based on OS
    if Sys.isapple()
        lib_name = "libyaml_c_wrapper.dylib"
    elseif Sys.islinux()
        lib_name = "libyaml_c_wrapper.so"
    elseif Sys.iswindows()
        lib_name = "libyaml_c_wrapper.dll"
    else
        error("Unsupported operating system")
    end
    
    lib_path = joinpath(base_path, lib_name)
    
    # Verify the library exists
    if !isfile(lib_path)
        error("""
        Library not found: $lib_path
        
        Please build the C++ library first:
        cd pals-cpp
        mkdir -p build
        cd build
        cmake ..
        make
        """)
    end
    
    return lib_path
end

const LIBYAML = get_library_path()