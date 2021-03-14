## Setup
using DrWatson
initialize_project("DataScienceWorkshop"; authors="CSL")
cd("DataScienceWorkshop")
@quickactivate
add CSV DataFrames Arrow Tables HTTP JellyMe4 RCall


## Arrow
using Arrow, CSV, DataFrames, HTTP, Tables

f = CSV.File(
    HTTP.get("https://github.com/manybabies/mb1-analysis-public/raw/master/processed_data/02_validated_output.csv").body,
    missingstrings = ["NA"],
	truestrings = ["TRUE"],
	falsestrings = ["FALSE"],
);

ct = Tables.columntable(f)

begin
    df = DataFrame(ct);
    describe(df)
end

Arrow.write("02_validated_output.arrow", f);
filesize("02_validated_output.arrow")
Arrow.write("02_validated_output_compressed.arrow", f, compress = :zstd)
filesize("02_validated_output_compressed.arrow")

tbl = Arrow.Table("02_validated_output.arrow");
df = DataFrame(tbl);
describe(df)
typeof(tbl.subid)

### MixedModels
using DataFrames, JellyMe4, MixedModels, RCall
sleepstudy = DataFrame(MixedModels.dataset(:sleepstudy));
describe(sleepstudy)
f1 =  @formula(reaction ~ 1 + days + (1+days|subj));
m1 = fit(MixedModel, f1, sleepstudy)
ranefvals = DataFrame(only(raneftables(m1)))

