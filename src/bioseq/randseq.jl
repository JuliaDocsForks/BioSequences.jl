# Random Sequence Generator
# =========================
#
# Random sequence generator.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/BioSequences.jl/blob/master/LICENSE.md

"""
Abstract sequence generator type.
"""
abstract type SequenceGenerator{T} end

# Sequence generator of stationary distributions.
struct StationaryGenerator{T} <: SequenceGenerator{T}
    elems::Vector{T}
    probs::Vector{Float64}

    function StationaryGenerator{T}(elems, probs) where {T}
        @assert sum(probs) ≤ 1
        @assert length(elems) == length(probs) + 1
        return new(copy(elems), copy(probs))
    end
end

function StationaryGenerator(elems::AbstractVector{T},
                             probs::AbstractVector{<:AbstractFloat}) where {T}
    return StationaryGenerator{T}(elems, probs)
end

alphatype(::Type{DNA}) = DNAAlphabet{4}
alphatype(::Type{RNA}) = RNAAlphabet{4}
alphatype(::Type{AminoAcid}) = AminoAcidAlphabet

function randseq(generator::StationaryGenerator{T}, len::Integer) where {T}
    if len < 0
        throw(ArgumentError("length must be non-negative"))
    end
    seq = BioSequence{alphatype(T)}(len)
    probs = generator.probs
    for i in 1:len
        r = rand()
        j = 1
        cumprob = probs[j]
        while cumprob < r && j ≤ lastindex(probs)
            j += 1
            if j ≤ lastindex(probs)
                cumprob += probs[j]
            end
        end
        seq[i] = generator.elems[j]
    end
    return seq
end

const StationaryDNAGenerator = StationaryGenerator(
    collect(dna"ACGT"), ones(3) / 4)

const StationaryRNAGenerator = StationaryGenerator(
    collect(rna"ACGU"), ones(3) / 4)

const StationaryAAGenerator = StationaryGenerator(
    collect(aa"ARNDCQEGHILKMFPSTWYV"), ones(19) / 20)

"""
    randdnaseq(len::Integer)

Generate a random DNA sequence of length `len`.
"""
function randdnaseq(len::Integer)
    return randseq(StationaryDNAGenerator, len)
end

"""
    randrnaseq(len::Integer)

Generate a random RNA sequence of length `len`.
"""
function randrnaseq(len::Integer)
    return randseq(StationaryRNAGenerator, len)
end

"""
    randaaseq(len::Integer)

Generate a random amino acid sequence of length `len`.
"""
function randaaseq(len::Integer)
    return randseq(StationaryAAGenerator, len)
end
