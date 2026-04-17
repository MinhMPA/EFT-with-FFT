ClearAll["Global`*"];

Get[FileNameJoin[{DirectoryName[$InputFileName], "FFTLog_MasterIntegrals_Common.wl"}]];

$RedshiftSpaceMatterPaper = <|
   "Title" -> "Non-linear perturbation theory extension of the Boltzmann code CLASS",
   "ArXiv" -> "2004.10607",
   "Section" -> "Redshift-space matter master integrals and Gaussian sector subset"
|>;

$RedshiftSpaceMatterNuBias = -0.7;

$RSDMatterCoefficientMap = <|
   "A1" -> {1, 1},
   "A2" -> {2, 0}, "B2" -> {2, 2},
   "A3" -> {3, 1}, "B3" -> {3, 3},
   "A4" -> {4, 0}, "B4" -> {4, 2}, "C4" -> {4, 4}
|>;

$RSDMatterLabelsByN = <|
   1 -> {"A1"},
   2 -> {"A2", "B2"},
   3 -> {"A3", "B3"},
   4 -> {"A4", "B4", "C4"}
|>;

RSDMatterCoefficientNames[n_Integer?Positive] := Lookup[$RSDMatterLabelsByN, n, {}];

shiftedI[a_Integer?NonNegative, b_Integer?NonNegative][nu1_, nu2_] :=
  ScalarIMaster[nu1 - a, nu2 - b];

RSDMatterReferenceCoefficient["A1"][nu1_, nu2_] :=
  (1/2) (
    shiftedI[1, 0][nu1, nu2] -
     shiftedI[0, 1][nu1, nu2] +
     shiftedI[0, 0][nu1, nu2]
   );

RSDMatterReferenceCoefficient["A2"][nu1_, nu2_] :=
  -(1/8) (
     shiftedI[0, 0][nu1, nu2] +
      shiftedI[0, 2][nu1, nu2] +
      shiftedI[2, 0][nu1, nu2] -
      2 shiftedI[0, 1][nu1, nu2] -
      2 shiftedI[1, 0][nu1, nu2] -
      2 shiftedI[1, 1][nu1, nu2]
    );

RSDMatterReferenceCoefficient["B2"][nu1_, nu2_] :=
  3 (
    shiftedI[0, 0][nu1, nu2] +
     shiftedI[0, 2][nu1, nu2] +
     shiftedI[2, 0][nu1, nu2] +
     (2/3) shiftedI[0, 1][nu1, nu2] -
     2 shiftedI[1, 0][nu1, nu2] -
     2 shiftedI[1, 1][nu1, nu2]
   );

RSDMatterReferenceCoefficient["A3"][nu1_, nu2_] :=
  -(3/16) (
     shiftedI[0, 0][nu1, nu2] +
      shiftedI[3, 0][nu1, nu2] -
      3 shiftedI[2, 1][nu1, nu2] -
      shiftedI[2, 0][nu1, nu2] +
      3 shiftedI[1, 2][nu1, nu2] -
      2 shiftedI[1, 1][nu1, nu2] -
      shiftedI[1, 0][nu1, nu2] -
      shiftedI[0, 3][nu1, nu2] +
      3 shiftedI[0, 2][nu1, nu2] -
      3 shiftedI[0, 1][nu1, nu2]
    );

RSDMatterReferenceCoefficient["B3"][nu1_, nu2_] :=
  (1/16) (
    5 shiftedI[3, 0][nu1, nu2] -
     15 shiftedI[2, 1][nu1, nu2] +
     3 shiftedI[2, 0][nu1, nu2] +
     15 shiftedI[1, 2][nu1, nu2] -
     18 shiftedI[1, 1][nu1, nu2] +
     3 shiftedI[1, 0][nu1, nu2] -
     5 shiftedI[0, 3][nu1, nu2] +
     15 shiftedI[0, 2][nu1, nu2] -
     15 shiftedI[0, 1][nu1, nu2] +
     5 shiftedI[0, 0][nu1, nu2]
   );

RSDMatterReferenceCoefficient["A4"][nu1_, nu2_] :=
  (3/128) (
    shiftedI[4, 0][nu1, nu2] -
     4 shiftedI[3, 1][nu1, nu2] -
     4 shiftedI[3, 0][nu1, nu2] +
     6 shiftedI[2, 2][nu1, nu2] +
     4 shiftedI[2, 1][nu1, nu2] +
     6 shiftedI[2, 0][nu1, nu2] -
     4 shiftedI[1, 3][nu1, nu2] +
     4 shiftedI[1, 2][nu1, nu2] +
     4 shiftedI[1, 1][nu1, nu2] -
     4 shiftedI[1, 0][nu1, nu2] +
     shiftedI[0, 4][nu1, nu2] -
     4 shiftedI[0, 3][nu1, nu2] +
     6 shiftedI[0, 2][nu1, nu2] -
     4 shiftedI[0, 1][nu1, nu2] +
     shiftedI[0, 0][nu1, nu2]
   );

RSDMatterReferenceCoefficient["B4"][nu1_, nu2_] :=
  -(3/64) (
     5 shiftedI[4, 0][nu1, nu2] -
      20 shiftedI[3, 1][nu1, nu2] -
      4 shiftedI[3, 0][nu1, nu2] +
      30 shiftedI[2, 2][nu1, nu2] -
      12 shiftedI[2, 1][nu1, nu2] -
      2 shiftedI[2, 0][nu1, nu2] -
      20 shiftedI[1, 3][nu1, nu2] +
      36 shiftedI[1, 2][nu1, nu2] -
      12 shiftedI[1, 1][nu1, nu2] -
      4 shiftedI[1, 0][nu1, nu2] +
      5 shiftedI[0, 4][nu1, nu2] -
      20 shiftedI[0, 3][nu1, nu2] +
      30 shiftedI[0, 2][nu1, nu2] -
      20 shiftedI[0, 1][nu1, nu2] +
      5 shiftedI[0, 0][nu1, nu2]
    );

RSDMatterReferenceCoefficient["C4"][nu1_, nu2_] :=
  (1/128) (
    35 shiftedI[4, 0][nu1, nu2] -
     140 shiftedI[3, 1][nu1, nu2] +
     20 shiftedI[3, 0][nu1, nu2] +
     210 shiftedI[2, 2][nu1, nu2] -
     180 shiftedI[2, 1][nu1, nu2] +
     18 shiftedI[2, 0][nu1, nu2] -
     140 shiftedI[1, 3][nu1, nu2] +
     300 shiftedI[1, 2][nu1, nu2] -
     180 shiftedI[1, 1][nu1, nu2] +
     20 shiftedI[1, 0][nu1, nu2] +
     35 shiftedI[0, 4][nu1, nu2] -
     140 shiftedI[0, 3][nu1, nu2] +
     210 shiftedI[0, 2][nu1, nu2] -
     140 shiftedI[0, 1][nu1, nu2] +
     35 shiftedI[0, 0][nu1, nu2]
   );

RSDMatterDerivedCoefficient[name_String][nu1_, nu2_] := Module[{spec},
  spec = Lookup[$RSDMatterCoefficientMap, name, Missing["UnknownCoefficient", name]];
  If[MissingQ[spec], spec, DerivedLOSCoefficient[spec[[1]], spec[[2]], nu1, nu2]]
];

RSDMatterReferenceMasterIntegral[n_Integer?Positive, nu1_, nu2_, mu_, k_] /;
   KeyExistsQ[$RSDMatterLabelsByN, n] :=
  k^(3 - 2 (nu1 + nu2))*k^n*
   Total[
    (mu^Lookup[$RSDMatterCoefficientMap, #][[2]])*
       RSDMatterReferenceCoefficient[#][nu1, nu2] & /@
     $RSDMatterLabelsByN[n]
   ];

RSDMatterDerivedMasterIntegral[n_Integer?Positive, nu1_, nu2_, mu_, k_] /;
   KeyExistsQ[$RSDMatterLabelsByN, n] :=
  k^(3 - 2 (nu1 + nu2))*k^n*
   Total[
    (mu^Lookup[$RSDMatterCoefficientMap, #][[2]])*
       RSDMatterDerivedCoefficient[#][nu1, nu2] & /@
     $RSDMatterLabelsByN[n]
   ];

RSDMatterCoefficientValidationExpression[name_String] :=
  FullSimplify[
   RSDMatterDerivedCoefficient[name][nu1, nu2] -
    RSDMatterReferenceCoefficient[name][nu1, nu2]
  ];

RSDMatterCoefficientValidationSummary[seconds_: 30] :=
  ExactValidationSummary[
   Keys[$RSDMatterCoefficientMap],
   RSDMatterCoefficientValidationExpression,
   seconds
  ];

RSDMatterCoefficientNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  NumericResidualSummary[
   Keys[$RSDMatterCoefficientMap],
   RSDMatterCoefficientValidationExpression,
   point,
   precision
  ];

RSDMatterMasterIntegralValidationExpression[n_Integer?Positive] /;
   KeyExistsQ[$RSDMatterLabelsByN, n] :=
  FullSimplify[
   RSDMatterDerivedMasterIntegral[n, nu1, nu2, mu, k] -
    RSDMatterReferenceMasterIntegral[n, nu1, nu2, mu, k]
  ];

RSDMatterMasterIntegralValidationSummary[seconds_: 30] :=
  ExactValidationSummary[
   Keys[$RSDMatterLabelsByN],
   RSDMatterMasterIntegralValidationExpression,
   seconds
  ];

RSDMatterMasterIntegralNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  NumericResidualSummary[
   Keys[$RSDMatterLabelsByN],
   RSDMatterMasterIntegralValidationExpression,
   point,
   precision
  ];

RSDMatterM13SectorFiles[] :=
  Select[
   RedshiftSpaceGaussianFilenames["M13"],
   With[{meta = ParseBiasSectorFilename[#]},
      Lookup[meta, "bG2", 0] == 0 && Lookup[meta, "bGamma3", 0] == 0
     ] &
  ];

RSDMatterM22SectorFiles[] :=
  Select[
   RedshiftSpaceGaussianFilenames["M22"],
   With[{meta = ParseBiasSectorFilename[#]},
      Lookup[meta, "b2", 0] == 0 && Lookup[meta, "bG2", 0] == 0
     ] &
  ];

RSDMatterDerivedSectorExpression[file_String] := GaussianSectorKernel[file];

RSDMatterReferenceSectorExpression[file_String] :=
  RedshiftSpaceGaussianReferenceExpression[file];

RSDMatterSectorValidationExpression[file_String] :=
  FullSimplify[
   RSDMatterDerivedSectorExpression[file] - RSDMatterReferenceSectorExpression[file]
  ];

RSDMatterSectorValidationSummary[seconds_: 30] := <|
   "M13" -> ExactValidationSummary[
     RSDMatterM13SectorFiles[],
     RSDMatterSectorValidationExpression,
     seconds
    ],
   "M22" -> ExactValidationSummary[
     RSDMatterM22SectorFiles[],
     RSDMatterSectorValidationExpression,
     seconds
    ]
|>;

RSDMatterSectorNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] := <|
   "M13" -> NumericResidualSummary[
     RSDMatterM13SectorFiles[],
     RSDMatterSectorValidationExpression,
     point,
     precision
    ],
   "M22" -> NumericResidualSummary[
     RSDMatterM22SectorFiles[],
     RSDMatterSectorValidationExpression,
     point,
     precision
    ]
|>;
