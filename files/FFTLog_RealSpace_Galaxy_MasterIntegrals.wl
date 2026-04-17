ClearAll["Global`*"];

Get[FileNameJoin[{DirectoryName[$InputFileName], "FFTLog_MasterIntegrals_Common.wl"}]];

$RealSpaceGalaxyPaper = <|
   "Title" -> "Cosmological Perturbation Theory Using the FFTLog: Formalism and Connection to QFT Loop Integrals",
   "ArXiv" -> "1708.08130",
   "Section" -> "One-loop power spectrum of biased tracers in real space"
|>;

$RealSpaceGalaxyNuBias = -1.6;
$RealSpaceGalaxyKernelNames = {
   "I_d2",
   "I_G2",
   "F_G2",
   "I_d2_d2",
   "I_d2_G2",
   "I_G2_G2"
};

RealSpaceGalaxyReducedKernelExpression["I_d2"] :=
  ((-3 + 2 nu1 + 2 nu2)*(-4 + 7 nu1 + 7 nu2))/(14 nu1 nu2);

RealSpaceGalaxyReducedKernelExpression["I_G2"] :=
  -(((-3 + 2 nu1 + 2 nu2)*(-1 + 2 nu1 + 2 nu2)*(6 + 7 nu1 + 7 nu2))/
     (28 nu1 (1 + nu1) nu2 (1 + nu2)));

RealSpaceGalaxyReducedKernelExpression["F_G2"] :=
  (-15 Tan[nu1 Pi])/
   (28 nu1 (-6 + 5 nu1 + 5 nu1^2 - 5 nu1^3 + nu1^4) Pi);

RealSpaceGalaxyReducedKernelExpression["I_d2_d2"] := 2;

RealSpaceGalaxyReducedKernelExpression["I_d2_G2"] :=
  (3 - 2 nu1 - 2 nu2)/(nu1 nu2);

RealSpaceGalaxyReducedKernelExpression["I_G2_G2"] :=
  ((-3 + 2 nu1 + 2 nu2)*(-1 + 2 nu1 + 2 nu2))/
   (nu1 (1 + nu1) nu2 (1 + nu2));

RealSpaceGalaxyReferenceKernelExpression[name_String] :=
  RealSpaceGaussianReferenceExpression[name];

RealSpaceGalaxyKernelValidationExpression[name_String] :=
  FullSimplify[
   RealSpaceGalaxyReducedKernelExpression[name] -
    RealSpaceGalaxyReferenceKernelExpression[name]
  ];

RealSpaceGalaxyKernelValidationSummary[seconds_: 30] :=
  ExactValidationSummary[
   $RealSpaceGalaxyKernelNames,
   RealSpaceGalaxyKernelValidationExpression,
   seconds
  ];

RealSpaceGalaxyKernelNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  NumericResidualSummary[
   $RealSpaceGalaxyKernelNames,
   RealSpaceGalaxyKernelValidationExpression,
   point,
   precision
  ];

RealSpaceGalaxyAutoSpectrumWeights[b1_, b2_, bG2_, bGamma3_] := <|
   "13_dd + 22_dd" -> b1^2,
   "I_d2" -> b1 b2,
   "I_G2" -> 2 b1 bG2,
   "F_G2" -> 2 b1 bG2 + (4/5) b1 bGamma3,
   "I_d2_d2" -> b2^2/4,
   "I_d2_G2" -> b2 bG2,
   "I_G2_G2" -> bG2^2
|>;

RealSpaceGalaxyCrossSpectrumWeights[b1_, b2_, bG2_, bGamma3_] := <|
   "13_dd + 22_dd" -> b1,
   "I_d2" -> b2/2,
   "I_G2" -> bG2,
   "F_G2" -> bG2 + (2/5) bGamma3
|>;
