using DrWatson
@quickactivate
using DataFrames, JellyMe4, MixedModels, RCall

sleepstudy = DataFrame(MixedModels.dataset(:sleepstudy));
describe(sleepstudy)

R"""
require("ggplot2", quietly=TRUE)
require("lattice", quietly=TRUE)
require("lme4", quietly=TRUE)
""";
RCall.ijulia_setdevice(MIME("image/svg+xml"), width=6, height=3.5)

@rput sleepstudy;

R"""
xy <- xyplot(
    reaction ~ days | subj, sleepstudy, aspect = "xy",
    layout = c(9,2), type = c("g", "p", "r"),
    index.cond = function(x,y) coef(lm(y ~ x))[1],
    xlab = "Days of sleep deprivation",
    ylab = "Average reaction time (ms)"
)
"""

let days = 0:9
    hcat(ones(length(days)), days)
end

withinsubj = combine(groupby(sleepstudy, :subj)) do sdf
    days = sdf.days
    X = hcat(ones(length(days)), days)
    coefs = X \ sdf.reaction
    (intercept = first(coefs), slope = last(coefs), )
end

withinsubj = combine(groupby(sleepstudy, :subj)) do sdf
    days, rt = sdf.days, sdf.reaction
    X = hcat(ones(length(days)), days)
    coefs = X \ rt
    dfr = length(days) - 2  # degrees of freedom for residuals
    ssr = sum(abs2, rt - X * coefs) # sum of squared residuals
    (intercept = first(coefs), slope = last(coefs),
    ssr = ssr, dfr = dfr, s = sqrt(ssr / dfr), )
end

describe(withinsubj)

f1 =  @formula(reaction ~ 1 + days + (1+days|subj));
m1 = fit(MixedModel, f1, sleepstudy)

ranefvals = DataFrame(only(raneftables(m1)))

let fe = fixef(m1)
    ranefvals[2] .+= fe[1]
    ranefvals[3] .+= fe[2]
end;
describe(ranefvals)

coefs = innerjoin(ranefvals, withinsubj, on = :subj);
@rput coefs

RCall.ijulia_setdevice(MIME("image/svg+xml"), width=6, height=5)
R"""
p <- ggplot(coefs, aes(slope, intercept)) +
    geom_point(aes(color="Within")) +
    geom_text(aes(label=subj), vjust="outward") +
    geom_point(aes(days, `(Intercept)`, color="Mixed")) +
    geom_segment(aes(xend=days, yend=`(Intercept)`),
        arrow = arrow(length=unit(0.015, "npc"))) +
    xlab("Slope w.r.t. days (ms/day)") +
    ylab("Intercept (ms)")
"""

RCall.ijulia_setdevice(MIME("image/svg+xml"), width=6, height=3.5)
R"xy"

f2 = @formula(reaction ~ 1 + days + zerocorr(1+days|subj));
m2 = fit(MixedModel, f2, sleepstudy)

MixedModels.likelihoodratiotest(m2, m1)

DataFrame(map(m -> (objective = objective(m), AIC = aic(m), AICc = aicc(m), BIC = bic(m)), [m2, m1]))

typeof(m1)
propertynames(m1)
m1.formula
m1.objective

R"summary(m1 <- $(m1, sleepstudy))"

RCall.ijulia_setdevice(MIME("image/svg+xml"), width=6, height=4.5)
R"""
dotplot(ranef(m1),
    scales = list(x = list(relation = 'free')))[['subj']]
"""

R"qqmath(ranef(m1))[['subj']]"
