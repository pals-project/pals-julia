include("../src/pals.jl")

#reading a lattice from a yaml file
yaml_file = abspath(joinpath(@__DIR__, "..", "lattice_files", "ex.pals.yaml"))
node = parse_file(yaml_file)
#printing to terminal
println(to_yaml_string(node))

#type checking
println((is_sequence(node)))

#accessing sequence
seq = getindex(node, 1)
println("the first element is: \n", to_yaml_string(seq))

#accessing map
println("the value at key 'thingB' is: ", to_yaml_string(getindex(seq, "thingB")))

#creating a new node that's a map 
map = create_map()
setvalue!(map, 2, "first")

#creating a new node that's a sequence
sequence = create_sequence()
push!(sequence, "magnet1")
push!(sequence, "")
scalar = create_scalar()
set!(scalar, "magnet2")
set_at_index!(sequence, 1, scalar)

#adding new nodes to lattice
push!(node, map)
push!(node, sequence)

#writing modified lattice file to expand.pals.yaml
file_dest = abspath(joinpath(@__DIR__, "..", "lattice_files", "expand.pals.yaml"))
write_yaml(node, file_dest)
