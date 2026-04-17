BeginPackage["EFTwithFFT`"];

BuildK13Sector::usage = "BuildK13Sector[sector] returns the symbolic one-variable M13 kernel for a Gaussian redshift-space biased-tracer sector.";
BuildK22Sector::usage = "BuildK22Sector[sector] returns the symbolic two-variable M22 kernel for a Gaussian redshift-space biased-tracer sector.";
BuildAllM13Kernels::usage = "BuildAllM13Kernels[] returns an Association from exact M13 filenames to symbolic expressions.";
BuildAllM22Kernels::usage = "BuildAllM22Kernels[] returns an Association from exact M22 filenames to symbolic expressions.";
BuildKernelCorpus::usage = "BuildKernelCorpus[kind] builds the requested kernel corpus. The redshift-space M13/M22 corpora are canonicalized to the ps_1loop_jax text contract by default, while the raw derived corpus can be requested with the option \"CanonicalizeForReference\" -> False.";
ClassifyKernelMismatches::usage = "ClassifyKernelMismatches[kind] compares the requested raw kernel corpus against the ps_1loop_jax text files and labels each kernel as an exact match, canonicalization-only mismatch, or formula mismatch.";
CanonicalizeKernelForReference::usage = "CanonicalizeKernelForReference[file, expr] rewrites a kernel expression to the exact ps_1loop_jax reference form when the current expression is symbolically equivalent but not text-identical.";
GetIndependentKernel::usage = "GetIndependentKernel[name] returns one exact real-space independent kernel expression by name.";
Ps1LoopNuBiases::usage = "Ps1LoopNuBiases[] returns the FFTLog nu-bias choices used by ps_1loop_jax for real-space matter, real-space biased tracers, and redshift-space biased tracers.";
LoadLinearSpectrum::usage = "LoadLinearSpectrum[path] imports a two-column linear power spectrum table and returns raw data plus interpolants.";
BuildNoWiggleSpectrum::usage = "BuildNoWiggleSpectrum[linAssoc, opts] builds smooth no-wiggle and residual wiggle spectra.";
SplitNoWiggleSpectrum::usage = "SplitNoWiggleSpectrum[linAssoc, width] is a compatibility alias of BuildNoWiggleSpectrum.";
MakeIRResummedSpectrum::usage = "MakeIRResummedSpectrum[splitAssoc, sigma] returns a simple isotropically IR-resummed linear spectrum association.";
GetSigma2::usage = "GetSigma2[pkNwAssoc, kS, rBAO] computes the isotropic BAO-damping integral from the no-wiggle spectrum.";
GetDeltaSigma2::usage = "GetDeltaSigma2[pkNwAssoc, kS, rBAO] computes the anisotropic BAO-damping correction from the no-wiggle spectrum.";
BuildIRDampingFactor::usage = "BuildIRDampingFactor[pars, sigma2, dsigma2] returns an Association containing SigmaTot2 and Exp[-k^2 SigmaTot2(mu)] helpers.";
FFTLogDecompose::usage = "FFTLogDecompose[plin, {kmin,kmax}, n, bias] computes a discrete FFTLog exponent grid and coefficients.";
ClearFFTLogCache::usage = "ClearFFTLogCache[] clears cached FFTLog-sampled M13/M22 matrices and cached linear-spectrum integrals.";
EvaluateM13Contribution::usage = "EvaluateM13Contribution[expr, fftAssoc, k, plin] evaluates a symbolic M13 kernel at a given wavenumber.";
EvaluateM22Contribution::usage = "EvaluateM22Contribution[expr, fftAssoc, k] evaluates a symbolic M22 kernel at a given wavenumber.";
EvaluateM22ContributionComponents::usage = "EvaluateM22ContributionComponents[expr, fftAssoc, k] returns the loop, k->0 subtraction, and total M22 contraction terms at a given wavenumber.";
SectorCoefficient::usage = "SectorCoefficient[sector, pars, mu] returns the bias-growth-angle prefactor for a symbolic kernel sector.";
BuildPkmu13UV::usage = "BuildPkmu13UV[kgrid, linAssoc, pars, mu] builds the ultraviolet P13 contribution used by ps_1loop_jax before EFT counterterms are added.";
GetLinearSpectrumIntegral::usage = "GetLinearSpectrumIntegral[linAssoc, kmin, kmax, num] returns the cached integral int dq q P_lin(q)/(2 pi^2) used in the 13_dd ultraviolet subtraction.";
BuildRawOneLoopSectorCache::usage = "BuildRawOneLoopSectorCache[fftAssoc, plin] computes and caches the mu-independent raw M13/M22 sector spectra on the FFTLog internal k grid.";
BuildRawRealSpaceSectorCache::usage = "BuildRawRealSpaceSectorCache[fftMatterAssoc, fftBiasAssoc, linAssoc] computes and caches the real-space raw basis terms on the shared internal FFTLog k grid.";
SubtractRawOneLoopSectorCaches::usage = "SubtractRawOneLoopSectorCaches[fullCache, nwCache] subtracts mu-independent raw one-loop sector caches sector by sector.";
AssembleOneLoopFromRawSectorCache::usage = "AssembleOneLoopFromRawSectorCache[kgrid, rawCache, pars, mu] assembles weighted P13/P22/P1Loop terms from a cached mu-independent raw sector cache.";
AssembleRealSpaceFromRawCache::usage = "AssembleRealSpaceFromRawCache[kgrid, rawCache, model, pars] assembles real-space basis terms or spectra from a cached real-space raw-sector cache.";
BuildPkmu1LoopRaw::usage = "BuildPkmu1LoopRaw[kgrid, fftAssoc, pars, mu, plin] evaluates sector-by-sector raw one-loop P13 and P22 pieces.";
BuildOneLoopComponents::usage = "BuildOneLoopComponents[kgrid, fftAssoc, pars, mu, plin] is a compatibility wrapper returning tree plus raw one-loop pieces.";
SubtractOneLoopComponents::usage = "SubtractOneLoopComponents[full, nw] subtracts one-loop Associations sector by sector.";
SummarizeOneLoopComponents::usage = "SummarizeOneLoopComponents[assoc] returns a compact numerical summary for one-loop Associations.";
BuildPkmuTree::usage = "BuildPkmuTree[kgrid, linAssoc, pars, mu] builds the raw tree-level redshift-space spectrum.";
BuildPkmuTreeIRResummed::usage = "BuildPkmuTreeIRResummed[kgrid, linAssoc, splitAssoc, pars, mu, dampAssoc] builds the IR-resummed tree-level spectrum.";
BuildPkmuCounterterms::usage = "BuildPkmuCounterterms[kgrid, mu, plinValues, pars] builds Gaussian EFT counterterms using c0/c2/c4 and optional cfog, with legacy cs0/cs2/cs4 aliases supported.";
BuildPkmuStochastic::usage = "BuildPkmuStochastic[kgrid, mu, pars] builds stochastic terms using P_shot/a0/a2/k_nl/ndens, with legacy Pshot/b4 fallback supported.";
AssemblePkmuRaw::usage = "AssemblePkmuRaw[treeAssoc, oneLoopAssoc, ctrs, stoch] assembles the raw total P(k,mu).";
AssemblePkmuIRResummed::usage = "AssemblePkmuIRResummed[treeIRAssoc, oneLoopNWAssoc, oneLoopWAssoc, dampAssoc, ctrs, stoch] assembles the IR-resummed total P(k,mu).";
BuildOneLoopComparisonPlots::usage = "BuildOneLoopComparisonPlots[fullAssoc, nwAssoc, wiggleAssoc] returns diagnostic plots for raw, no-wiggle, and wiggly one-loop pieces.";
BuildBenchmarkPlots::usage = "BuildBenchmarkPlots[kgrid, lin, split, full, nw, wiggle, treeIR, pkRaw, pkIR, mu, damp] returns compact benchmark diagnostics.";
ProjectPkmuToMultipoles::usage = "ProjectPkmuToMultipoles[kgrid, pkmuFnOrGrid, muSamples] projects P(k,mu) to l=0,2,4 multipoles.";
BuildMultipoleTablesFromPkmu::usage = "BuildMultipoleTablesFromPkmu[kgrid, pkmuFnOrGrid, muSamples] is a compatibility alias of ProjectPkmuToMultipoles.";
BuildMultipoleTables::usage = "BuildMultipoleTables[kgrid, fftAssoc, pars, plin, muSamples] is the older helper that builds multipoles directly from raw one-loop components.";
KernelFilename::usage = "KernelFilename[kind, sector] builds the exact downstream filename for a kernel sector.";
VerifiedNBFilename::usage = "VerifiedNBFilename[file] appends the _nb suffix before the .txt extension.";
KernelString::usage = "KernelString[expr] serializes a kernel expression in deterministic Mathematica InputForm syntax.";
ExportKernelText::usage = "ExportKernelText[path, expr] writes exactly one line of Mathematica InputForm with no trailing newline.";
ValidateKernelText::usage = "ValidateKernelText[path, expr] checks exact text serialization and symbolic round-trip equivalence.";
ValidateAgainstReference::usage = "ValidateAgainstReference[path, expr, vars] compares a kernel expression against a reference text file.";
ExportAllM13Kernels::usage = "ExportAllM13Kernels[dir] exports the full M13 kernel corpus to dir.";
ExportAllM22Kernels::usage = "ExportAllM22Kernels[dir] exports the full M22 kernel corpus to dir.";
ValidateExportedKernels::usage = "ValidateExportedKernels[kind, dir] validates exported kernel files.";
GetPs1LoopSectorReference::usage = "GetPs1LoopSectorReference[kgrid, linearPath] returns ps_1loop_jax M13/M22 sector values interpolated onto kgrid.";
GetPs1LoopContractionReference::usage = "GetPs1LoopContractionReference[fftAssoc, linearPath] returns ps_1loop_jax raw M13/M22 contraction data on the internal FFTLog grid, including M22 loop and k->0 subtraction pieces.";
CompareFFTLogContractionsWithPs1Loop::usage = "CompareFFTLogContractionsWithPs1Loop[fftAssoc, linearPath, plin] compares Mathematica raw M13/M22 contractions against ps_1loop_jax on the internal FFTLog grid and summarizes per-sector errors.";
GetM13ContractionIngredients::usage = "GetM13ContractionIngredients[fftAssoc, sectorFile, kTarget, plin] returns the Mathematica-side M13 contraction ingredients for one sector at the nearest internal FFTLog grid point.";
GetM22ContractionIngredients::usage = "GetM22ContractionIngredients[fftAssoc, sectorFile, kTarget] returns the Mathematica-side M22 contraction ingredients for one sector at the nearest internal FFTLog grid point, including transpose trial terms.";
GetPs1LoopM13ContractionIngredients::usage = "GetPs1LoopM13ContractionIngredients[fftAssoc, linearPath, sectorFile, kTarget] returns the ps_1loop_jax M13 contraction ingredients for one sector at the nearest internal FFTLog grid point.";
GetPs1LoopM22ContractionIngredients::usage = "GetPs1LoopM22ContractionIngredients[fftAssoc, linearPath, sectorFile, kTarget] returns the ps_1loop_jax M22 contraction ingredients for one sector at the nearest internal FFTLog grid point.";
CompareSingleM13ContractionWithPs1Loop::usage = "CompareSingleM13ContractionWithPs1Loop[fftAssoc, linearPath, sectorFile, kTarget, plin] compares Mathematica and ps_1loop_jax M13 contraction ingredients for one sector.";
CompareSingleM22ContractionWithPs1Loop::usage = "CompareSingleM22ContractionWithPs1Loop[fftAssoc, linearPath, sectorFile, kTarget] compares Mathematica and ps_1loop_jax M22 contraction ingredients for one sector and tests direct vs transposed matrix orientation.";
CompareM13M22WithPs1Loop::usage = "CompareM13M22WithPs1Loop[kgrid, linearPath, m13BySector, m22BySector] returns comparison plots against ps_1loop_jax reference sectors.";
$EFTwithFFTReferenceDir::usage = "$EFTwithFFTReferenceDir is the canonical directory containing reference analytic kernel text files.";
$EFTwithFFTOutputDir::usage = "$EFTwithFFTOutputDir is the default directory used when exporting analytic kernel text files.";
$EFTwithFFTEnableValidation::usage = "$EFTwithFFTEnableValidation toggles optional validation helpers in the notebook workflow.";
$UseParallelForKernels::usage = "$UseParallelForKernels toggles parallel evaluation in BuildAllM13Kernels and BuildAllM22Kernels.";
$UseParallelForMuIntegration::usage = "$UseParallelForMuIntegration toggles parallel evaluation in BuildPkmu1LoopRaw and BuildOneLoopComponents.";
$UseParallelForMultipole::usage = "$UseParallelForMultipole toggles parallel evaluation in BuildMultipoleTables and ProjectPkmuToMultipoles.";


Begin["`Private`"];
(* Parallelization flags - default to False for deterministic behavior *)
(* Parallelization flags - default to False for deterministic behavior *)
$UseParallelForKernels = False;
$UseParallelForMuIntegration = False;
$UseParallelForMultipole = False;

(* Distribute definitions to parallel kernels when they are launched *)
On[Parallel`DistributeDefinitions];

(* Ensure kernel definitions are available for parallel evaluation *)
$KernelContext = Context[];

(* Parallelization setup helper - call this at notebook start for M4 Max *)
SetupParallelKernels[n_Integer: 16] := Module[{},
    (* Enable parallelization flags BEFORE launching kernels so slaves get True values *)
    $UseParallelForKernels = True;
    $UseParallelForMuIntegration = True;
    $UseParallelForMultipole = True;
    
    Print["Launching ", n, " kernels for M4 Max..."];
    LaunchKernels[n];
    Print["Launched ", Length[Kernels[]], " kernels"];
    
    (* Distribute all EFTwithFFT symbols to parallel kernels *)
    (* For SetDelayed symbols, we need to evaluate them first on the master kernel *)
    $M13Sectors; (* Evaluate to ensure definition is cached *)
    $M22Sectors; (* Evaluate to ensure definition is cached *)
    
    
    DistributeDefinitions[BuildK13Sector];
    DistributeDefinitions[BuildK22Sector];
    DistributeDefinitions[deriveM13Expression];
    DistributeDefinitions[deriveM22Expression];
    DistributeDefinitions[EvaluateM13Contribution];
    DistributeDefinitions[EvaluateM22Contribution];
    DistributeDefinitions[SectorCoefficient];
    
    (* Now distribute the computed values *)
    DistributeDefinitions[$M13Sectors, Evaluate];
    DistributeDefinitions[$M22Sectors, Evaluate];
    
    Print["Parallelization enabled"];
    Length[Kernels[]]
];


$EFTwithFFTNotebookDir = Replace[DirectoryName[$InputFileName], {
    _String?(StringLength[#] > 0 &) :> DirectoryName[$InputFileName],
    _ :> Directory[]
}];

If[!ValueQ[$EFTwithFFTReferenceDir],
    $EFTwithFFTReferenceDir = FileNameJoin[{
        $HomeDirectory,
        "ps_1loop_jax-for-pfs",
        "src",
        "ps_1loop_jax",
        "pt_matrix",
        "redshift_space",
        "gauss"
    }]
];

If[!ValueQ[$EFTwithFFTOutputDir], $EFTwithFFTOutputDir = Automatic];
If[!ValueQ[$EFTwithFFTEnableValidation], $EFTwithFFTEnableValidation = True];

$M13SectorFilenames := {
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-0_f-2_mu-4.txt",
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-0_f-3_mu-4.txt",
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-0_f-3_mu-6.txt",
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-1_f-1_mu-2.txt",
    "M13_gg_rsd=b1-0_bG2-1_bGamma3-0_f-1_mu-2.txt",
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-0_f-1_mu-2.txt",
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-0_f-2_mu-2.txt",
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-0_f-2_mu-4.txt",
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-1_f-0_mu-0.txt",
    "M13_gg_rsd=b1-1_bG2-1_bGamma3-0_f-0_mu-0.txt",
    "M13_gg_rsd=b1-2_bG2-0_bGamma3-0_f-0_mu-0.txt",
    "M13_gg_rsd=b1-2_bG2-0_bGamma3-0_f-1_mu-2.txt"
};

$M22SectorFilenames := {
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-2_mu-4.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-3_mu-4.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-3_mu-6.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-4_mu-4.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-4_mu-6.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-4_mu-8.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-1_f-1_mu-2.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-1_f-2_mu-2.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-1_f-2_mu-4.txt",
    "M22_gg_rsd=b1-0_b2-0_bG2-2_f-0_mu-0.txt",
    "M22_gg_rsd=b1-0_b2-1_bG2-0_f-1_mu-2.txt",
    "M22_gg_rsd=b1-0_b2-1_bG2-0_f-2_mu-2.txt",
    "M22_gg_rsd=b1-0_b2-1_bG2-0_f-2_mu-4.txt",
    "M22_gg_rsd=b1-0_b2-1_bG2-1_f-0_mu-0.txt",
    "M22_gg_rsd=b1-0_b2-2_bG2-0_f-0_mu-0.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-1_mu-2.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-2_mu-2.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-2_mu-4.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-3_mu-4.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-3_mu-6.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-1_f-0_mu-0.txt",
    "M22_gg_rsd=b1-1_b2-0_bG2-1_f-1_mu-2.txt",
    "M22_gg_rsd=b1-1_b2-1_bG2-0_f-0_mu-0.txt",
    "M22_gg_rsd=b1-1_b2-1_bG2-0_f-1_mu-2.txt",
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-0_mu-0.txt",
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-1_mu-2.txt",
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-2_mu-2.txt",
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-2_mu-4.txt"
};

$RealSpaceGaussianKernelNames := {
    "13_dd",
    "13_dv",
    "13_vv",
    "22_dd",
    "22_dv",
    "22_vv",
    "I_d2",
    "I_G2",
    "I_d2_d2",
    "I_d2_G2",
    "I_G2_G2",
    "F_G2",
    "I_d2_v"
};

$RealSpaceM13RawKernelNames := {"13_dd", "F_G2"};
$RealSpaceM22RawKernelNames := {"22_dd", "I_d2", "I_G2", "I_d2_d2", "I_d2_G2", "I_G2_G2", "I_d2_v"};

parseM13Filename[file_String] := Module[{rules},
    rules = Association @ Map[
        Function[token,
            With[{parts = StringSplit[token, "-"]},
                parts[[1]] -> ToExpression[parts[[2]]]
            ]
        ],
        StringSplit[StringReplace[file, {"M13_gg_rsd=" -> "", ".txt" -> ""}], "_"]
    ];
    <|
        "Kind" -> "M13",
        "Filename" -> file,
        "b1" -> rules["b1"],
        "bG2" -> rules["bG2"],
        "bGamma3" -> rules["bGamma3"],
        "f" -> rules["f"],
        "mu" -> rules["mu"]
    |>
];

parseM22Filename[file_String] := Module[{rules},
    rules = Association @ Map[
        Function[token,
            With[{parts = StringSplit[token, "-"]},
                parts[[1]] -> ToExpression[parts[[2]]]
            ]
        ],
        StringSplit[StringReplace[file, {"M22_gg_rsd=" -> "", ".txt" -> ""}], "_"]
    ];
    <|
        "Kind" -> "M22",
        "Filename" -> file,
        "b1" -> rules["b1"],
        "b2" -> rules["b2"],
        "bG2" -> rules["bG2"],
        "f" -> rules["f"],
        "mu" -> rules["mu"]
    |>
];

$M13Sectors := Module[{fns = $M13SectorFilenames}, parseM13Filename /@ fns];
$M22Sectors := Module[{fns = $M22SectorFilenames}, parseM22Filename /@ fns];

ResolveOutputDir[dir_: Automatic] := Replace[dir, Automatic :> Replace[$EFTwithFFTOutputDir, Automatic :> $EFTwithFFTReferenceDir]];
KernelFilename["M13", sector_Association] := StringTemplate["M13_gg_rsd=b1-`b1`_bG2-`bG2`_bGamma3-`bGamma3`_f-`f`_mu-`mu`.txt"][sector];
KernelFilename["M22", sector_Association] := StringTemplate["M22_gg_rsd=b1-`b1`_b2-`b2`_bG2-`bG2`_f-`f`_mu-`mu`.txt"][sector];
VerifiedNBFilename[file_String] := StringReplace[file, ".txt" -> "_nb.txt"];
kernelReferencePath[file_String] := FileNameJoin[{$EFTwithFFTReferenceDir, file}];
realSpaceKernelReferencePath[name_String] := Lookup[$IndependentKernelPaths, name, Missing["UnknownIndependentKernel", name]];
Clear[parseKernelString, referenceKernelText, referenceKernelExpr, loadIndependentKernel];
parseKernelString[text_String] := replaceNamedSymbols[
    ReleaseHold @ ToExpression[text, InputForm, HoldComplete],
    <|"nu1" -> nu1, "nu2" -> nu2|>
];
referenceKernelText[path_String] := referenceKernelText[path] = StringTrim[Import[path, "Text"]];
referenceKernelExpr[path_String] := referenceKernelExpr[path] = parseKernelString[referenceKernelText[path]];

$IndependentKernelPaths = <|
    "13_dd" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/13_dd.txt",
    "13_dv" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/13_dv.txt",
    "13_vv" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/13_vv.txt",
    "F_G2" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/F_G2.txt",
    "F_phi" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/lpng/F_phi.txt",
    "22_dd" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/22_dd.txt",
    "22_dv" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/22_dv.txt",
    "22_vv" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/22_vv.txt",
    "I_d2" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/I_d2.txt",
    "I_G2" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/I_G2.txt",
    "I_d2_d2" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/I_d2_d2.txt",
    "I_G2_G2" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/I_G2_G2.txt",
    "I_d2_G2" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/I_d2_G2.txt",
    "I_d2_v" -> "/Users/nguyenmn/ps_1loop_jax-for-pfs/src/ps_1loop_jax/pt_matrix/real_space/gauss/I_d2_v.txt"
|>;

loadIndependentKernel[name_String] := loadIndependentKernel[name] = Module[{path},
    path = Lookup[$IndependentKernelPaths, name, Missing["UnknownIndependentKernel", name]];
    If[MissingQ[path], path, parseKernelString[Import[path, "Text"]]]
];

independentKernel[name_String] := loadIndependentKernel[name];

GetIndependentKernel[name_String] := independentKernel[name];

Ps1LoopNuBiases[] := <|
    "pk_lin nu=-0.3" -> -0.3,
    "pk_lin nu=-0.7" -> -0.7,
    "pk_lin nu=-1.6" -> -1.6,
    "RealSpaceMatter" -> -0.3,
    "RealSpaceBias" -> -1.6,
    "RedshiftSpaceGaussian" -> -0.7
|>;

ClearAll[deriveM13ExpressionCache];
deriveM13Expression[file_String] := deriveM13Expression[file] = Switch[file,
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-0_f-2_mu-4.txt", independentKernel["13_vv"],
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-0_f-3_mu-4.txt", (3/10) independentKernel["F_G2"],
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-0_f-3_mu-6.txt", 2 independentKernel["13_dv"] - (7/30) independentKernel["F_G2"],
    "M13_gg_rsd=b1-0_bG2-0_bGamma3-1_f-1_mu-2.txt", (4/5) independentKernel["F_G2"],
    "M13_gg_rsd=b1-0_bG2-1_bGamma3-0_f-1_mu-2.txt", 2 independentKernel["F_G2"],
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-0_f-1_mu-2.txt", 2 independentKernel["13_dv"],
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-0_f-2_mu-2.txt", (3/10) independentKernel["F_G2"],
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-0_f-2_mu-4.txt", (39/4) independentKernel["13_dv"] - (23/4) independentKernel["13_vv"],
    "M13_gg_rsd=b1-1_bG2-0_bGamma3-1_f-0_mu-0.txt", (4/5) independentKernel["F_G2"],
    "M13_gg_rsd=b1-1_bG2-1_bGamma3-0_f-0_mu-0.txt", 2 independentKernel["F_G2"],
    "M13_gg_rsd=b1-2_bG2-0_bGamma3-0_f-0_mu-0.txt", independentKernel["13_dd"],
    "M13_gg_rsd=b1-2_bG2-0_bGamma3-0_f-1_mu-2.txt", 2 independentKernel["F_phi"],
    _, Missing["UnknownM13Sector", file]
];

ClearAll[deriveM22ExpressionCache];
deriveM22Expression[file_String] := deriveM22Expression[file] = Switch[file,
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-2_mu-4.txt", independentKernel["22_vv"],
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-3_mu-4.txt", (-7/4) independentKernel["22_dv"] + (7/4) independentKernel["22_vv"],
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-3_mu-6.txt", (9/4) independentKernel["22_dv"] - (1/4) independentKernel["22_vv"],
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-4_mu-4.txt", (3/32) independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-4_mu-6.txt", ((-3 + 2*nu1 + 2*nu2)*(-1 + 2*nu1 + 2*nu2)*(1 + 2*nu1 + 2*nu2)*(1 + 2*(nu1^2 - 4*nu1*nu2 + nu2^2)))/(16*nu1*(1 + nu1)*(-1 + 2*nu1)*nu2*(1 + nu2)*(-1 + 2*nu2)),
    "M22_gg_rsd=b1-0_b2-0_bG2-0_f-4_mu-8.txt", ((-3 + 2*nu1 + 2*nu2)*(-1 + 2*nu1 + 2*nu2)*(1 + 2*nu1 + 2*nu2)*(3 + 2*nu1 + 2*nu2))/(32*nu1*(1 + nu1)*nu2*(1 + nu2)),
    "M22_gg_rsd=b1-0_b2-0_bG2-1_f-1_mu-2.txt", 2 independentKernel["I_G2"] + (4/7) independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-0_b2-0_bG2-1_f-2_mu-2.txt", (1/2) independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-0_b2-0_bG2-1_f-2_mu-4.txt", 2 independentKernel["I_G2"] - (1/14) independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-0_b2-0_bG2-2_f-0_mu-0.txt", independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-0_b2-1_bG2-0_f-1_mu-2.txt", independentKernel["I_d2_v"],
    "M22_gg_rsd=b1-0_b2-1_bG2-0_f-2_mu-2.txt", (1/4) independentKernel["I_d2_G2"],
    "M22_gg_rsd=b1-0_b2-1_bG2-0_f-2_mu-4.txt", independentKernel["I_d2"] - (1/28) independentKernel["I_d2_G2"],
    "M22_gg_rsd=b1-0_b2-1_bG2-1_f-0_mu-0.txt", independentKernel["I_d2_G2"],
    "M22_gg_rsd=b1-0_b2-2_bG2-0_f-0_mu-0.txt", (1/4) independentKernel["I_d2_d2"],
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-1_mu-2.txt", 2 independentKernel["22_dv"],
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-2_mu-2.txt", (1/2) independentKernel["I_G2"],
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-2_mu-4.txt", (33/4) independentKernel["22_dv"] - (17/4) independentKernel["22_vv"] + (9/49) independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-3_mu-4.txt", ((-3 + 2*nu1 + 2*nu2)*(-1 + 2*nu1 + 2*nu2)*(2 + nu1 + 4*nu1^3 + nu2 - 8*nu1^2*nu2 + 4*nu2^3 - 8*nu1*nu2*(1 + nu2)))/(8*nu1*(1 + nu1)*(-1 + 2*nu1)*nu2*(1 + nu2)*(-1 + 2*nu2)),
    "M22_gg_rsd=b1-1_b2-0_bG2-0_f-3_mu-6.txt", ((2 + nu1 + nu2)*(-3 + 2*nu1 + 2*nu2)*(-1 + 2*nu1 + 2*nu2)*(1 + 2*nu1 + 2*nu2))/(8*nu1*(1 + nu1)*nu2*(1 + nu2)),
    "M22_gg_rsd=b1-1_b2-0_bG2-1_f-0_mu-0.txt", 2 independentKernel["I_G2"],
    "M22_gg_rsd=b1-1_b2-0_bG2-1_f-1_mu-2.txt", 2 independentKernel["I_G2"] - (4/7) independentKernel["I_G2_G2"],
    "M22_gg_rsd=b1-1_b2-1_bG2-0_f-0_mu-0.txt", independentKernel["I_d2"],
    "M22_gg_rsd=b1-1_b2-1_bG2-0_f-1_mu-2.txt", 2 independentKernel["I_d2"] - independentKernel["I_d2_v"],
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-0_mu-0.txt", independentKernel["22_dd"],
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-1_mu-2.txt", 4 independentKernel["22_dd"] - 2 independentKernel["22_dv"],
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-2_mu-2.txt", ((-3 + 2*nu1 + 2*nu2)*(-1 + 2*nu1 + 2*nu2)*(2 + (-1 + nu1)*nu1*(1 + 2*nu1) - nu2 - 2*nu1*(1 + nu1)*nu2 - (1 + 2*nu1)*nu2^2 + 2*nu2^3))/(8*nu1*(1 + nu1)*(-1 + 2*nu1)*nu2*(1 + nu2)*(-1 + 2*nu2)),
    "M22_gg_rsd=b1-2_b2-0_bG2-0_f-2_mu-4.txt", ((1 + nu1 + nu2)*(2 + nu1 + nu2)*(-3 + 2*nu1 + 2*nu2)*(-1 + 2*nu1 + 2*nu2))/(8*nu1*(1 + nu1)*nu2*(1 + nu2)),
    _, Missing["UnknownM22Sector", file]
];

BuildK13Sector[sector_Association] := Module[{file = Lookup[sector, "Filename", KernelFilename["M13", sector]]}, deriveM13Expression[file]];
BuildK22Sector[sector_Association] := Module[{file = Lookup[sector, "Filename", KernelFilename["M22", sector]]}, deriveM22Expression[file]];
Options[BuildKernelCorpus] = {"CanonicalizeForReference" -> Automatic};

rawKernelCorpus["RealSpace"] := AssociationMap[independentKernel, $RealSpaceGaussianKernelNames];
rawKernelCorpus["M13"] := Association @@ mapMaybeParallel[
    $UseParallelForKernels,
    Function[sector, sector["Filename"] -> BuildK13Sector[sector]],
    $M13Sectors
];
rawKernelCorpus["M22"] := Association @@ mapMaybeParallel[
    $UseParallelForKernels,
    Function[sector, sector["Filename"] -> BuildK22Sector[sector]],
    $M22Sectors
];

canonicalizeReferencePath["RealSpace", name_String] := realSpaceKernelReferencePath[name];
canonicalizeReferencePath["M13", file_String] := kernelReferencePath[file];
canonicalizeReferencePath["M22", file_String] := kernelReferencePath[file];

kernelReferenceVarsFromFile[file_String] := If[StringStartsQ[file, "M13"], {nu1}, {nu1, nu2}];
realSpaceKernelVars[name_String] := If[
    StringStartsQ[name, "13"] || MemberQ[{"F_G2", "F_phi"}, name],
    {nu1},
    {nu1, nu2}
];

referenceNumericMatchQ[path_String, expr_, vars_List] := Module[
    {refExpr, samples, comparisons, names},
    refExpr = referenceKernelExpr[path];
    names = SymbolName /@ vars;
    samples = sampleRuleAssociations[names];
    comparisons = Table[
        Quiet @ Check[
            Abs[N[expr /. namedRules[expr, rules], 50] - N[refExpr /. namedRules[refExpr, rules], 50]] < 10^-20,
            False
        ],
        {rules, samples}
    ];
    And @@ comparisons
];

zeroKernelDifferenceQ[diff_] := Module[
    {normalized, numerator},
    normalized = Quiet @ Check[Cancel @ Together[diff], diff];
    numerator = Quiet @ Check[Numerator[normalized], normalized];
    TrueQ[normalized === 0] ||
    TrueQ[numerator === 0] ||
    TrueQ[Simplify[numerator == 0]] ||
    TrueQ[FullSimplify[numerator == 0]]
];

referenceSymbolicMatchQ[path_String, expr_] := Module[
    {refExpr},
    refExpr = referenceKernelExpr[path];
    TrueQ @ TimeConstrained[
        zeroKernelDifferenceQ[expr - refExpr] || TrueQ[FullSimplify[expr == refExpr]],
        10.0,
        False
    ]
];

CanonicalizeKernelForReference[file_String, expr_] := Module[
    {path, refExpr, vars},
    path = kernelReferencePath[file];
    If[!StringQ[path] || !FileExistsQ[path], Return[expr]];
    If[KernelString[expr] === referenceKernelText[path], Return[expr]];
    vars = kernelReferenceVarsFromFile[file];
    refExpr = referenceKernelExpr[path];
    If[referenceSymbolicMatchQ[path, expr] || referenceNumericMatchQ[path, expr, vars], refExpr, expr]
];

BuildKernelCorpus[kind_String, opts : OptionsPattern[]] := Module[
    {canonicalizeQ, corpus},
    canonicalizeQ = Replace[
        OptionValue["CanonicalizeForReference"],
        Automatic :> MemberQ[{"M13", "M22"}, kind]
    ];
    corpus = rawKernelCorpus[kind];
    If[TrueQ[canonicalizeQ] && kind =!= "RealSpace",
        Association @ KeyValueMap[Function[{file, expr}, file -> CanonicalizeKernelForReference[file, expr]], corpus],
        corpus
    ]
];

BuildAllM13Kernels[] := BuildKernelCorpus["M13"];
BuildAllM22Kernels[] := BuildKernelCorpus["M22"];

kernelMismatchClassification[path_String, expr_, vars_List] := Module[
    {exactText, symbolic, numeric},
    exactText = KernelString[expr] === referenceKernelText[path];
    symbolic = If[exactText, True, referenceSymbolicMatchQ[path, expr]];
    numeric = If[exactText || symbolic, True, referenceNumericMatchQ[path, expr, vars]];
    <|
        "ExactText" -> exactText,
        "SymbolicEquivalent" -> symbolic,
        "ReferenceNumeric" -> numeric,
        "Classification" -> Which[
            exactText, "ExactTextMatch",
            symbolic || numeric, "CanonicalizationOnly",
            True, "FormulaMismatch"
        ]
    |>
];

ClassifyKernelMismatches[kind_String] := Module[
    {corpus, referencePathFn, byKernel, mismatches},
    corpus = BuildKernelCorpus[kind, "CanonicalizeForReference" -> False];
    referencePathFn = Switch[kind,
        "RealSpace", realSpaceKernelReferencePath,
        "M13" | "M22", kernelReferencePath,
        _, Return[$Failed]
    ];
    byKernel = Association @ KeyValueMap[
        Function[{name, expr},
            With[{path = referencePathFn[If[kind === "RealSpace", name, name]]},
                name -> If[StringQ[path] && FileExistsQ[path],
                    kernelMismatchClassification[
                        path,
                        expr,
                        If[kind === "RealSpace", realSpaceKernelVars[name], If[kind === "M13", {nu1}, {nu1, nu2}]]
                    ],
                    <|"ExactText" -> False, "SymbolicEquivalent" -> False, "ReferenceNumeric" -> False, "Classification" -> "MissingReference"|>
                ]
            ]
        ],
        corpus
    ];
    mismatches = Select[byKernel, #[ "Classification"] =!= "ExactTextMatch" &];
    <|
        "Kind" -> kind,
        "Summary" -> Counts[Lookup[Values[byKernel], "Classification"]],
        "ByKernel" -> byKernel,
        "Mismatches" -> mismatches
    |>
];

logExtrapolateSpectrum[x_List, y_List, xmin_: 10^-5, xmax_: 10^4, numExtrap_: 10] := Module[
    {dlnxLow, dlnyLow, numLow, xLow, yLow, dlnxHigh, dlnyHigh, numHigh, xHigh, yHigh},
    dlnxLow = Log[x[[2]]/x[[1]]];
    dlnyLow = Log[y[[2]]/y[[1]]];
    numLow = Floor[Log[x[[1]]/xmin]/dlnxLow] + 1;
    xLow = x[[1]] * Exp[dlnxLow * numLow/numExtrap * Range[-numExtrap, -1]];
    yLow = y[[1]] * Exp[dlnyLow * numLow/numExtrap * Range[-numExtrap, -1]];
    dlnxHigh = Log[x[[-1]]/x[[-2]]];
    dlnyHigh = Log[y[[-1]]/y[[-2]]];
    numHigh = Floor[Log[xmax/x[[-1]]]/dlnxHigh] + 1;
    xHigh = x[[-1]] * Exp[dlnxHigh * numHigh/numExtrap * Range[1, numExtrap]];
    yHigh = y[[-1]] * Exp[dlnyHigh * numHigh/numExtrap * Range[1, numExtrap]];
    {Join[xLow, x, xHigh], Join[yLow, y, yHigh]}
];

LoadLinearSpectrum[path_String] := Module[{data, x, y, xExtrap, yExtrap, logInterp},
    data = SortBy[Import[path, "Table"], First];
    x = data[[All, 1]];
    y = data[[All, 2]];
    {xExtrap, yExtrap} = logExtrapolateSpectrum[x, y];
    logInterp = Interpolation[
        Transpose[{Log[xExtrap], Log[yExtrap]}],
        InterpolationOrder -> Min[3, Length[xExtrap] - 1]
    ];
    <|
        "Path" -> path,
        "Data" -> data,
        "k" -> x,
        "P" -> y,
        "kMin" -> First[xExtrap],
        "kMax" -> Last[xExtrap],
        "kExtrap" -> xExtrap,
        "PExtrap" -> yExtrap,
        "Plin" -> Function[{kk}, Quiet@Exp[logInterp[Log[kk]]]]
    |>
];

gaussianLogSmoothSplit[linAssoc_Association, width_] := Module[
    {k, p, logp, sigma, kernel, radius, smoothLog, pNw, pW, nwInterp, wInterp},
    k = linAssoc["k"];
    p = linAssoc["P"];
    logp = Log[p];
    sigma = Max[1., N[width]];
    radius = Max[2, Ceiling[4 sigma]];
    kernel = Exp[-Range[-radius, radius]^2/(2 sigma^2)];
    kernel = kernel/Total[kernel];
    smoothLog = ListCorrelate[kernel, logp, {radius + 1, -(radius + 1)}, logp];
    pNw = Exp[smoothLog];
    pW = p - pNw;
    nwInterp = Interpolation[Transpose[{k, pNw}], InterpolationOrder -> 1];
    wInterp = Interpolation[Transpose[{k, pW}], InterpolationOrder -> 1];
    Join[linAssoc, <|
        "Width" -> width,
        "SplitMethod" -> "GaussianLogSmooth",
        "PnwData" -> Transpose[{k, pNw}],
        "PwData" -> Transpose[{k, pW}],
        "PnwFunction" -> Function[{kk}, Quiet@nwInterp[kk]],
        "PwFunction" -> Function[{kk}, Quiet@wInterp[kk]]
    |>]
];

Options[BuildNoWiggleSpectrum] = {
    "Width" -> 8,
    "Method" -> "ps_1loop_jax",
    "h" -> Automatic
};

buildNoWiggleSpectrumFromPs1Loop[linAssoc_Association, h_?NumericQ] := Module[
    {path, tempPath, code, result, parsed, k, pNw, pW, nwInterp, wInterp},
    path = Lookup[linAssoc, "Path", Missing["NoPath"]];
    tempPath = None;
    If[MissingQ[path] || !FileExistsQ[path],
        tempPath = FileNameJoin[{$TemporaryDirectory, "eftwithfft_linear_" <> IntegerString[Hash[linAssoc["Data"]], 16] <> ".dat"}];
        Export[tempPath, linAssoc["Data"], "Table"];
        path = tempPath;
    ];
    code = StringRiffle[{
        "import json, sys, numpy as np",
        "sys.path.insert(0, '/Users/nguyenmn/ps_1loop_jax-for-pfs/src')",
        "from ps_1loop_jax import ir_resum",
        "data = np.loadtxt(sys.argv[1])",
        "pk_data = {'k': data[:, 0], 'pk': data[:, 1]}",
        "res = ir_resum.get_pk_nw_data(pk_data, float(sys.argv[2]), kmin_interp=float(sys.argv[3]), kmax_interp=float(sys.argv[4]))",
        "payload = {'k': np.asarray(res['k']).tolist(), 'pk': np.asarray(res['pk']).tolist()}",
        "print(json.dumps(payload))"
    }, "\n"];
    result = Quiet @ Check[
        RunProcess[{
            ps1LoopPythonExecutable[],
            "-c",
            code,
            path,
            ToString[FortranForm@N[h, 16]],
            ToString[FortranForm@N[linAssoc["kMin"], 16]],
            ToString[FortranForm@N[linAssoc["kMax"], 16]]
        }, "StandardOutput"],
        $Failed
    ];
    If[StringQ[tempPath] && FileExistsQ[tempPath], Quiet@DeleteFile[tempPath]];
    parsed = Quiet @ Check[ImportString[result, "RawJSON"], $Failed];
    If[!AssociationQ[parsed] || !KeyExistsQ[parsed, "k"] || !KeyExistsQ[parsed, "pk"], Return[$Failed]];
    k = N @ parsed["k"];
    pNw = N @ parsed["pk"];
    pW = (linAssoc["Plin"] /@ k) - pNw;
    nwInterp = Interpolation[Transpose[{k, pNw}], InterpolationOrder -> 1];
    wInterp = Interpolation[Transpose[{k, pW}], InterpolationOrder -> 1];
    Join[linAssoc, <|
        "SplitMethod" -> "ps_1loop_jax",
        "h" -> h,
        "PnwData" -> Transpose[{k, pNw}],
        "PwData" -> Transpose[{k, pW}],
        "PnwFunction" -> Function[{kk}, Quiet@nwInterp[kk]],
        "PwFunction" -> Function[{kk}, Quiet@wInterp[kk]]
    |>]
];

BuildNoWiggleSpectrum[linAssoc_Association, opts : OptionsPattern[]] := Module[
    {method, h, width, splitAssoc},
    method = OptionValue["Method"];
    h = Replace[OptionValue["h"], Automatic :> Lookup[linAssoc, "h", 0.67]];
    width = OptionValue["Width"];
    splitAssoc = If[method === "ps_1loop_jax",
        buildNoWiggleSpectrumFromPs1Loop[linAssoc, h],
        $Failed
    ];
    If[AssociationQ[splitAssoc], splitAssoc, gaussianLogSmoothSplit[linAssoc, width]]
];

SplitNoWiggleSpectrum[linAssoc_Association, width_: 8] := BuildNoWiggleSpectrum[linAssoc, "Width" -> width];

MakeIRResummedSpectrum[splitAssoc_Association, sigma_: 20.] := Join[
    splitAssoc,
    <|
        "IRSigma" -> sigma,
        "PIRFunction" -> Function[{kk}, Quiet@splitAssoc["PnwFunction"][kk] + Exp[-sigma kk^2] Quiet@splitAssoc["PwFunction"][kk]]
    |>
];

GetSigma2[pkNwAssoc_Association, kS_?NumericQ, rBAO_?NumericQ, kMin_: 10^-4, num_: 1000] := Module[
    {q, integrand},
    q = Subdivide[kMin, kS, num];
    integrand = (pkNwAssoc["PnwFunction"] /@ q) * (1 - SphericalBesselJ[0, rBAO q] + 2 SphericalBesselJ[2, rBAO q]);
    N[(Differences[q].MovingAverage[integrand, 2] // Total)/(6 Pi^2)]
];

GetDeltaSigma2[pkNwAssoc_Association, kS_?NumericQ, rBAO_?NumericQ, kMin_: 10^-4, num_: 1000] := Module[
    {q, integrand},
    q = Subdivide[kMin, kS, num];
    integrand = (pkNwAssoc["PnwFunction"] /@ q) * SphericalBesselJ[2, rBAO q];
    N[(Differences[q].MovingAverage[integrand, 2] // Total)/(2 Pi^2)]
];

BuildIRDampingFactor[pars_Association, sigma2_?NumericQ, dsigma2_?NumericQ] := Module[
    {f = Lookup[pars, "f", 0.]},
    <|
        "Sigma2" -> sigma2,
        "DeltaSigma2" -> dsigma2,
        "SigmaTot2" -> Function[{mu}, (1 + mu^2 f (2 + f)) sigma2 + f^2 mu^2 (mu^2 - 1) dsigma2],
        "DampingExponent" -> Function[{k, mu}, k^2 ((1 + mu^2 f (2 + f)) sigma2 + f^2 mu^2 (mu^2 - 1) dsigma2)],
        "Damping" -> Function[{k, mu}, Exp[-k^2 ((1 + mu^2 f (2 + f)) sigma2 + f^2 mu^2 (mu^2 - 1) dsigma2)]]
    |>
];

safeKernelValue[expr_] := Quiet @ Check[
    Module[{val = N[expr, 50]},
        If[NumericQ[val] && FreeQ[val, Indeterminate | ComplexInfinity | DirectedInfinity[_]], val, 0]
    ],
    0,
    {Power::indet, Infinity::indet, General::infy}
];

replaceNamedSymbols[expr_, assoc_Association] := expr /. s_Symbol /; KeyExistsQ[assoc, SymbolName[Unevaluated[s]]] :> assoc[SymbolName[Unevaluated[s]]];

m22LoopPrefactor[nu1_, nu2_] := Gamma[3/2 - nu1] * Gamma[3/2 - nu2] * Gamma[nu1 + nu2 - 3/2]/
    (8 Pi^(3/2) Gamma[nu1] Gamma[nu2] Gamma[3 - nu1 - nu2]);

If[!ValueQ[$FFTLogMatrixCache], $FFTLogMatrixCache = <||>];
If[!ValueQ[$FFTLogSectorCache], $FFTLogSectorCache = <||>];
If[!ValueQ[$LinearSpectrumIntegralCache], $LinearSpectrumIntegralCache = <||>];

ClearFFTLogCache[] := (
    $FFTLogMatrixCache = <||>;
    $FFTLogSectorCache = <||>;
    $LinearSpectrumIntegralCache = <||>;
);

fftAssocCacheKey[fftAssoc_Association] := Replace[
    Lookup[fftAssoc, "CacheKey", Missing["NoCacheKey"]],
    Missing["NoCacheKey"] :> {
        Lookup[fftAssoc, "Bias", Missing["NoBias"]],
        Lookup[fftAssoc, "kMin", Missing["NoKMin"]],
        Lookup[fftAssoc, "kMax", Missing["NoKMax"]],
        Lookup[fftAssoc, "N", Missing["NoN"]],
        Hash[Normal @ N @ Lookup[fftAssoc, "nu", {}]]
    }
];

mapMaybeParallel[flag_, fn_, list_List] := If[
    flag && Length[Kernels[]] > 0,
    ParallelMap[fn, list, Method -> "FinestGrained"],
    Map[fn, list]
];

sameNumericGridQ[a_List, b_List, tol_: 10^-12] := Length[a] == Length[b] && Max[Abs[N[a] - N[b]]] <= tol;

interpolateOntoGrid[kFrom_List, vals_List, kTo_List] := Module[{fn},
    If[sameNumericGridQ[kFrom, kTo], Return[N @ vals]];
    fn = Interpolation[Transpose[{N @ kFrom, N @ vals}], InterpolationOrder -> 1];
    N @ (fn /@ kTo)
];

interpolateAssociationOntoGrid[kFrom_List, assoc_Association, kTo_List] := AssociationMap[
    interpolateOntoGrid[kFrom, assoc[#], kTo] &,
    Keys[assoc]
];

getCachedPowerRows[fftAssoc_Association] := Module[
    {key, kGrid, nus},
    key = {"PowerRows", fftAssocCacheKey[fftAssoc]};
    If[KeyExistsQ[$FFTLogMatrixCache, key], Return[$FFTLogMatrixCache[key]]];
    kGrid = N @ Lookup[fftAssoc, "kSample", {}];
    nus = Lookup[fftAssoc, "nu", {}];
    $FFTLogMatrixCache[key] = N @ Outer[Power, kGrid, -2 nus];
    $FFTLogMatrixCache[key]
];

contractM13SampleOnGrid[sample_List, fftAssoc_Association, plinValues_List] := Module[
    {kGrid, coeffs, powerRows, weightedKernel, base},
    kGrid = N @ Lookup[fftAssoc, "kSample", {}];
    coeffs = Lookup[fftAssoc, "Coefficients", {}];
    powerRows = getCachedPowerRows[fftAssoc];
    weightedKernel = coeffs * sample;
    base = (kGrid^3) * N[plinValues];
    Re @ Chop[N[base * (powerRows . weightedKernel), 30], 10^-20]
];

contractM22SampleComponentsOnGrid[sampleMat_?MatrixQ, fftAssoc_Association] := Module[
    {kGrid, coeffs, coeffsK0, powerRows, weightedMat, loopCore, loopTerms, k0Scalar},
    kGrid = N @ Lookup[fftAssoc, "kSample", {}];
    coeffs = Lookup[fftAssoc, "Coefficients", {}];
    coeffsK0 = Lookup[fftAssoc, "CoefficientsK0", ConstantArray[0, Length[coeffs]]];
    powerRows = getCachedPowerRows[fftAssoc];
    weightedMat = Outer[Times, coeffs, coeffs] * sampleMat;
    loopCore = powerRows . weightedMat . Transpose[powerRows];
    loopTerms = Re @ Chop[N[(kGrid^3) * Diagonal[loopCore], 30], 10^-20];
    k0Scalar = Re @ Chop[
        N[
            Lookup[fftAssoc, "kMin", First[kGrid]]^3 * Total[Flatten[Outer[Times, coeffsK0, coeffsK0] * sampleMat]],
            30
        ],
        10^-20
    ];
    <|
        "LoopTerm" -> loopTerms,
        "K0Term" -> ConstantArray[k0Scalar, Length[kGrid]],
        "Total" -> loopTerms - k0Scalar
    |>
];

FFTLogDecompose[plin_, {kmin_?NumericQ, kmax_?NumericQ}, n_Integer: 64, bias_: -1.6] := Module[
    {ll, js, ks, pkVals, biasedVals, rawCoeffs, etaGrid, nuM, coeffsOrdered, coeffs, coeffsK0},
    ll = Log[kmax/kmin];
    js = Range[0, n - 1];
    ks = Exp[Subdivide[Log[kmin], Log[kmax], n - 1]];
    pkVals = plin /@ ks;
    biasedVals = pkVals * (ks/kmin)^(-bias);
    rawCoeffs = Table[Mean[biasedVals*Exp[-2 Pi I mode js/n]], {mode, 0, n - 1}];
    etaGrid = (2 Pi/(n/(n - 1) * ll)) * (Range[0, n] - Floor[n/2]);
    nuM = bias + I etaGrid;
    coeffsOrdered = Join[
        Conjugate[Reverse[rawCoeffs[[2 ;; Floor[n/2] + 1]]]],
        rawCoeffs[[1 ;; Floor[n/2] + 1]]
    ];
    coeffs = kmin^(-nuM) * coeffsOrdered;
    coeffs[[1]] = coeffs[[1]]/2;
    coeffs[[-1]] = coeffs[[-1]]/2;
    coeffsK0 = coeffs * (kmin^nuM);
    <|
        "kMin" -> kmin,
        "kMax" -> kmax,
        "L" -> ll,
        "N" -> n,
        "Bias" -> bias,
        "Eta" -> etaGrid,
        "nu" -> (-nuM/2),
        "nuM" -> nuM,
        "kSample" -> ks,
        "SampleValues" -> pkVals,
        "LinearData" -> Transpose[{ks, pkVals}],
        "SpectrumHash" -> Hash[N[pkVals, 20]],
        "Coefficients" -> coeffs,
        "CoefficientsK0" -> coeffsK0,
        "PlinFunction" -> plin,
        "CacheKey" -> {N[bias, 16], N[kmin, 16], N[kmax, 16], n, Hash[N[nuM, 20]]}
    |>
];

getCachedM13Sample[fftAssoc_Association, file_String, expr_: Automatic] := Module[
    {key, nus, resolvedExpr},
    key = {"M13", fftAssocCacheKey[fftAssoc], file};
    If[KeyExistsQ[$FFTLogMatrixCache, key], Return[$FFTLogMatrixCache[key]]];
    nus = fftAssoc["nu"];
    resolvedExpr = Replace[expr, Automatic :> BuildK13Sector[<|"Filename" -> file|>]];
    $FFTLogMatrixCache[key] = Table[
        safeKernelValue[replaceNamedSymbols[resolvedExpr, <|"nu1" -> nus[[i]]|>]],
        {i, Length[nus]}
    ];
    $FFTLogMatrixCache[key]
];

getCachedM22Sample[fftAssoc_Association, file_String, expr_: Automatic] := Module[
    {key, nus, resolvedExpr},
    key = {"M22", fftAssocCacheKey[fftAssoc], file};
    If[KeyExistsQ[$FFTLogMatrixCache, key], Return[$FFTLogMatrixCache[key]]];
    nus = fftAssoc["nu"];
    resolvedExpr = m22LoopPrefactor[nu1, nu2] * Replace[expr, Automatic :> BuildK22Sector[<|"Filename" -> file|>]];
    $FFTLogMatrixCache[key] = Transpose @ Table[
        safeKernelValue[replaceNamedSymbols[resolvedExpr, <|"nu1" -> nus[[ni]], "nu2" -> nus[[nj]]|>]],
        {ni, Length[nus]}, {nj, Length[nus]}
    ];
    $FFTLogMatrixCache[key]
];

BuildCachedM13SectorMatrices[fftAssoc_Association] := Association @@ mapMaybeParallel[
    $UseParallelForKernels,
    Function[sector,
        With[{file = sector["Filename"], expr = BuildK13Sector[sector]},
            file -> getCachedM13Sample[fftAssoc, file, expr]
        ]
    ],
    $M13Sectors
];

BuildCachedM22SectorMatrices[fftAssoc_Association] := Association @@ mapMaybeParallel[
    $UseParallelForKernels,
    Function[sector,
        With[{file = sector["Filename"], expr = BuildK22Sector[sector]},
            file -> getCachedM22Sample[fftAssoc, file, expr]
        ]
    ],
    $M22Sectors
];

EvaluateM13Contribution[expr_, fftAssoc_Association, k_?NumericQ, plin_: Automatic] := Module[
    {nus, coeffs, plinFunc, kernelVals, contribution, kval},
    nus = fftAssoc["nu"];
    coeffs = fftAssoc["Coefficients"];
    plinFunc = Replace[plin, Automatic :> fftAssoc["PlinFunction"]];
    kval = N[k, 30];
    kernelVals = If[
        ListQ[expr],
        expr,
        Table[
            safeKernelValue[replaceNamedSymbols[expr, <|"nu1" -> nus[[i]]|>]],
            {i, Length[nus]}
        ]
    ];
    powers = kval^(-2 nus);
    contribution = kval^3 * plinFunc[kval] * Total[coeffs * powers * kernelVals];
    Re @ Chop[N[contribution, 30], 10^-20]
];

EvaluateM22Contribution[expr_, fftAssoc_Association, k_?NumericQ] := Module[
    {nus, coeffs, coeffsK0, kernelVals, contribution, k0Contribution, kval},
    nus = fftAssoc["nu"];
    coeffs = fftAssoc["Coefficients"];
    coeffsK0 = Lookup[fftAssoc, "CoefficientsK0", ConstantArray[0, Length[coeffs]]];
    kval = N[k, 30];
    kernelVals = If[
        MatrixQ[expr],
        expr,
        Table[
            safeKernelValue[replaceNamedSymbols[expr, <|"nu1" -> nus[[ni]], "nu2" -> nus[[nj]]|>]],
            {ni, Length[nus]}, {nj, Length[nus]}
        ]
    ];
    powersMat = Outer[Times, kval^(-2 nus), kval^(-2 nus)];
    contribution = Total[Outer[Times, coeffs, coeffs] * powersMat * kernelVals, 2];
    k0Contribution = Lookup[fftAssoc, "kMin", kval]^3 * Total[Outer[Times, coeffsK0, coeffsK0] * kernelVals, 2];
    contribution = kval^3 * contribution - k0Contribution;
    Re @ Chop[N[contribution, 30], 10^-20]
];

EvaluateM22ContributionComponents[expr_, fftAssoc_Association, k_?NumericQ] := Module[
    {nus, coeffs, coeffsK0, kernelVals, loopTerm, k0Term, kval},
    nus = fftAssoc["nu"];
    coeffs = fftAssoc["Coefficients"];
    coeffsK0 = Lookup[fftAssoc, "CoefficientsK0", ConstantArray[0, Length[coeffs]]];
    kval = N[k, 30];
    kernelVals = If[
        MatrixQ[expr],
        expr,
        Table[
            safeKernelValue[replaceNamedSymbols[expr, <|"nu1" -> nus[[ni]], "nu2" -> nus[[nj]]|>]],
            {ni, Length[nus]}, {nj, Length[nus]}
        ]
    ];
    loopTerm = kval^3 * Total[Outer[Times, coeffs, coeffs] * Outer[Times, kval^(-2 nus), kval^(-2 nus)] * kernelVals, 2];
    k0Term = Lookup[fftAssoc, "kMin", kval]^3 * Total[Outer[Times, coeffsK0, coeffsK0] * kernelVals, 2];
    <|
        "LoopTerm" -> Re @ Chop[N[loopTerm, 30], 10^-20],
        "K0Term" -> Re @ Chop[N[k0Term, 30], 10^-20],
        "Total" -> Re @ Chop[N[loopTerm - k0Term, 30], 10^-20]
    |>
];

sectorPower[pars_Association, name_String, exponent_Integer] := If[exponent == 0, 1, Lookup[pars, name, 0]^exponent];
SectorCoefficient[sector_Association, pars_Association, mu_?NumericQ] := Times @@ {
    sectorPower[pars, "b1", Lookup[sector, "b1", 0]],
    sectorPower[pars, "b2", Lookup[sector, "b2", 0]],
    sectorPower[pars, "bG2", Lookup[sector, "bG2", 0]],
    sectorPower[pars, "bGamma3", Lookup[sector, "bGamma3", 0]],
    sectorPower[pars, "f", Lookup[sector, "f", 0]],
    If[Lookup[sector, "mu", 0] == 0, 1, mu^Lookup[sector, "mu", 0]]
};

sectorMetadata[file_String] := sectorMetadata[file] = Which[
    StringStartsQ[file, "M13_"], parseM13Filename[file],
    StringStartsQ[file, "M22_"], parseM22Filename[file],
    True, <|"Filename" -> file|>
];

buildFFTLinearAssociation[fftAssoc_Association, plinFunc_] := Module[
    {kEval, sampleValues, linData},
    kEval = Lookup[fftAssoc, "kSample", {}];
    sampleValues = Replace[
        Lookup[fftAssoc, "SampleValues", Missing["NoSampleValues"]],
        Missing["NoSampleValues"] :> (plinFunc /@ kEval)
    ];
    linData = Replace[
        Lookup[fftAssoc, "LinearData", Missing["NoLinearData"]],
        Missing["NoLinearData"] :> Transpose[{N @ kEval, N @ sampleValues}]
    ];
    <|
        "Plin" -> plinFunc,
        "kMin" -> Lookup[fftAssoc, "kMin", If[ListQ[kEval] && kEval =!= {}, Min[kEval], 10^-4]],
        "kMax" -> Lookup[fftAssoc, "kMax", If[ListQ[kEval] && kEval =!= {}, Max[kEval], 10^4]],
        "Data" -> linData,
        "SpectrumHash" -> Hash[N[linData, 20]]
    |>
];

rawCacheLinearOnGrid[rawCache_Association, kgrid_List] := Which[
    KeyExistsQ[rawCache, "LinAssoc"] && AssociationQ[rawCache["LinAssoc"]],
        rawCache["LinAssoc"]["Plin"] /@ kgrid,
    KeyExistsQ[rawCache, "PositiveLinAssoc"] && KeyExistsQ[rawCache, "NegativeLinAssoc"] &&
        AssociationQ[rawCache["PositiveLinAssoc"]] && AssociationQ[rawCache["NegativeLinAssoc"]],
        (rawCache["PositiveLinAssoc"]["Plin"] /@ kgrid) - (rawCache["NegativeLinAssoc"]["Plin"] /@ kgrid),
    True,
        Missing["NoLinearAssociation"]
];

getLinearSpectrumIntegral[linAssoc_Association, kmin_: 10^-4, kmax_: 10^4, num_: 1000] := Module[
    {key, q, lq, integrand},
    key = {
        Lookup[linAssoc, "Path", Hash[Normal @ linAssoc["Data"]]],
        N[kmin, 16],
        N[kmax, 16],
        num
    };
    If[KeyExistsQ[$LinearSpectrumIntegralCache, key], Return[$LinearSpectrumIntegralCache[key]]];
    lq = Subdivide[Log[kmin], Log[kmax], num];
    q = Exp[lq];
    integrand = q * (linAssoc["Plin"] /@ q);
    $LinearSpectrumIntegralCache[key] = N[(Differences[lq].MovingAverage[integrand, 2] // Total)/(2 Pi^2)];
    $LinearSpectrumIntegralCache[key]
];

GetLinearSpectrumIntegral[linAssoc_Association, kmin_: 10^-4, kmax_: 10^4, num_: 1000] := getLinearSpectrumIntegral[linAssoc, kmin, kmax, num];

BuildPkmu13UV[kgrid_List, linAssoc_Association, pars_Association, mu_: 0.] := Module[
    {f, b1, bG2, bGamma3, z1, z3uv, pkInt, pk},
    f = Lookup[pars, "f", 0.];
    b1 = Lookup[pars, "b1", 1.];
    bG2 = Lookup[pars, "bG2", 0.];
    bGamma3 = Lookup[pars, "bGamma3", 0.];
    z1 = b1 + f mu^2;
    z3uv = -61./315. * b1 - 64./21. * bG2 - 128./105. * bGamma3;
    z3uv += (-3./5. + 2./105. * b1) * f mu^2;
    z3uv += (-16./35. - 1./3. * b1) * f^2 mu^2;
    z3uv += (-46./105.) * f^2 mu^4;
    z3uv += (-1./3.) * f^3 mu^4;
    pkInt = getLinearSpectrumIntegral[linAssoc];
    pk = linAssoc["Plin"] /@ kgrid;
    <|"k" -> kgrid, "mu" -> mu, "P13UV" -> (kgrid^2 * pk * pkInt) * (z1 * z3uv)|>
];

BuildRawOneLoopSectorCache[fftAssoc_Association, plin_: Automatic] := Module[
    {
        plinFunc,
        linAssoc,
        key,
        kInternal,
        plinInternal,
        pkInt,
        sampledM13,
        sampledM22,
        m13BareAssoc,
        m22ComponentAssoc,
        m22BareAssoc,
        m22LoopAssoc,
        m22K0Assoc,
        p13Raw,
        p22
    },
    plinFunc = Replace[plin, Automatic :> fftAssoc["PlinFunction"]];
    linAssoc = buildFFTLinearAssociation[fftAssoc, plinFunc];
    key = {"RawSectors", fftAssocCacheKey[fftAssoc], Lookup[linAssoc, "SpectrumHash", Hash[Normal @ linAssoc["Data"]]]};
    If[KeyExistsQ[$FFTLogSectorCache, key], Return[$FFTLogSectorCache[key]]];
    kInternal = Lookup[fftAssoc, "kSample", {}];
    plinInternal = linAssoc["Plin"] /@ kInternal;
    pkInt = getLinearSpectrumIntegral[linAssoc];
    sampledM13 = BuildCachedM13SectorMatrices[fftAssoc];
    sampledM22 = BuildCachedM22SectorMatrices[fftAssoc];
    m13BareAssoc = Association @@ mapMaybeParallel[
        $UseParallelForMuIntegration,
        Function[sector,
            With[
                {
                    file = sector["Filename"],
                    sample = sampledM13[sector["Filename"]]
                },
                file -> contractM13SampleOnGrid[sample, fftAssoc, plinInternal]
            ]
        ],
        $M13Sectors
    ];
    m22ComponentAssoc = Association @@ mapMaybeParallel[
        $UseParallelForMuIntegration,
        Function[sector,
            With[
                {
                    file = sector["Filename"],
                    sample = sampledM22[sector["Filename"]]
                },
                file -> contractM22SampleComponentsOnGrid[sample, fftAssoc]
            ]
        ],
        $M22Sectors
    ];
    m22BareAssoc = AssociationMap[m22ComponentAssoc[#]["Total"] &, Keys[m22ComponentAssoc]];
    m22LoopAssoc = AssociationMap[m22ComponentAssoc[#]["LoopTerm"] &, Keys[m22ComponentAssoc]];
    m22K0Assoc = AssociationMap[m22ComponentAssoc[#]["K0Term"] &, Keys[m22ComponentAssoc]];
    p13Raw = Total[Values[m13BareAssoc]];
    p22 = Total[Values[m22BareAssoc]];
    $FFTLogSectorCache[key] = <|
        "CacheKind" -> "RawOneLoopSectorCache",
        "CacheKey" -> key,
        "FFTAssocCacheKey" -> fftAssocCacheKey[fftAssoc],
        "kInternal" -> kInternal,
        "LinAssoc" -> linAssoc,
        "PlinInternal" -> N @ plinInternal,
        "P13UVBaseInternal" -> N[(kInternal^2) * plinInternal * pkInt],
        "CachedM13" -> sampledM13,
        "CachedM22" -> sampledM22,
        "M13BySectorRawInternal" -> m13BareAssoc,
        "M22BySectorRawInternal" -> m22BareAssoc,
        "M22LoopBySectorInternal" -> m22LoopAssoc,
        "M22K0BySectorInternal" -> m22K0Assoc,
        "P13RawInternal" -> p13Raw,
        "P22Internal" -> p22,
        "P1LoopRawInternal" -> p13Raw + p22
    |>;
    $FFTLogSectorCache[key]
];

BuildRawRealSpaceSectorCache::grid = "Matter and bias FFT objects use different internal k grids and cannot be combined into one real-space raw cache.";
BuildRawRealSpaceSectorCache[fftMatterAssoc_Association, fftBiasAssoc_Association, linAssoc_Association] := Module[
    {
        key,
        kInternal,
        plinInternal,
        pkInt,
        sampledMatter13,
        sampledMatter22,
        sampledBias13,
        sampledBias22,
        m13Assoc,
        m22Assoc,
        p13Raw,
        p22Raw
    },
    If[!sameNumericGridQ[Lookup[fftMatterAssoc, "kSample", {}], Lookup[fftBiasAssoc, "kSample", {}]],
        Message[BuildRawRealSpaceSectorCache::grid];
        Return[$Failed];
    ];
    key = {
        "RealSpaceRawSectors",
        fftAssocCacheKey[fftMatterAssoc],
        fftAssocCacheKey[fftBiasAssoc],
        Lookup[linAssoc, "SpectrumHash", Hash[Normal @ linAssoc["Data"]]]
    };
    If[KeyExistsQ[$FFTLogSectorCache, key], Return[$FFTLogSectorCache[key]]];
    kInternal = Lookup[fftMatterAssoc, "kSample", {}];
    plinInternal = linAssoc["Plin"] /@ kInternal;
    pkInt = getLinearSpectrumIntegral[linAssoc];
    sampledMatter13 = AssociationMap[
        getCachedM13Sample[fftMatterAssoc, #, independentKernel[#]] &,
        {"13_dd"}
    ];
    sampledMatter22 = AssociationMap[
        getCachedM22Sample[fftMatterAssoc, #, independentKernel[#]] &,
        {"22_dd"}
    ];
    sampledBias13 = AssociationMap[
        getCachedM13Sample[fftBiasAssoc, #, independentKernel[#]] &,
        {"F_G2"}
    ];
    sampledBias22 = AssociationMap[
        getCachedM22Sample[fftBiasAssoc, #, independentKernel[#]] &,
        {"I_d2", "I_G2", "I_d2_d2", "I_d2_G2", "I_G2_G2", "I_d2_v"}
    ];
    m13Assoc = Join[
        AssociationMap[contractM13SampleOnGrid[sampledMatter13[#], fftMatterAssoc, plinInternal] &, Keys[sampledMatter13]],
        AssociationMap[contractM13SampleOnGrid[sampledBias13[#], fftBiasAssoc, plinInternal] &, Keys[sampledBias13]]
    ];
    m22Assoc = Join[
        AssociationMap[contractM22SampleComponentsOnGrid[sampledMatter22[#], fftMatterAssoc]["Total"] &, Keys[sampledMatter22]],
        AssociationMap[contractM22SampleComponentsOnGrid[sampledBias22[#], fftBiasAssoc]["Total"] &, Keys[sampledBias22]]
    ];
    p13Raw = Total[Values[m13Assoc]];
    p22Raw = Total[Values[m22Assoc]];
    $FFTLogSectorCache[key] = <|
        "CacheKind" -> "RealSpaceRawSectorCache",
        "CacheKey" -> key,
        "FFTAssocCacheKeyMatter" -> fftAssocCacheKey[fftMatterAssoc],
        "FFTAssocCacheKeyBias" -> fftAssocCacheKey[fftBiasAssoc],
        "kInternal" -> kInternal,
        "LinAssoc" -> linAssoc,
        "PlinInternal" -> N @ plinInternal,
        "P13UVBaseInternal" -> N[(61./315.) * (kInternal^2) * plinInternal * pkInt],
        "M13BySectorRawInternal" -> m13Assoc,
        "M22BySectorRawInternal" -> m22Assoc,
        "P13RawInternal" -> p13Raw,
        "P22Internal" -> p22Raw,
        "P1LoopRawInternal" -> p13Raw + p22Raw
    |>;
    $FFTLogSectorCache[key]
];

SubtractRawOneLoopSectorCaches::grid = "Raw sector caches use different internal k grids and cannot be subtracted.";
SubtractRawOneLoopSectorCaches::keys = "Raw sector caches use different sector keys and cannot be subtracted.";
SubtractRawOneLoopSectorCaches[full_Association, nw_Association] := Module[
    {m13Raw, m22Raw, m22Loop, m22K0},
    If[!sameNumericGridQ[full["kInternal"], nw["kInternal"]],
        Message[SubtractRawOneLoopSectorCaches::grid];
        Return[$Failed];
    ];
    If[
        Sort[Keys[full["M13BySectorRawInternal"]]] =!= Sort[Keys[nw["M13BySectorRawInternal"]]] ||
        Sort[Keys[full["M22BySectorRawInternal"]]] =!= Sort[Keys[nw["M22BySectorRawInternal"]]],
        Message[SubtractRawOneLoopSectorCaches::keys];
        Return[$Failed];
    ];
    m13Raw = AssociationMap[full["M13BySectorRawInternal"][#] - nw["M13BySectorRawInternal"][#] &, Keys[full["M13BySectorRawInternal"]]];
    m22Raw = AssociationMap[full["M22BySectorRawInternal"][#] - nw["M22BySectorRawInternal"][#] &, Keys[full["M22BySectorRawInternal"]]];
    m22Loop = If[
        KeyExistsQ[full, "M22LoopBySectorInternal"] && KeyExistsQ[nw, "M22LoopBySectorInternal"],
        AssociationMap[full["M22LoopBySectorInternal"][#] - nw["M22LoopBySectorInternal"][#] &, Keys[full["M22LoopBySectorInternal"]]],
        <||>
    ];
    m22K0 = If[
        KeyExistsQ[full, "M22K0BySectorInternal"] && KeyExistsQ[nw, "M22K0BySectorInternal"],
        AssociationMap[full["M22K0BySectorInternal"][#] - nw["M22K0BySectorInternal"][#] &, Keys[full["M22K0BySectorInternal"]]],
        <||>
    ];
    <|
        "CacheKind" -> "DifferenceRawOneLoopSectorCache",
        "ParentCacheKeys" -> {Lookup[full, "CacheKey", Missing["NotAvailable"]], Lookup[nw, "CacheKey", Missing["NotAvailable"]]},
        "FFTAssocCacheKey" -> Lookup[full, "FFTAssocCacheKey", Missing["NotAvailable"]],
        "kInternal" -> full["kInternal"],
        "PositiveLinAssoc" -> full["LinAssoc"],
        "NegativeLinAssoc" -> nw["LinAssoc"],
        "PlinInternal" -> If[KeyExistsQ[full, "PlinInternal"] && KeyExistsQ[nw, "PlinInternal"], full["PlinInternal"] - nw["PlinInternal"], Missing["NotAvailable"]],
        "P13UVBaseInternal" -> If[KeyExistsQ[full, "P13UVBaseInternal"] && KeyExistsQ[nw, "P13UVBaseInternal"], full["P13UVBaseInternal"] - nw["P13UVBaseInternal"], Missing["NotAvailable"]],
        "M13BySectorRawInternal" -> m13Raw,
        "M22BySectorRawInternal" -> m22Raw,
        "M22LoopBySectorInternal" -> m22Loop,
        "M22K0BySectorInternal" -> m22K0,
        "P13RawInternal" -> full["P13RawInternal"] - nw["P13RawInternal"],
        "P22Internal" -> full["P22Internal"] - nw["P22Internal"],
        "P1LoopRawInternal" -> full["P1LoopRawInternal"] - nw["P1LoopRawInternal"]
    |>
];

Options[AssembleRealSpaceFromRawCache] = {
    "IncludeInterpolatedTerms" -> True,
    "IncludeCounterterm" -> True,
    "IncludeStochastic" -> True
};

AssembleRealSpaceFromRawCache[kgrid_List, rawCache_Association, model_String: "Basis", pars_: <||>, opts : OptionsPattern[]] := Module[
    {
        includeTermsQ,
        includeCtrQ,
        includeStochQ,
        kInternal,
        interpToGrid,
        plinGrid,
        basisInternal,
        basisGrid,
        b1, b2, bG2, bGamma3, cs, cs0, pshot,
        treeInternal, treeGrid, loopInternal, loopGrid, ctrInternal, ctrGrid, stochInternal, stochGrid
    },
    includeTermsQ = TrueQ[OptionValue["IncludeInterpolatedTerms"]];
    includeCtrQ = TrueQ[OptionValue["IncludeCounterterm"]];
    includeStochQ = TrueQ[OptionValue["IncludeStochastic"]];
    kInternal = rawCache["kInternal"];
    interpToGrid = interpolateOntoGrid[kInternal, #, kgrid] &;
    plinGrid = rawCacheLinearOnGrid[rawCache, kgrid];
    basisInternal = <|
        "P_lin" -> rawCache["PlinInternal"],
        "P13UV" -> rawCache["P13UVBaseInternal"],
        "13_dd_raw" -> rawCache["M13BySectorRawInternal"]["13_dd"],
        "13_dd" -> rawCache["M13BySectorRawInternal"]["13_dd"] - rawCache["P13UVBaseInternal"],
        "22_dd" -> rawCache["M22BySectorRawInternal"]["22_dd"],
        "I_d2" -> rawCache["M22BySectorRawInternal"]["I_d2"],
        "I_G2" -> rawCache["M22BySectorRawInternal"]["I_G2"],
        "I_d2_d2" -> rawCache["M22BySectorRawInternal"]["I_d2_d2"],
        "I_d2_G2" -> rawCache["M22BySectorRawInternal"]["I_d2_G2"],
        "I_G2_G2" -> rawCache["M22BySectorRawInternal"]["I_G2_G2"],
        "I_d2_v" -> rawCache["M22BySectorRawInternal"]["I_d2_v"],
        "F_G2" -> rawCache["M13BySectorRawInternal"]["F_G2"]
    |>;
    basisGrid = If[
        includeTermsQ,
        Join[
            interpolateAssociationOntoGrid[kInternal, basisInternal, kgrid],
            If[ListQ[plinGrid], <|"P_lin" -> N @ plinGrid|>, <||>]
        ],
        <||>
    ];
    Which[
        model === "Basis",
            Join[
                <|"k" -> kgrid, "kInternal" -> kInternal, "BasisInternal" -> basisInternal|>,
                If[includeTermsQ, basisGrid, <||>]
            ],
        model === "Matter",
            treeInternal = basisInternal["P_lin"];
            loopInternal = basisInternal["13_dd"] + basisInternal["22_dd"];
            cs = Lookup[pars, "cs", 0.];
            ctrInternal = If[includeCtrQ, -2 cs (kInternal^2) treeInternal, ConstantArray[0., Length[kInternal]]];
            treeGrid = If[ListQ[plinGrid], N @ plinGrid, interpToGrid[treeInternal]];
            loopGrid = interpToGrid[loopInternal];
            ctrGrid = If[includeCtrQ, -2 cs (kgrid^2) treeGrid, ConstantArray[0., Length[kgrid]]];
            Join[
                <|
                    "k" -> kgrid,
                    "kInternal" -> kInternal,
                    "PtreeInternal" -> treeInternal,
                    "P13Internal" -> basisInternal["13_dd"],
                    "P22Internal" -> basisInternal["22_dd"],
                    "P1LoopInternal" -> loopInternal,
                    "PctrInternal" -> ctrInternal,
                    "PtotInternal" -> treeInternal + loopInternal + ctrInternal,
                    "Ptree" -> treeGrid,
                    "P13" -> interpToGrid[basisInternal["13_dd"]],
                    "P22" -> interpToGrid[basisInternal["22_dd"]],
                    "P1Loop" -> loopGrid,
                    "Pctr" -> ctrGrid,
                    "Ptot" -> treeGrid + loopGrid + ctrGrid
                |>,
                If[includeTermsQ, basisGrid, <||>]
            ],
        model === "GG",
            b1 = Lookup[pars, "b1", 1.];
            b2 = Lookup[pars, "b2", 0.];
            bG2 = Lookup[pars, "bG2", 0.];
            bGamma3 = Lookup[pars, "bGamma3", 0.];
            cs = Lookup[pars, "cs", 0.];
            cs0 = Lookup[pars, "cs0", 0.];
            pshot = Lookup[pars, "Pshot", 0.];
            treeInternal = b1^2 basisInternal["P_lin"];
            loopInternal =
                b1^2 (basisInternal["22_dd"] + basisInternal["13_dd"]) +
                b1 b2 basisInternal["I_d2"] +
                2 b1 bG2 basisInternal["I_G2"] +
                (b2^2/4) basisInternal["I_d2_d2"] +
                bG2^2 basisInternal["I_G2_G2"] +
                b2 bG2 basisInternal["I_d2_G2"] +
                (2 b1 bG2 + (4/5) b1 bGamma3) basisInternal["F_G2"];
            ctrInternal = If[
                includeCtrQ,
                -(2 cs b1^2 + 2 cs0 b1) (kInternal^2) basisInternal["P_lin"],
                ConstantArray[0., Length[kInternal]]
            ];
            stochInternal = If[includeStochQ, ConstantArray[pshot, Length[kInternal]], ConstantArray[0., Length[kInternal]]];
            treeGrid = If[ListQ[plinGrid], b1^2 * N @ plinGrid, interpToGrid[treeInternal]];
            loopGrid = interpToGrid[loopInternal];
            ctrGrid = If[
                includeCtrQ,
                -(2 cs b1^2 + 2 cs0 b1) (kgrid^2) If[ListQ[plinGrid], N @ plinGrid, interpToGrid[basisInternal["P_lin"]]],
                ConstantArray[0., Length[kgrid]]
            ];
            stochGrid = If[includeStochQ, ConstantArray[pshot, Length[kgrid]], ConstantArray[0., Length[kgrid]]];
            Join[
                <|
                    "k" -> kgrid,
                    "kInternal" -> kInternal,
                    "Ptree" -> treeGrid,
                    "P1Loop" -> loopGrid,
                    "Pctr" -> ctrGrid,
                    "Pstoch" -> stochGrid,
                    "Ptot" -> treeGrid + loopGrid + ctrGrid + stochGrid
                |>,
                If[includeTermsQ, basisGrid, <||>]
            ],
        model === "GM",
            b1 = Lookup[pars, "b1", 1.];
            b2 = Lookup[pars, "b2", 0.];
            bG2 = Lookup[pars, "bG2", 0.];
            bGamma3 = Lookup[pars, "bGamma3", 0.];
            cs = Lookup[pars, "cs", 0.];
            cs0 = Lookup[pars, "cs0", 0.];
            treeInternal = b1 basisInternal["P_lin"];
            loopInternal =
                b1 (basisInternal["22_dd"] + basisInternal["13_dd"]) +
                (b2/2) basisInternal["I_d2"] +
                bG2 basisInternal["I_G2"] +
                (bG2 + (2/5) bGamma3) basisInternal["F_G2"];
            ctrInternal = If[includeCtrQ, -(cs0 + 2 cs b1) (kInternal^2) basisInternal["P_lin"], ConstantArray[0., Length[kInternal]]];
            treeGrid = If[ListQ[plinGrid], b1 * N @ plinGrid, interpToGrid[treeInternal]];
            loopGrid = interpToGrid[loopInternal];
            ctrGrid = If[includeCtrQ, -(cs0 + 2 cs b1) (kgrid^2) If[ListQ[plinGrid], N @ plinGrid, interpToGrid[basisInternal["P_lin"]]], ConstantArray[0., Length[kgrid]]];
            Join[
                <|
                    "k" -> kgrid,
                    "kInternal" -> kInternal,
                    "Ptree" -> treeGrid,
                    "P1Loop" -> loopGrid,
                    "Pctr" -> ctrGrid,
                    "Ptot" -> treeGrid + loopGrid + ctrGrid
                |>,
                If[includeTermsQ, basisGrid, <||>]
            ],
        True,
            $Failed
    ]
];

pkmu13UVCoefficient[pars_Association, mu_?NumericQ] := Module[
    {f, b1, bG2, bGamma3, z1, z3uv},
    f = Lookup[pars, "f", 0.];
    b1 = Lookup[pars, "b1", 1.];
    bG2 = Lookup[pars, "bG2", 0.];
    bGamma3 = Lookup[pars, "bGamma3", 0.];
    z1 = b1 + f mu^2;
    z3uv = -61./315. * b1 - 64./21. * bG2 - 128./105. * bGamma3;
    z3uv += (-3./5. + 2./105. * b1) * f mu^2;
    z3uv += (-16./35. - 1./3. * b1) * f^2 mu^2;
    z3uv += (-46./105.) * f^2 mu^4;
    z3uv += (-1./3.) * f^3 mu^4;
    z1 * z3uv
];

Options[AssembleOneLoopFromRawSectorCache] = {"IncludeInterpolatedSectorBreakdown" -> False};

AssembleOneLoopFromRawSectorCache[kgrid_List, rawCache_Association, pars_Association, mu_: 0., opts : OptionsPattern[]] := Module[
    {
        includeBreakdownQ,
        kInternal,
        interpToGrid,
        m13RawInternal,
        m22RawInternal,
        m13AssocInternal,
        m22AssocInternal,
        p13RawInternal,
        p22Internal,
        p13UVInternal,
        result
    },
    includeBreakdownQ = TrueQ[OptionValue["IncludeInterpolatedSectorBreakdown"]];
    kInternal = rawCache["kInternal"];
    interpToGrid = interpolateOntoGrid[kInternal, #, kgrid] &;
    m13RawInternal = rawCache["M13BySectorRawInternal"];
    m22RawInternal = rawCache["M22BySectorRawInternal"];
    m13AssocInternal = AssociationMap[
        SectorCoefficient[sectorMetadata[#], pars, mu] * m13RawInternal[#] &,
        Keys[m13RawInternal]
    ];
    m22AssocInternal = AssociationMap[
        SectorCoefficient[sectorMetadata[#], pars, mu] * m22RawInternal[#] &,
        Keys[m22RawInternal]
    ];
    p13RawInternal = Total[Values[m13AssocInternal]];
    p22Internal = Total[Values[m22AssocInternal]];
    p13UVInternal = If[
        KeyExistsQ[rawCache, "P13UVBaseInternal"] && ListQ[rawCache["P13UVBaseInternal"]],
        pkmu13UVCoefficient[pars, mu] * rawCache["P13UVBaseInternal"],
        Switch[
            Lookup[rawCache, "CacheKind", "RawOneLoopSectorCache"],
            "DifferenceRawOneLoopSectorCache",
                BuildPkmu13UV[kInternal, rawCache["PositiveLinAssoc"], pars, mu]["P13UV"] -
                BuildPkmu13UV[kInternal, rawCache["NegativeLinAssoc"], pars, mu]["P13UV"],
            _,
                BuildPkmu13UV[kInternal, rawCache["LinAssoc"], pars, mu]["P13UV"]
        ]
    ];
    result = <|
        "k" -> kgrid,
        "kInternal" -> kInternal,
        "mu" -> mu,
        "RawSectorCache" -> rawCache,
        "CachedM13" -> Lookup[rawCache, "CachedM13", <||>],
        "CachedM22" -> Lookup[rawCache, "CachedM22", <||>],
        "M13BySectorRawInternal" -> m13RawInternal,
        "M22BySectorRawInternal" -> m22RawInternal,
        "M13BySectorInternal" -> m13AssocInternal,
        "M22BySectorInternal" -> m22AssocInternal,
        "P13RawInternal" -> p13RawInternal,
        "P13UVInternal" -> p13UVInternal,
        "P13Internal" -> p13RawInternal + p13UVInternal,
        "P22Internal" -> p22Internal,
        "P1LoopInternal" -> p13RawInternal + p13UVInternal + p22Internal,
        "P13Raw" -> interpToGrid[p13RawInternal],
        "P13UV" -> interpToGrid[p13UVInternal],
        "P13" -> interpToGrid[p13RawInternal + p13UVInternal],
        "P22" -> interpToGrid[p22Internal],
        "P1Loop" -> interpToGrid[p13RawInternal + p13UVInternal + p22Internal]
    |>;
    If[includeBreakdownQ,
        Join[
            result,
            <|
                "M13BySectorRaw" -> interpolateAssociationOntoGrid[kInternal, m13RawInternal, kgrid],
                "M22BySectorRaw" -> interpolateAssociationOntoGrid[kInternal, m22RawInternal, kgrid],
                "M13BySector" -> interpolateAssociationOntoGrid[kInternal, m13AssocInternal, kgrid],
                "M22BySector" -> interpolateAssociationOntoGrid[kInternal, m22AssocInternal, kgrid]
            |>
        ],
        result
    ]
];

BuildPkmu1LoopRaw[kgrid_List, fftAssoc_Association, pars_Association, mu_: 0., plin_: Automatic, opts : OptionsPattern[AssembleOneLoopFromRawSectorCache]] := Module[
    AssembleOneLoopFromRawSectorCache[
        kgrid,
        BuildRawOneLoopSectorCache[fftAssoc, plin],
        pars,
        mu,
        opts
    ]
];

BuildPkmuTree[kgrid_List, linAssoc_Association, pars_Association, mu_: 0.] := Module[
    {z1},
    z1 = Lookup[pars, "b1", 1] + Lookup[pars, "f", 0] mu^2;
    <|"k" -> kgrid, "mu" -> mu, "Ptree" -> z1^2 * (linAssoc["Plin"] /@ kgrid)|>
];

BuildPkmuTreeIRResummed[kgrid_List, linAssoc_Association, splitAssoc_Association, pars_Association, mu_: 0., dampAssoc_Association] := Module[
    {z1, pkNw, pkW, damp, plir},
    z1 = Lookup[pars, "b1", 1] + Lookup[pars, "f", 0] mu^2;
    pkNw = splitAssoc["PnwFunction"] /@ kgrid;
    pkW = splitAssoc["PwFunction"] /@ kgrid;
    damp = Map[dampAssoc["DampingExponent"][#, mu] &, kgrid];
    plir = pkNw + Exp[-damp] * pkW;
    <|
        "k" -> kgrid,
        "mu" -> mu,
        "PLIR" -> plir,
        "PtreeIR" -> z1^2 * (pkNw + Exp[-damp] * pkW * (1 + damp))
    |>
];

resolveSpectrumValues[input_, key_String: "PLIR"] := Which[
    AssociationQ[input] && KeyExistsQ[input, key], input[key],
    AssociationQ[input] && KeyExistsQ[input, "Ptree"], input["Ptree"],
    AssociationQ[input] && KeyExistsQ[input, "PtreeIR"], input["PtreeIR"],
    ListQ[input], input,
    True, input
];

BuildPkmuCounterterms[kgrid_List, mu_: 0., plinValues_, pars_Association] := Module[
    {f, b1, c0, c2, c4, cfog, ctrMu, base},
    f = Lookup[pars, "f", 0.];
    b1 = Lookup[pars, "b1", 1.];
    c0 = Lookup[pars, "c0", Lookup[pars, "cs0", 0.]];
    c2 = Lookup[pars, "c2", Lookup[pars, "cs2", 0.]];
    c4 = Lookup[pars, "c4", Lookup[pars, "cs4", 0.]];
    cfog = Lookup[pars, "cfog", 0.];
    ctrMu = c0 + c2 f mu^2 + c4 f^2 mu^4;
    base = resolveSpectrumValues[plinValues];
    <|
        "k" -> kgrid,
        "mu" -> mu,
        "PctrK2" -> -2 ctrMu kgrid^2 base,
        "PctrK4" -> -cfog f^4 mu^4 (b1 + f mu^2)^2 kgrid^4 base,
        "Pctr" -> (-2 ctrMu kgrid^2 base) - (cfog f^4 mu^4 (b1 + f mu^2)^2 kgrid^4 base)
    |>
];

BuildPkmuStochastic[kgrid_List, mu_: 0., pars_Association] := Module[
    {pshot, legacyPshot, legacyB4, a0, a2, kNl, ndens, kKnL2},
    pshot = Lookup[pars, "P_shot", Missing["Legacy"]];
    a0 = Lookup[pars, "a0", 0.];
    a2 = Lookup[pars, "a2", 0.];
    kNl = Lookup[pars, "k_nl", 1.];
    ndens = Lookup[pars, "ndens", 1.];
    legacyPshot = Lookup[pars, "Pshot", 0.];
    legacyB4 = Lookup[pars, "b4", 0.];
    If[pshot === Missing["Legacy"] && a0 == 0 && a2 == 0 && ndens == 1,
        <|"k" -> kgrid, "mu" -> mu, "Pstoch" -> ConstantArray[legacyPshot + legacyB4 mu^4, Length[kgrid]]|>,
        kKnL2 = (kgrid/kNl)^2;
        <|"k" -> kgrid, "mu" -> mu, "Pstoch" -> (Lookup[pars, "P_shot", 0.] + a0 kKnL2 + a2 kKnL2 mu^2)/ndens|>
    ]
];

AssemblePkmuRaw[treeAssoc_Association, oneLoopAssoc_Association, ctrs_: None, stoch_: None] := Module[
    {k, mu, ctrVals, stochVals},
    k = treeAssoc["k"];
    mu = treeAssoc["mu"];
    ctrVals = If[AssociationQ[ctrs], ctrs[First@Complement[Keys[ctrs], {"k", "mu"}]], ConstantArray[0., Length[k]]];
    stochVals = If[AssociationQ[stoch], stoch[First@Complement[Keys[stoch], {"k", "mu"}]], ConstantArray[0., Length[k]]];
    <|
        "k" -> k,
        "mu" -> mu,
        "Ptree" -> treeAssoc["Ptree"],
        "P13Raw" -> Lookup[oneLoopAssoc, "P13Raw", oneLoopAssoc["P13"]],
        "P13UV" -> Lookup[oneLoopAssoc, "P13UV", ConstantArray[0., Length[k]]],
        "P13" -> oneLoopAssoc["P13"],
        "P22" -> oneLoopAssoc["P22"],
        "P1Loop" -> oneLoopAssoc["P1Loop"],
        "Pctr" -> ctrVals,
        "Pstoch" -> stochVals,
        "Ptot" -> treeAssoc["Ptree"] + oneLoopAssoc["P1Loop"] + ctrVals + stochVals
    |>
];

SubtractOneLoopComponents[full_Association, nw_Association] := Module[
    {m13Key, m22Key, m13RawKey, m22RawKey, m13, m22, m13Raw, m22Raw},
    m13Key = If[KeyExistsQ[full, "M13BySector"], "M13BySector", "M13BySectorInternal"];
    m22Key = If[KeyExistsQ[full, "M22BySector"], "M22BySector", "M22BySectorInternal"];
    m13RawKey = If[KeyExistsQ[full, "M13BySectorRaw"], "M13BySectorRaw", "M13BySectorRawInternal"];
    m22RawKey = If[KeyExistsQ[full, "M22BySectorRaw"], "M22BySectorRaw", "M22BySectorRawInternal"];
    m13 = AssociationMap[full[m13Key][#] - nw[m13Key][#] &, Keys[full[m13Key]]];
    m22 = AssociationMap[full[m22Key][#] - nw[m22Key][#] &, Keys[full[m22Key]]];
    m13Raw = AssociationMap[
        full[m13RawKey][#] - nw[m13RawKey][#] &,
        Keys[full[m13RawKey]]
    ];
    m22Raw = AssociationMap[
        full[m22RawKey][#] - nw[m22RawKey][#] &,
        Keys[full[m22RawKey]]
    ];
    <|
        "k" -> full["k"],
        "mu" -> full["mu"],
        m13RawKey -> m13Raw,
        m22RawKey -> m22Raw,
        m13Key -> m13,
        m22Key -> m22,
        "P13Raw" -> Lookup[full, "P13Raw", full["P13"]] - Lookup[nw, "P13Raw", nw["P13"]],
        "P13UV" -> Lookup[full, "P13UV", ConstantArray[0., Length[full["k"]]]] - Lookup[nw, "P13UV", ConstantArray[0., Length[nw["k"]]]],
        "P13" -> full["P13"] - nw["P13"],
        "P22" -> full["P22"] - nw["P22"],
        "P1Loop" -> full["P1Loop"] - nw["P1Loop"]
    |>
];

AssemblePkmuIRResummed[treeIRAssoc_Association, oneLoopNW_Association, oneLoopW_Association, dampAssoc_Association, ctrs_: None, stoch_: None] := Module[
    {k, mu, damp, ctrVals, stochVals, p1LoopIR},
    k = treeIRAssoc["k"];
    mu = treeIRAssoc["mu"];
    damp = Map[dampAssoc["Damping"][#, mu] &, k];
    ctrVals = If[AssociationQ[ctrs], ctrs[First@Complement[Keys[ctrs], {"k", "mu"}]], ConstantArray[0., Length[k]]];
    stochVals = If[AssociationQ[stoch], stoch[First@Complement[Keys[stoch], {"k", "mu"}]], ConstantArray[0., Length[k]]];
    p1LoopIR = oneLoopNW["P1Loop"] + damp * oneLoopW["P1Loop"];
    <|
        "k" -> k,
        "mu" -> mu,
        "PtreeIR" -> treeIRAssoc["PtreeIR"],
        "P1LoopNW" -> oneLoopNW["P1Loop"],
        "P1LoopW" -> oneLoopW["P1Loop"],
        "P1LoopIR" -> p1LoopIR,
        "Pctr" -> ctrVals,
        "Pstoch" -> stochVals,
        "Ptot" -> treeIRAssoc["PtreeIR"] + p1LoopIR + ctrVals + stochVals
    |>
];

SummarizeOneLoopComponents[assoc_Association] := <|
    "mu" -> assoc["mu"],
    "P13Range" -> {Min[assoc["P13"]], Max[assoc["P13"]]},
    "P22Range" -> {Min[assoc["P22"]], Max[assoc["P22"]]},
    "P1LoopRange" -> {Min[assoc["P1Loop"]], Max[assoc["P1Loop"]]}
|>;

BuildOneLoopComponents[kgrid_List, fftAssoc_Association, pars_Association, mu_: 0., plin_: Automatic] := Module[
    {tree, oneLoop, plinFunc},
    plinFunc = Replace[plin, Automatic :> fftAssoc["PlinFunction"]];
    tree = BuildPkmuTree[kgrid, <|"Plin" -> Replace[plin, Automatic :> fftAssoc["PlinFunction"]]|>, pars, mu];
    oneLoop = BuildPkmu1LoopRaw[kgrid, fftAssoc, pars, mu, plin, "IncludeInterpolatedSectorBreakdown" -> True];
    <|
        "k" -> kgrid,
        "mu" -> mu,
        "Tree" -> tree["Ptree"],
        "M13BySectorRaw" -> oneLoop["M13BySectorRaw"],
        "M22BySectorRaw" -> oneLoop["M22BySectorRaw"],
        "M13BySector" -> oneLoop["M13BySector"],
        "M22BySector" -> oneLoop["M22BySector"],
        "P13Raw" -> oneLoop["P13Raw"],
        "P13UV" -> oneLoop["P13UV"],
        "P13" -> oneLoop["P13"],
        "P22" -> oneLoop["P22"],
        "P1Loop" -> oneLoop["P1Loop"],
        "P13Total" -> oneLoop["P13"],
        "P22Total" -> oneLoop["P22"],
        "OneLoopTotal" -> tree["Ptree"] + oneLoop["P1Loop"],
        "PlinFunction" -> plinFunc
    |>
];

safeLinePlot[data_, legends_, ylab_, title_] := ListLinePlot[
    data,
    Frame -> True,
    PlotRange -> All,
    PlotLegends -> legends,
    FrameLabel -> {"k", ylab},
    PlotLabel -> title,
    ImageSize -> Large
];

lookupFirstPresent[assoc_Association, keys_List] := Module[{present},
    present = SelectFirst[keys, KeyExistsQ[assoc, #] &, Missing["KeyAbsent", keys]];
    If[MissingQ[present], Missing["KeyAbsent", keys], assoc[present]]
];

sectorPlot[k_List, sectorAssoc_Association, title_] := Module[{keys, data},
    keys = Keys[sectorAssoc];
    data = Transpose[{k, #}] & /@ Values[sectorAssoc];
    ListLogLogPlot[
        data,
        Frame -> True,
        PlotRange -> All,
        PlotLegends -> keys,
        FrameLabel -> {"k", "P(k)"},
        PlotLabel -> title,
        Joined -> True,
        ImageSize -> Large
    ]
];

BuildOneLoopComparisonPlots[assoc_Association] := Module[
    {k, treeVals, p13Vals, p22Vals, p1LoopVals},
    k = assoc["k"];
    treeVals = lookupFirstPresent[assoc, {"Tree", "Ptree"}];
    p13Vals = lookupFirstPresent[assoc, {"P13", "P13Total"}];
    p22Vals = lookupFirstPresent[assoc, {"P22", "P22Total"}];
    p1LoopVals = lookupFirstPresent[assoc, {"P1Loop", "OneLoopTotal"}];
    <|
        "P13Sectors" -> sectorPlot[k, assoc["M13BySector"], "M13 sector contributions"],
        "P22Sectors" -> sectorPlot[k, assoc["M22BySector"], "M22 sector contributions"],
        "NoIRSummary" -> ListLogLogPlot[
            DeleteMissing[
                {
                    If[ListQ[treeVals], Transpose[{k, treeVals}], Missing["NotAvailable"]],
                    If[ListQ[p13Vals], Transpose[{k, p13Vals}], Missing["NotAvailable"]],
                    If[ListQ[p22Vals], Transpose[{k, p22Vals}], Missing["NotAvailable"]],
                    If[ListQ[p1LoopVals], Transpose[{k, p1LoopVals}], Missing["NotAvailable"]]
                }
            ],
            Frame -> True,
            PlotRange -> All,
            PlotLegends -> DeleteMissing[
                {
                    If[ListQ[treeVals], "Tree", Missing["NotAvailable"]],
                    If[ListQ[p13Vals], "P13", Missing["NotAvailable"]],
                    If[ListQ[p22Vals], "P22", Missing["NotAvailable"]],
                    If[ListQ[p1LoopVals], "P1Loop", Missing["NotAvailable"]]
                }
            ],
            FrameLabel -> {"k", "P(k)"},
            PlotLabel -> "One-loop summary",
            Joined -> True,
            ImageSize -> Large
        ]
    |>
];

BuildOneLoopComparisonPlots[full_Association, nw_Association, wiggle_: None] := Module[
    {k, rawPlot, nwPlot, wigglePlot},
    k = full["k"];
    rawPlot = ListLogLogPlot[
        {
            Transpose[{k, full["P13"]}],
            Transpose[{k, full["P22"]}],
            Transpose[{k, full["P1Loop"]}]
        },
        Frame -> True,
        PlotRange -> All,
        PlotLegends -> {"P13(full)", "P22(full)", "P1loop(full)"},
        FrameLabel -> {"k", "P(k)"},
        PlotLabel -> "Raw one-loop pieces from the full linear spectrum",
        Joined -> True,
        ImageSize -> Large
    ];
    nwPlot = ListLogLogPlot[
        {
            Transpose[{k, nw["P13"]}],
            Transpose[{k, nw["P22"]}],
            Transpose[{k, nw["P1Loop"]}]
        },
        Frame -> True,
        PlotRange -> All,
        PlotLegends -> {"P13(nw)", "P22(nw)", "P1loop(nw)"},
        FrameLabel -> {"k", "P(k)"},
        PlotLabel -> "Raw one-loop pieces from the no-wiggle linear spectrum",
        Joined -> True,
        ImageSize -> Large
    ];
    wigglePlot = If[
        AssociationQ[wiggle],
        ListLogLogPlot[
            {
                Transpose[{k, wiggle["P13"]}],
                Transpose[{k, wiggle["P22"]}],
                Transpose[{k, wiggle["P1Loop"]}]
            },
            Frame -> True,
            PlotRange -> All,
            PlotLegends -> {"P13(w)", "P22(w)", "P1loop(w)"},
            FrameLabel -> {"k", "P(k)"},
            PlotLabel -> "Wiggly one-loop piece defined by subtraction",
            Joined -> True,
            ImageSize -> Large
        ],
        Missing["NoWigglyAssociation"]
    ];
    <|"FullRaw" -> rawPlot, "NoWiggleRaw" -> nwPlot, "WigglyRaw" -> wigglePlot|>
];

BuildBenchmarkPlots[kgrid_List, lin_Association, split_Association, full_Association, nw_Association, wiggle_Association, treeIRAssoc_Association, pkRaw_Association, pkIR_Association, mu_: 0., dampAssoc_: None] := Module[
    {linearPlot, pwPlot, totalPlot},
    linearPlot = ListLogLogPlot[
        {
            Transpose[{lin["k"], lin["Data"][[All, 2]]/split["PnwData"][[All, 2]]}],
            Transpose[{kgrid, treeIRAssoc["PtreeIR"]}]
        },
        Frame -> True,
        PlotRange -> All,
        PlotLegends -> {"P_lin/P_nw", "Ptree,IR"},
        FrameLabel -> {"k", "P(k)/P_nw(k)"},
        PlotLabel -> "Linear and no-wiggle spectra",
        ImageSize -> Large
    ];
    pwPlot = ListLinePlot[
        {Transpose[{lin["k"], split["PwData"][[All, 2]]}]},
        Frame -> True,
        PlotRange -> All,
        PlotLegends -> {"P_w"},
        FrameLabel -> {"k", "P_w(k)"},
        PlotLabel -> "Wiggle residual",
        ScalingFunctions -> {"Log", None},
        ImageSize -> Large
    ];
    totalPlot = safeLinePlot[
        {
            Transpose[{kgrid, pkRaw["Ptot"]}],
            Transpose[{kgrid, pkIR["Ptot"]}]
        },
        {"Raw total", "IR-resummed total"},
        "P(k,mu)",
        "Raw versus IR-resummed total spectrum"
    ];
    <|"Linear" -> linearPlot, "WiggleResidual" -> pwPlot, "Summary" -> totalPlot|>
];

gaussLegendreRule[n_Integer?Positive, workingPrecision_: 50] := Module[
    {x, roots, weights},
    roots = x /. NSolve[
        LegendreP[n, x] == 0,
        x,
        WorkingPrecision -> workingPrecision
    ];
    roots = Sort[N[roots, workingPrecision]];
    weights = N[
        2/((1 - roots^2) * (D[LegendreP[n, x], x] /. x -> roots)^2),
        workingPrecision
    ];
    {roots, weights}
];

muGridWeights[muSamples_Integer: 32] := Module[{nodes, weightsRaw},
    (* Use Gaussian-Legendre quadrature on [0,1] via change of variables from [-1,1]. *)
    {nodes, weightsRaw} = gaussLegendreRule[muSamples, 50];
    {(nodes + 1)/2, weightsRaw/2}
];

ProjectPkmuToMultipoles[kgrid_List, pkmuGrid_Association, muSamples_Integer: 32] /; KeyExistsQ[pkmuGrid, "muGrid"] && KeyExistsQ[pkmuGrid, "PtotGrid"] := Module[
    {mus, weights, spectrumAtMu, spectrumByK, legendreMatrix},
    mus = pkmuGrid["muGrid"];
    weights = pkmuGrid["Weights"];
    spectrumAtMu = N @ pkmuGrid["PtotGrid"];
    spectrumByK = If[
        Dimensions[spectrumAtMu] === {Length[mus], Length[kgrid]},
        Transpose[spectrumAtMu],
        spectrumAtMu
    ];
    legendreMatrix = Table[LegendreP[ell, mus], {ell, {0, 2, 4}}];
    <|
        "k" -> kgrid,
        "P0" -> spectrumByK . (weights * legendreMatrix[[1]]),
        "P2" -> 5 * (spectrumByK . (weights * legendreMatrix[[2]])),
        "P4" -> 9 * (spectrumByK . (weights * legendreMatrix[[3]]))
    |>
];

pkmuCallableQ[pkmuBuilder_] := Quiet @ Check[
    Module[{sample = pkmuBuilder[0.]},
        AssociationQ[sample] && KeyExistsQ[sample, "Ptot"]
    ],
    False
];

ProjectPkmuToMultipoles[kgrid_List, pkmuBuilder_?pkmuCallableQ, muSamples_Integer: 32] := Module[
    {mus, weights, grid, mapFn},
    {mus, weights} = muGridWeights[muSamples];
    (* Parallel or sequential evaluation at all mu values *)
    mapFn = If[$UseParallelForMultipole && Length[Kernels[]] > 0,
        ParallelMap[#, #2, Method -> "FinestGrained"] &,
        Map
    ];
    grid = mapFn[pkmuBuilder, mus];
    ProjectPkmuToMultipoles[
        kgrid,
        <|"muGrid" -> mus, "Weights" -> weights, "PtotGrid" -> (Lookup[grid, "Ptot"])|>,
        muSamples
    ]
];

BuildMultipoleTablesFromPkmu[kgrid_List, pkmuFnOrGrid_, muSamples_Integer: 9] := ProjectPkmuToMultipoles[kgrid, pkmuFnOrGrid, muSamples];

BuildMultipoleTables[kgrid_List, fftAssoc_Association, pars_Association, plin_: Automatic, muSamples_Integer: 32] := Module[
    {mus, weights, componentList, spectrumAtMu, spectrumByK, legendreMatrix, mapFn},
    {mus, weights} = muGridWeights[muSamples];
    (* Parallel or sequential evaluation at all mu values *)
    mapFn = If[$UseParallelForMultipole && Length[Kernels[]] > 0,
        ParallelMap[#, #2, Method -> "FinestGrained"] &,
        Map
    ];
    componentList = mapFn[BuildOneLoopComponents[kgrid, fftAssoc, pars, #, plin] &, mus];
    spectrumAtMu = N @ Lookup[componentList, "OneLoopTotal"];
    spectrumByK = If[
        Dimensions[spectrumAtMu] === {Length[mus], Length[kgrid]},
        Transpose[spectrumAtMu],
        spectrumAtMu
    ];
    legendreMatrix = Table[LegendreP[ell, mus], {ell, {0, 2, 4}}];
    <|
        "k" -> kgrid,
        "P0" -> spectrumByK . (weights * legendreMatrix[[1]]),
        "P2" -> 5 * (spectrumByK . (weights * legendreMatrix[[2]])),
        "P4" -> 9 * (spectrumByK . (weights * legendreMatrix[[3]]))
    |>
];

stripKernelSymbolContexts[text_String] := StringReplace[
    text,
    {
        RegularExpression["(?:[A-Za-z$][A-Za-z0-9$]*`)+nu1"] -> "nu1",
        RegularExpression["(?:[A-Za-z$][A-Za-z0-9$]*`)+nu2"] -> "nu2"
    }
];

KernelString[text_String] := stripKernelSymbolContexts @ StringReplace[text, {"\n" -> "", "\r" -> ""}];
KernelString[expr_] := stripKernelSymbolContexts @ StringReplace[ToString[Unevaluated[expr], InputForm, PageWidth -> Infinity], {"\n" -> "", "\r" -> ""}];

ExportKernelText[path_String, expr_] := Module[{stream, text},
    text = KernelString[expr];
    If[!DirectoryQ[DirectoryName[path]], CreateDirectory[DirectoryName[path], CreateIntermediateDirectories -> True]];
    stream = OpenWrite[path, BinaryFormat -> True, CharacterEncoding -> "UTF-8"];
    WriteString[stream, text];
    Close[stream];
    path
];

roundTripKernel[path_String] := ReleaseHold @ ToExpression[Import[path, "Text"], InputForm, HoldComplete];

ValidateKernelText[path_String, expr_] := Module[{serialized, parsed},
    serialized = Quiet @ Check[Import[path, "Text"], $Failed];
    parsed = Quiet @ Check[roundTripKernel[path], $Failed];
    If[serialized === $Failed || parsed === $Failed, False, serialized === KernelString[expr] && TrueQ[FullSimplify[parsed == expr]]]
];

sampleRuleAssociations[{"nu1"}] := {<|"nu1" -> 1/7|>, <|"nu1" -> 2/11|>, <|"nu1" -> 3/17|>};
sampleRuleAssociations[{"nu1", "nu2"}] := {<|"nu1" -> 1/7, "nu2" -> 2/11|>, <|"nu1" -> 1/9, "nu2" -> 1/13|>, <|"nu1" -> 2/15, "nu2" -> 3/19|>};

namedRules[ex_, assoc_Association] := DeleteDuplicates @ Cases[
    Hold[ex],
    s_Symbol /; KeyExistsQ[assoc, SymbolName[Unevaluated[s]]] :> (s -> assoc[SymbolName[Unevaluated[s]]]),
    Infinity
];

ValidateAgainstReference[path_String, expr_, vars_List] := Module[
    {referenceText, referenceExpr, samples, comparisons, names},
    referenceText = Quiet @ Check[Import[path, "Text"], $Failed];
    referenceExpr = Quiet @ Check[roundTripKernel[path], $Failed];
    If[referenceText === $Failed || referenceExpr === $Failed,
        False,
        If[KernelString[expr] === referenceText || zeroKernelDifferenceQ[expr - referenceExpr] || TrueQ[FullSimplify[expr == referenceExpr]],
            True,
            names = SymbolName /@ vars;
            samples = sampleRuleAssociations[names];
            comparisons = Table[
                Quiet @ Check[
                    Abs[N[expr /. namedRules[expr, rules], 50] - N[referenceExpr /. namedRules[referenceExpr, rules], 50]] < 10^-20,
                    False
                ],
                {rules, samples}
            ];
            And @@ comparisons
        ]
    ]
];

ExportAllM13Kernels[dir_: Automatic] := Module[{resolved = ResolveOutputDir[dir], kernels},
    kernels = BuildAllM13Kernels[];
    Association @ KeyValueMap[Function[{file, expr}, file -> ExportKernelText[FileNameJoin[{resolved, file}], expr]], kernels]
];

ExportAllM22Kernels[dir_: Automatic] := Module[{resolved = ResolveOutputDir[dir], kernels},
    kernels = BuildAllM22Kernels[];
    Association @ KeyValueMap[Function[{file, expr}, file -> ExportKernelText[FileNameJoin[{resolved, file}], expr]], kernels]
];

referenceVars["M13"] := {nu1};
referenceVars["M22"] := {nu1, nu2};
kernelBuilder["M13"] := BuildAllM13Kernels;
kernelBuilder["M22"] := BuildAllM22Kernels;

ValidateExportedKernels[kind_String, dir_: Automatic] := Module[
    {resolved = ResolveOutputDir[dir], kernels, vars},
    If[!TrueQ[$EFTwithFFTEnableValidation], Return[<|"Validation" -> "Disabled"|>]];
    kernels = kernelBuilder[kind][];
    vars = referenceVars[kind];
    Association @ KeyValueMap[
        Function[{file, expr},
            file -> <|
                "SerializedText" -> ValidateKernelText[FileNameJoin[{resolved, file}], expr],
                "ReferenceNumeric" -> ValidateAgainstReference[kernelReferencePath[file], expr, vars]
            |>
        ],
        kernels
    ]
];

runPythonJSON[code_String, args_List] := Module[{raw},
    raw = Quiet @ Check[RunProcess[Join[{ps1LoopPythonExecutable[], "-c", code}, args], "StandardOutput"], $Failed];
    If[!StringQ[raw] || StringTrim[raw] === "", Return[$Failed]];
    Quiet @ Check[ImportString[raw, "RawJSON"], $Failed]
];

pythonCommandWorksQ[cmd_String, code_String] := Quiet @ Check[
    StringTrim @ RunProcess[{cmd, "-c", code}, "StandardOutput"] === "OK",
    False
];

ps1LoopPythonExecutable[] := Module[
    {
        candidates = {
            "/Users/nguyenmn/miniconda3/envs/evs-hmf_osx-64_py310forge/bin/python",
            "python3",
            "python"
        },
        importCode
    },
    If[ValueQ[$Ps1LoopPythonExecutable] && StringQ[$Ps1LoopPythonExecutable],
        Return[$Ps1LoopPythonExecutable]
    ];
    importCode = StringRiffle[{
        "import sys",
        "sys.path.insert(0, '/Users/nguyenmn/ps_1loop_jax-for-pfs/src')",
        "import ps_1loop_jax",
        "print('OK')"
    }, "\n"];
    $Ps1LoopPythonExecutable = SelectFirst[candidates, pythonCommandWorksQ[#, importCode] &, "python3"];
    $Ps1LoopPythonExecutable
];

ensureAssociation[assoc_Association] := assoc;
ensureAssociation[rules_List] := Association @ rules;
ensureAssociation[other_] := Association @ other;

toNumericAssociation[input_] := Module[{assoc},
    assoc = ensureAssociation[input];
    Association @ KeyValueMap[Function[{k, v}, k -> (N @ v)], assoc]
];

nearestGridLocation[kgrid_List, kTarget_?NumericQ] := Module[{idx},
    idx = First @ Ordering[Abs[N @ kgrid - N @ kTarget], 1];
    <|"Index" -> idx, "KUsed" -> N @ kgrid[[idx]], "KTarget" -> N @ kTarget|>
];

arrayComparisonStats[computed_, reference_] := Module[
    {c, r, absErr, relErr, idx, safeDenom},
    c = Flatten @ N @ computed;
    r = Flatten @ N @ reference;
    If[Length[c] =!= Length[r],
        Return[<|"SameShape" -> False, "ComputedLength" -> Length[c], "ReferenceLength" -> Length[r]|>]
    ];
    absErr = Abs[c - r];
    safeDenom = Map[Max[Abs[#], 10^-30] &, r];
    relErr = absErr/safeDenom;
    idx = First @ Ordering[relErr, -1];
    <|
        "SameShape" -> True,
        "MaxAbsError" -> Max[absErr],
        "MaxRelError" -> Max[relErr],
        "WorstFlatIndex" -> idx,
        "ComputedAtWorstRel" -> c[[idx]],
        "ReferenceAtWorstRel" -> r[[idx]]
    |>
];

sectorComparisonStats[k_List, computed_List, reference_List] := Module[
    {computedVals, referenceVals, absErr, relErr, absIdx, relIdx, safeDenom},
    computedVals = N @ computed;
    referenceVals = N @ reference;
    absErr = Abs[computedVals - referenceVals];
    safeDenom = Map[Max[Abs[#], 10^-30] &, referenceVals];
    relErr = absErr/safeDenom;
    absIdx = First @ Ordering[absErr, -1];
    relIdx = First @ Ordering[relErr, -1];
    <|
        "MaxAbsError" -> absErr[[absIdx]],
        "MaxRelError" -> relErr[[relIdx]],
        "WorstAbsK" -> k[[absIdx]],
        "WorstRelK" -> k[[relIdx]],
        "ComputedAtWorstRel" -> computedVals[[relIdx]],
        "ReferenceAtWorstRel" -> referenceVals[[relIdx]]
    |>
];

compareSectorAssociations[k_List, computed_Association, reference_Association] := Association @ KeyValueMap[
    Function[{name, values},
        name -> If[
            KeyExistsQ[reference, name],
            sectorComparisonStats[k, values, reference[name]],
            <|"MissingReference" -> True|>
        ]
    ],
    computed
];

worstSectorEntry[stats_Association, key_String: "MaxRelError"] := Module[
    {eligible},
    eligible = Select[Normal @ stats, NumericQ[Lookup[Last[#], key, Missing["NotNumeric"]]] &];
    If[eligible === {},
        Missing["NoEligibleSector"],
        With[{entry = First @ MaximalBy[eligible, Lookup[Last[#], key, -Infinity] &]},
            <|"Sector" -> First[entry], "Stats" -> Last[entry]|>
        ]
    ]
];

stripTxtExtension[file_String] := StringReplace[file, ".txt" -> ""];

GetM13ContractionIngredients[fftAssoc_Association, sectorFile_String, kTarget_?NumericQ, plin_: Automatic] := Module[
    {plinFunc, kInternal, loc, kUsed, nus, coeffs, kernelVec, pkValue, coeffVector, integrandVector, coreSum},
    plinFunc = Replace[plin, Automatic :> fftAssoc["PlinFunction"]];
    kInternal = Lookup[fftAssoc, "kSample", {}];
    loc = nearestGridLocation[kInternal, kTarget];
    kUsed = loc["KUsed"];
    nus = fftAssoc["nu"];
    coeffs = fftAssoc["Coefficients"];
    kernelVec = BuildCachedM13SectorMatrices[fftAssoc][sectorFile];
    pkValue = N @ plinFunc[kUsed];
    coeffVector = coeffs * kUsed^(-2 nus);
    integrandVector = coeffVector * kernelVec;
    coreSum = Total[integrandVector];
    <|
        "Sector" -> sectorFile,
        "Kind" -> "M13",
        "Index" -> loc["Index"],
        "KTarget" -> loc["KTarget"],
        "KUsed" -> kUsed,
        "NuGrid" -> N @ nus,
        "PkValue" -> pkValue,
        "CoefficientVector" -> N @ coeffVector,
        "KernelVector" -> N @ kernelVec,
        "IntegrandVector" -> N @ integrandVector,
        "CoreSum" -> Re @ Chop[N[coreSum, 30], 10^-20],
        "Total" -> Re @ Chop[N[kUsed^3 * pkValue * coreSum, 30], 10^-20]
    |>
];

GetM22ContractionIngredients[fftAssoc_Association, sectorFile_String, kTarget_?NumericQ] := Module[
    {
        kInternal, loc, kUsed, nus, coeffs, coeffsK0, kernelMat, coeffVector, coeffOuter,
        loopIntegrand, k0Outer, k0Integrand, loopCore, k0Core, kernelTranspose,
        loopIntegrandTranspose, k0IntegrandTranspose, loopCoreTranspose, k0CoreTranspose
    },
    kInternal = Lookup[fftAssoc, "kSample", {}];
    loc = nearestGridLocation[kInternal, kTarget];
    kUsed = loc["KUsed"];
    nus = fftAssoc["nu"];
    coeffs = fftAssoc["Coefficients"];
    coeffsK0 = Lookup[fftAssoc, "CoefficientsK0", ConstantArray[0, Length[coeffs]]];
    kernelMat = BuildCachedM22SectorMatrices[fftAssoc][sectorFile];
    coeffVector = coeffs * kUsed^(-2 nus);
    coeffOuter = Outer[Times, coeffVector, coeffVector];
    loopIntegrand = coeffOuter * kernelMat;
    k0Outer = Outer[Times, coeffsK0, coeffsK0];
    k0Integrand = k0Outer * kernelMat;
    loopCore = Total[loopIntegrand, 2];
    k0Core = Total[k0Integrand, 2];
    kernelTranspose = Transpose[kernelMat];
    loopIntegrandTranspose = coeffOuter * kernelTranspose;
    k0IntegrandTranspose = k0Outer * kernelTranspose;
    loopCoreTranspose = Total[loopIntegrandTranspose, 2];
    k0CoreTranspose = Total[k0IntegrandTranspose, 2];
    <|
        "Sector" -> sectorFile,
        "Kind" -> "M22",
        "Index" -> loc["Index"],
        "KTarget" -> loc["KTarget"],
        "KUsed" -> kUsed,
        "NuGrid" -> N @ nus,
        "CoefficientVector" -> N @ coeffVector,
        "CoefficientOuter" -> N @ coeffOuter,
        "KernelMatrix" -> N @ kernelMat,
        "LoopIntegrandMatrix" -> N @ loopIntegrand,
        "LoopCore" -> Re @ Chop[N[loopCore, 30], 10^-20],
        "LoopTerm" -> Re @ Chop[N[kUsed^3 * loopCore, 30], 10^-20],
        "K0CoefficientVector" -> N @ coeffsK0,
        "K0CoefficientOuter" -> N @ k0Outer,
        "K0IntegrandMatrix" -> N @ k0Integrand,
        "K0Core" -> Re @ Chop[N[k0Core, 30], 10^-20],
        "K0Term" -> Re @ Chop[N[Lookup[fftAssoc, "kMin", kUsed]^3 * k0Core, 30], 10^-20],
        "Total" -> Re @ Chop[N[kUsed^3 * loopCore - Lookup[fftAssoc, "kMin", kUsed]^3 * k0Core, 30], 10^-20],
        "KernelMatrixTransposeTrial" -> N @ kernelTranspose,
        "LoopIntegrandMatrixTransposeTrial" -> N @ loopIntegrandTranspose,
        "LoopCoreTransposeTrial" -> Re @ Chop[N[loopCoreTranspose, 30], 10^-20],
        "LoopTermTransposeTrial" -> Re @ Chop[N[kUsed^3 * loopCoreTranspose, 30], 10^-20],
        "K0IntegrandMatrixTransposeTrial" -> N @ k0IntegrandTranspose,
        "K0CoreTransposeTrial" -> Re @ Chop[N[k0CoreTranspose, 30], 10^-20],
        "K0TermTransposeTrial" -> Re @ Chop[N[Lookup[fftAssoc, "kMin", kUsed]^3 * k0CoreTranspose, 30], 10^-20],
        "TotalTransposeTrial" -> Re @ Chop[N[kUsed^3 * loopCoreTranspose - Lookup[fftAssoc, "kMin", kUsed]^3 * k0CoreTranspose, 30], 10^-20]
    |>
];

GetPs1LoopContractionReference[fftAssoc_Association, linearPath_String] := Module[
    {code, parsed, kInternal},
    kInternal = Lookup[fftAssoc, "kSample", {}];
    code = StringRiffle[{
        "import json, sys, numpy as np",
        "sys.path.insert(0, '/Users/nguyenmn/ps_1loop_jax-for-pfs/src')",
        "from ps_1loop_jax import PowerSpectrum1Loop",
        "from ps_1loop_jax.utils_loop import get_pk",
        "data = np.loadtxt(sys.argv[1])",
        "pk_data = {'k': data[:, 0], 'pk': data[:, 1]}",
        "kmin = float(sys.argv[2])",
        "kmax = float(sys.argv[3])",
        "nfft = int(float(sys.argv[4]))",
        "ps = PowerSpectrum1Loop(kmin_fft=kmin, kmax_fft=kmax, nfft=nfft)",
        "pk_lin = np.asarray(get_pk(ps._kn, pk_data, kmin=ps._kmin, kmax=ps._kmax), dtype=float)",
        "p_q, p_k, p_k0 = ps.decomp['pk_lin nu=-0.7'].get_decomposed_data(pk_lin)",
        "p_q = np.asarray(p_q)",
        "p_k = np.asarray(p_k)",
        "p_k0 = np.asarray(p_k0)",
        "payload = {'kInternal': np.asarray(ps._kn, dtype=float).tolist(), 'M13': {}, 'M22': {}, 'M22Loop': {}, 'M22K0': {}}",
        "for name in ps.name_pkmu_terms['13']:",
        "    arr = np.asarray(ps._kn**3 * p_k * np.dot(ps.matrix[name], p_q).real, dtype=float)",
        "    payload['M13'][name + '.txt'] = arr.tolist()",
        "for name in ps.name_pkmu_terms['22']:",
        "    loop = np.asarray(ps._kn**3 * np.diag(np.dot(p_q.T, np.dot(ps.matrix[name], p_q)).real), dtype=float)",
        "    k0 = np.asarray(np.full(loop.shape, ps._kmin**3 * np.dot(p_k0, np.dot(ps.matrix[name], p_k0)).real), dtype=float)",
        "    payload['M22Loop'][name + '.txt'] = loop.tolist()",
        "    payload['M22K0'][name + '.txt'] = k0.tolist()",
        "    payload['M22'][name + '.txt'] = (loop - k0).tolist()",
        "print(json.dumps(payload))"
    }, "\n"];
    parsed = runPythonJSON[
        code,
        {
            linearPath,
            ToString @ N @ Lookup[fftAssoc, "kMin", Min[kInternal]],
            ToString @ N @ Lookup[fftAssoc, "kMax", Max[kInternal]],
            ToString @ Lookup[fftAssoc, "N", Length[kInternal]]
        }
    ];
    If[!AssociationQ[parsed],
        <|"kInternal" -> {}, "M13" -> <||>, "M22" -> <||>, "M22Loop" -> <||>, "M22K0" -> <||>|>,
        <|
            "kInternal" -> (N @ parsed["kInternal"]),
            "M13" -> toNumericAssociation[parsed["M13"]],
            "M22" -> toNumericAssociation[parsed["M22"]],
            "M22Loop" -> toNumericAssociation[parsed["M22Loop"]],
            "M22K0" -> toNumericAssociation[parsed["M22K0"]]
        |>
    ]
];

GetPs1LoopContractionReference[fftAssoc_Association, linAssoc_Association] := Module[{path},
    path = Lookup[linAssoc, "Path", Missing["NoPath"]];
    If[MissingQ[path] || !FileExistsQ[path], Return[<|"kInternal" -> {}, "M13" -> <||>, "M22" -> <||>, "M22Loop" -> <||>, "M22K0" -> <||>|>]];
    GetPs1LoopContractionReference[fftAssoc, path]
];

GetPs1LoopM13ContractionIngredients[fftAssoc_Association, linearPath_String, sectorFile_String, kTarget_?NumericQ] := Module[
    {code, parsed, kInternal},
    kInternal = Lookup[fftAssoc, "kSample", {}];
    code = StringRiffle[{
        "import json, sys, numpy as np",
        "sys.path.insert(0, '/Users/nguyenmn/ps_1loop_jax-for-pfs/src')",
        "from ps_1loop_jax import PowerSpectrum1Loop",
        "from ps_1loop_jax.utils_loop import get_pk",
        "data = np.loadtxt(sys.argv[1])",
        "pk_data = {'k': data[:, 0], 'pk': data[:, 1]}",
        "name = sys.argv[2]",
        "kmin = float(sys.argv[3])",
        "kmax = float(sys.argv[4])",
        "nfft = int(float(sys.argv[5]))",
        "ktarget = float(sys.argv[6])",
        "ps = PowerSpectrum1Loop(kmin_fft=kmin, kmax_fft=kmax, nfft=nfft)",
        "pk_lin = np.asarray(get_pk(ps._kn, pk_data, kmin=ps._kmin, kmax=ps._kmax), dtype=float)",
        "p_q, p_k, p_k0 = ps.decomp['pk_lin nu=-0.7'].get_decomposed_data(pk_lin)",
        "p_q = np.asarray(p_q)",
        "p_k = np.asarray(p_k)",
        "idx = int(np.argmin(np.abs(np.asarray(ps._kn, dtype=float) - ktarget)))",
        "name = name[:-4] if name.endswith('.txt') else name",
        "kernel = np.asarray(ps.matrix[name], dtype=np.complex128)",
        "coeff = np.asarray(p_q[:, idx], dtype=np.complex128)",
        "integrand = kernel * coeff",
        "payload = {",
        "  'Sector': name + '.txt',",
        "  'Kind': 'M13',",
        "  'Index': idx + 1,",
        "  'KTarget': ktarget,",
        "  'KUsed': float(np.asarray(ps._kn, dtype=float)[idx]),",
        "  'NuGrid': np.asarray(-0.5 * ps.decomp['pk_lin nu=-0.7'].nu_m, dtype=np.complex128).tolist(),",
        "  'PkValue': float(np.asarray(p_k, dtype=float)[idx]),",
        "  'CoefficientVector': coeff.tolist(),",
        "  'KernelVector': kernel.tolist(),",
        "  'IntegrandVector': integrand.tolist(),",
        "  'CoreSum': complex(np.sum(integrand)),",
        "  'Total': float((ps._kn[idx]**3 * p_k[idx] * np.sum(integrand).real))",
        "}",
        "print(json.dumps(payload, default=lambda x: [x.real, x.imag] if isinstance(x, complex) else x))"
    }, "\n"];
    parsed = runPythonJSON[
        code,
        {
            linearPath,
            stripTxtExtension[sectorFile],
            ToString @ N @ Lookup[fftAssoc, "kMin", Min[kInternal]],
            ToString @ N @ Lookup[fftAssoc, "kMax", Max[kInternal]],
            ToString @ Lookup[fftAssoc, "N", Length[kInternal]],
            ToString @ N @ kTarget
        }
    ];
    ensureAssociation[parsed]
];

GetPs1LoopM13ContractionIngredients[fftAssoc_Association, linAssoc_Association, sectorFile_String, kTarget_?NumericQ] := Module[{path},
    path = Lookup[linAssoc, "Path", Missing["NoPath"]];
    If[MissingQ[path] || !FileExistsQ[path], Return[<||>]];
    GetPs1LoopM13ContractionIngredients[fftAssoc, path, sectorFile, kTarget]
];

GetPs1LoopM22ContractionIngredients[fftAssoc_Association, linearPath_String, sectorFile_String, kTarget_?NumericQ] := Module[
    {code, parsed, kInternal},
    kInternal = Lookup[fftAssoc, "kSample", {}];
    code = StringRiffle[{
        "import json, sys, numpy as np",
        "sys.path.insert(0, '/Users/nguyenmn/ps_1loop_jax-for-pfs/src')",
        "from ps_1loop_jax import PowerSpectrum1Loop",
        "from ps_1loop_jax.utils_loop import get_pk",
        "data = np.loadtxt(sys.argv[1])",
        "pk_data = {'k': data[:, 0], 'pk': data[:, 1]}",
        "name = sys.argv[2]",
        "kmin = float(sys.argv[3])",
        "kmax = float(sys.argv[4])",
        "nfft = int(float(sys.argv[5]))",
        "ktarget = float(sys.argv[6])",
        "ps = PowerSpectrum1Loop(kmin_fft=kmin, kmax_fft=kmax, nfft=nfft)",
        "pk_lin = np.asarray(get_pk(ps._kn, pk_data, kmin=ps._kmin, kmax=ps._kmax), dtype=float)",
        "p_q, p_k, p_k0 = ps.decomp['pk_lin nu=-0.7'].get_decomposed_data(pk_lin)",
        "p_q = np.asarray(p_q, dtype=np.complex128)",
        "p_k0 = np.asarray(p_k0, dtype=np.complex128)",
        "idx = int(np.argmin(np.abs(np.asarray(ps._kn, dtype=float) - ktarget)))",
        "name = name[:-4] if name.endswith('.txt') else name",
        "kernel = np.asarray(ps.matrix[name], dtype=np.complex128)",
        "coeff = np.asarray(p_q[:, idx], dtype=np.complex128)",
        "coeff_outer = np.outer(coeff, coeff)",
        "loop_integrand = coeff_outer * kernel",
        "k0_outer = np.outer(p_k0, p_k0)",
        "k0_integrand = k0_outer * kernel",
        "kernel_T = kernel.T",
        "loop_integrand_T = coeff_outer * kernel_T",
        "k0_integrand_T = k0_outer * kernel_T",
        "loop_core = np.sum(loop_integrand)",
        "k0_core = np.sum(k0_integrand)",
        "loop_core_T = np.sum(loop_integrand_T)",
        "k0_core_T = np.sum(k0_integrand_T)",
        "payload = {",
        "  'Sector': name + '.txt',",
        "  'Kind': 'M22',",
        "  'Index': idx + 1,",
        "  'KTarget': ktarget,",
        "  'KUsed': float(np.asarray(ps._kn, dtype=float)[idx]),",
        "  'NuGrid': np.asarray(-0.5 * ps.decomp['pk_lin nu=-0.7'].nu_m, dtype=np.complex128).tolist(),",
        "  'CoefficientVector': coeff.tolist(),",
        "  'CoefficientOuter': coeff_outer.tolist(),",
        "  'KernelMatrix': kernel.tolist(),",
        "  'LoopIntegrandMatrix': loop_integrand.tolist(),",
        "  'LoopCore': complex(loop_core),",
        "  'LoopTerm': float((ps._kn[idx]**3 * loop_core.real)),",
        "  'K0CoefficientVector': p_k0.tolist(),",
        "  'K0CoefficientOuter': k0_outer.tolist(),",
        "  'K0IntegrandMatrix': k0_integrand.tolist(),",
        "  'K0Core': complex(k0_core),",
        "  'K0Term': float((ps._kmin**3 * k0_core.real)),",
        "  'Total': float((ps._kn[idx]**3 * loop_core.real) - (ps._kmin**3 * k0_core.real)),",
        "  'KernelMatrixTransposeTrial': kernel_T.tolist(),",
        "  'LoopIntegrandMatrixTransposeTrial': loop_integrand_T.tolist(),",
        "  'LoopCoreTransposeTrial': complex(loop_core_T),",
        "  'LoopTermTransposeTrial': float((ps._kn[idx]**3 * loop_core_T.real)),",
        "  'K0IntegrandMatrixTransposeTrial': k0_integrand_T.tolist(),",
        "  'K0CoreTransposeTrial': complex(k0_core_T),",
        "  'K0TermTransposeTrial': float((ps._kmin**3 * k0_core_T.real)),",
        "  'TotalTransposeTrial': float((ps._kn[idx]**3 * loop_core_T.real) - (ps._kmin**3 * k0_core_T.real))",
        "}",
        "print(json.dumps(payload, default=lambda x: [x.real, x.imag] if isinstance(x, complex) else x))"
    }, "\n"];
    parsed = runPythonJSON[
        code,
        {
            linearPath,
            stripTxtExtension[sectorFile],
            ToString @ N @ Lookup[fftAssoc, "kMin", Min[kInternal]],
            ToString @ N @ Lookup[fftAssoc, "kMax", Max[kInternal]],
            ToString @ Lookup[fftAssoc, "N", Length[kInternal]],
            ToString @ N @ kTarget
        }
    ];
    ensureAssociation[parsed]
];

GetPs1LoopM22ContractionIngredients[fftAssoc_Association, linAssoc_Association, sectorFile_String, kTarget_?NumericQ] := Module[{path},
    path = Lookup[linAssoc, "Path", Missing["NoPath"]];
    If[MissingQ[path] || !FileExistsQ[path], Return[<||>]];
    GetPs1LoopM22ContractionIngredients[fftAssoc, path, sectorFile, kTarget]
];

normalizeComplexJSON[data_] := data /. {re_?NumericQ, im_?NumericQ} :> N[re + I im];

CompareSingleM13ContractionWithPs1Loop[fftAssoc_Association, linearPath_, sectorFile_String, kTarget_?NumericQ, plin_: Automatic] := Module[
    {mathematica, reference},
    mathematica = GetM13ContractionIngredients[fftAssoc, sectorFile, kTarget, plin];
    reference = normalizeComplexJSON @ GetPs1LoopM13ContractionIngredients[fftAssoc, linearPath, sectorFile, kTarget];
    <|
        "Mathematica" -> mathematica,
        "Reference" -> reference,
        "CoefficientVectorStats" -> arrayComparisonStats[mathematica["CoefficientVector"], reference["CoefficientVector"]],
        "KernelVectorStats" -> arrayComparisonStats[mathematica["KernelVector"], reference["KernelVector"]],
        "IntegrandVectorStats" -> arrayComparisonStats[mathematica["IntegrandVector"], reference["IntegrandVector"]],
        "PkValueDifference" -> N[mathematica["PkValue"] - reference["PkValue"]],
        "CoreSumDifference" -> N[mathematica["CoreSum"] - reference["CoreSum"]],
        "TotalDifference" -> N[mathematica["Total"] - reference["Total"]]
    |>
];

CompareSingleM22ContractionWithPs1Loop[fftAssoc_Association, linearPath_, sectorFile_String, kTarget_?NumericQ] := Module[
    {mathematica, reference, matrixDirect, matrixTranspose, loopDirect, loopTranspose, k0Direct, k0Transpose},
    mathematica = GetM22ContractionIngredients[fftAssoc, sectorFile, kTarget];
    reference = normalizeComplexJSON @ GetPs1LoopM22ContractionIngredients[fftAssoc, linearPath, sectorFile, kTarget];
    matrixDirect = arrayComparisonStats[mathematica["KernelMatrix"], reference["KernelMatrix"]];
    matrixTranspose = arrayComparisonStats[mathematica["KernelMatrix"], Transpose[reference["KernelMatrix"]]];
    loopDirect = arrayComparisonStats[mathematica["LoopIntegrandMatrix"], reference["LoopIntegrandMatrix"]];
    loopTranspose = arrayComparisonStats[mathematica["LoopIntegrandMatrixTransposeTrial"], reference["LoopIntegrandMatrix"]];
    k0Direct = arrayComparisonStats[mathematica["K0IntegrandMatrix"], reference["K0IntegrandMatrix"]];
    k0Transpose = arrayComparisonStats[mathematica["K0IntegrandMatrixTransposeTrial"], reference["K0IntegrandMatrix"]];
    <|
        "Mathematica" -> mathematica,
        "Reference" -> reference,
        "CoefficientVectorStats" -> arrayComparisonStats[mathematica["CoefficientVector"], reference["CoefficientVector"]],
        "CoefficientOuterStats" -> arrayComparisonStats[mathematica["CoefficientOuter"], reference["CoefficientOuter"]],
        "KernelMatrixDirectStats" -> matrixDirect,
        "KernelMatrixTransposeStats" -> matrixTranspose,
        "LoopIntegrandDirectStats" -> loopDirect,
        "LoopIntegrandTransposeStats" -> loopTranspose,
        "K0IntegrandDirectStats" -> k0Direct,
        "K0IntegrandTransposeStats" -> k0Transpose,
        "LoopTermDifference" -> N[mathematica["LoopTerm"] - reference["LoopTerm"]],
        "LoopTermTransposeDifference" -> N[mathematica["LoopTermTransposeTrial"] - reference["LoopTerm"]],
        "K0TermDifference" -> N[mathematica["K0Term"] - reference["K0Term"]],
        "K0TermTransposeDifference" -> N[mathematica["K0TermTransposeTrial"] - reference["K0Term"]],
        "TotalDifference" -> N[mathematica["Total"] - reference["Total"]],
        "TotalTransposeDifference" -> N[mathematica["TotalTransposeTrial"] - reference["Total"]],
        "BestKernelOrientation" -> If[
            Lookup[matrixTranspose, "MaxAbsError", Infinity] < Lookup[matrixDirect, "MaxAbsError", Infinity],
            "Transpose",
            "Direct"
        ],
        "BestLoopOrientation" -> If[
            Lookup[loopTranspose, "MaxAbsError", Infinity] < Lookup[loopDirect, "MaxAbsError", Infinity],
            "Transpose",
            "Direct"
        ]
    |>
];

CompareFFTLogContractionsWithPs1Loop[fftAssoc_Association, linearPath_, plin_: Automatic] := Module[
    {rawCache, refs, kInternal, m13Stats, m22Stats, m22LoopStats, m22K0Stats},
    rawCache = BuildRawOneLoopSectorCache[fftAssoc, plin];
    refs = GetPs1LoopContractionReference[fftAssoc, linearPath];
    kInternal = rawCache["kInternal"];
    m13Stats = compareSectorAssociations[kInternal, rawCache["M13BySectorRawInternal"], refs["M13"]];
    m22Stats = compareSectorAssociations[kInternal, rawCache["M22BySectorRawInternal"], refs["M22"]];
    m22LoopStats = compareSectorAssociations[kInternal, Lookup[rawCache, "M22LoopBySectorInternal", <||>], refs["M22Loop"]];
    m22K0Stats = compareSectorAssociations[kInternal, Lookup[rawCache, "M22K0BySectorInternal", <||>], refs["M22K0"]];
    <|
        "kInternal" -> kInternal,
        "ComputedRawCache" -> rawCache,
        "ReferenceData" -> refs,
        "M13Stats" -> m13Stats,
        "M22Stats" -> m22Stats,
        "M22LoopStats" -> m22LoopStats,
        "M22K0Stats" -> m22K0Stats,
        "WorstM13Sector" -> worstSectorEntry[m13Stats],
        "WorstM22Sector" -> worstSectorEntry[m22Stats],
        "WorstM22LoopSector" -> worstSectorEntry[m22LoopStats],
        "WorstM22K0Sector" -> worstSectorEntry[m22K0Stats]
    |>
];

GetPs1LoopSectorReference[kgrid_List, linearPath_String] := Module[
    {code, parsed},
    code = StringRiffle[{
        "import json, sys, numpy as np",
        "sys.path.insert(0, '/Users/nguyenmn/ps_1loop_jax-for-pfs/src')",
        "from ps_1loop_jax import PowerSpectrum1Loop",
        "data = np.loadtxt(sys.argv[1])",
        "pk_data = {'k': data[:, 0], 'pk': data[:, 1]}",
        "kgrid = np.array(json.loads(sys.argv[2]), dtype=float)",
        "ps = PowerSpectrum1Loop()",
        "pk_dict = ps.get_pkmu_dict(pk_data)",
        "kn = np.asarray(ps._kn, dtype=float)",
        "payload = {'M13': {}, 'M22': {}}",
        "for name, values in pk_dict.items():",
        "    arr = np.interp(kgrid, kn, np.asarray(values).real.astype(float))",
        "    if name.startswith('M13_'):",
        "        payload['M13'][name + '.txt'] = arr.tolist()",
        "    elif name.startswith('M22_'):",
        "        payload['M22'][name + '.txt'] = arr.tolist()",
        "print(json.dumps(payload))"
    }, "\n"];
    parsed = runPythonJSON[code, {linearPath, ExportString[N @ kgrid, "RawJSON"]}];
    If[!AssociationQ[parsed],
        <|"M13" -> <||>, "M22" -> <||>|>,
        <|
            "M13" -> Association @ KeyValueMap[Function[{k, v}, k -> (N @ v)], Association @ parsed["M13"]],
            "M22" -> Association @ KeyValueMap[Function[{k, v}, k -> (N @ v)], Association @ parsed["M22"]]
        |>
    ]
];

GetPs1LoopSectorReference[kgrid_List, linAssoc_Association] := Module[{path},
    path = Lookup[linAssoc, "Path", Missing["NoPath"]];
    If[MissingQ[path] || !FileExistsQ[path], Return[<|"M13" -> <||>, "M22" -> <||>|>]];
    GetPs1LoopSectorReference[kgrid, path]
];

CompareSectorPlot[k_List, computed_Association, reference_Association, title_] := Module[
    {keys, plots},
    keys = Keys[computed];
    plots = Table[
        ListLogLogPlot[
            DeleteMissing @ {
                If[KeyExistsQ[computed, keys[[i]]], Transpose[{k, computed[keys[[i]]]}], Missing["NoComputed"]],
                If[KeyExistsQ[reference, keys[[i]]], Transpose[{k, reference[keys[[i]]]}], Missing["NoReference"]]
            },
            Frame -> True,
            PlotRange -> All,
            PlotLegends -> DeleteMissing @ {
                If[KeyExistsQ[computed, keys[[i]]], "Computed", Missing["NoComputed"]],
                If[KeyExistsQ[reference, keys[[i]]], "ps_1loop_jax ref", Missing["NoReference"]]
            },
            FrameLabel -> {"k", "P(k)"},
            PlotLabel -> keys[[i]],
            Joined -> True,
            ImageSize -> Large
        ],
        {i, Length[keys]}
    ];
    Grid[Partition[plots, UpTo[4]], Spacings -> {2, 2}]
];

CompareM13M22WithPs1Loop[kgrid_List, linearPath_, m13BySector_Association, m22BySector_Association] := Module[
    {refs},
    refs = GetPs1LoopSectorReference[kgrid, linearPath];
    <|
        "M13Comparison" -> CompareSectorPlot[kgrid, m13BySector, refs["M13"], "M13 sector comparison (computed vs ps_1loop_jax)"],
        "M22Comparison" -> CompareSectorPlot[kgrid, m22BySector, refs["M22"], "M22 sector comparison (computed vs ps_1loop_jax)"],
        "ReferenceData" -> refs
    |>
];

End[];

EndPackage[];
