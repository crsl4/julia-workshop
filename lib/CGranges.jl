module CGranges

const libcgranges = joinpath(@__DIR__, "libcgranges.so")

const khint32_t = Cuint

const khint_t = khint32_t

function __ac_X31_hash_string(s)
    ccall((:__ac_X31_hash_string, libcgranges), khint_t, (Ptr{Cchar},), s)
end

function __ac_Wang_hash(key)
    ccall((:__ac_Wang_hash, libcgranges), khint_t, (khint_t,), key)
end

const khint64_t = Culong

const kh_cstr_t = Ptr{Cchar}

const khiter_t = khint_t

struct cr_ctg_t
    name::Ptr{Cchar}
    len::Int32
    root_k::Int32
    n::Int64
    off::Int64
end

struct cr_intv_t
    x::UInt64
    y::UInt32
    rev::UInt32
    label::Int32
end

struct cgranges_t
    n_r::Int64
    m_r::Int64
    r::Ptr{cr_intv_t}
    n_ctg::Int32
    m_ctg::Int32
    ctg::Ptr{cr_ctg_t}
    hc::Ptr{Cvoid}
end

function cr_st(r)
    ccall((:cr_st, libcgranges), Int32, (Ptr{cr_intv_t},), r)
end

function cr_en(r)
    ccall((:cr_en, libcgranges), Int32, (Ptr{cr_intv_t},), r)
end

function cr_start(cr, i)
    ccall((:cr_start, libcgranges), Int32, (Ptr{cgranges_t}, Int64), cr, i)
end

function cr_end(cr, i)
    ccall((:cr_end, libcgranges), Int32, (Ptr{cgranges_t}, Int64), cr, i)
end

function cr_label(cr, i)
    ccall((:cr_label, libcgranges), Int32, (Ptr{cgranges_t}, Int64), cr, i)
end

function cr_init()
    ccall((:cr_init, libcgranges), Ptr{cgranges_t}, ())
end

function cr_destroy(cr)
    ccall((:cr_destroy, libcgranges), Cvoid, (Ptr{cgranges_t},), cr)
end

function cr_add(cr, ctg, st, en, label_int)
    ccall((:cr_add, libcgranges), Ptr{cr_intv_t}, (Ptr{cgranges_t}, Ptr{Cchar}, Int32, Int32, Int32), cr, ctg, st, en, label_int)
end

function cr_index(cr)
    ccall((:cr_index, libcgranges), Cvoid, (Ptr{cgranges_t},), cr)
end

function cr_overlap(cr, ctg, st, en, b_, m_b_)
    ccall((:cr_overlap, libcgranges), Int64, (Ptr{cgranges_t}, Ptr{Cchar}, Int32, Int32, Ptr{Ptr{Int64}}, Ptr{Int64}), cr, ctg, st, en, b_, m_b_)
end

function cr_contain(cr, ctg, st, en, b_, m_b_)
    ccall((:cr_contain, libcgranges), Int64, (Ptr{cgranges_t}, Ptr{Cchar}, Int32, Int32, Ptr{Ptr{Int64}}, Ptr{Int64}), cr, ctg, st, en, b_, m_b_)
end

function cr_add_ctg(cr, ctg, len)
    ccall((:cr_add_ctg, libcgranges), Int32, (Ptr{cgranges_t}, Ptr{Cchar}, Int32), cr, ctg, len)
end

function cr_get_ctg(cr, ctg)
    ccall((:cr_get_ctg, libcgranges), Int32, (Ptr{cgranges_t}, Ptr{Cchar}), cr, ctg)
end

# Skipping MacroDefinition: kh_inline inline

# Skipping MacroDefinition: klib_unused __attribute__ ( ( __unused__ ) )

# exports
const PREFIXES = ["cg_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

export 
    cr_add,
    cr_ctg_t,
    cr_end,
    cr_index,
    cr_init,
    cr_intv_t,
    cr_label,
    cr_overlap,
    cr_start

end # module
