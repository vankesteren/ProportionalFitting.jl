# dict methods for future reference
Base.Dict(AM::ArrayMargins) = Dict(AM.di[i] => AM.am[i] for i in 1:length(AM))
Base.Dict(AF::ArrayFactors) = Dict(AF.di[i] => AF.af[i] for i in 1:length(AF))
