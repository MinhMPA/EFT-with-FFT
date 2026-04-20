ClearAll["Global`*"];

Get[FileNameJoin[{DirectoryName[$InputFileName], "FFTLog_MasterIntegrals_DerivationCommon.wl"}]];

$RealSpaceMatterPaper = <|
   "Title" -> "Cosmological Perturbation Theory Using the FFTLog: Formalism and Connection to QFT Loop Integrals",
   "ArXiv" -> "1708.08130",
   "Section" -> "One-loop power spectrum of matter in real space"
|>;

$RealSpaceMatterNuBias = -0.3;
$RealSpaceMatterKernelNames = {"13_dd", "22_dd"};
$RealSpaceMatterIdentityNames = {"Symmetry", "Inversion", "RecursionNu1", "RecursionNu2"};
$ClassPTMatterDefaults = <|
   "Nmax" -> 256,
   "Bias" -> -0.3,
   "kmax" -> 10.^2,
   "k0" -> 0.00005
|>;

MatterScalarMaster[nu1_, nu2_] := ScalarIMaster[nu1, nu2];

MatterIdentityExpression["Symmetry"] :=
  FullSimplify[MatterScalarMaster[nu1, nu2] - MatterScalarMaster[nu2, nu1]];

MatterIdentityExpression["Inversion"] :=
  FullSimplify[MatterScalarMaster[nu1, nu2] - MatterScalarMaster[3 - nu1 - nu2, nu2]];

MatterIdentityExpression["RecursionNu1"] :=
  FullSimplify[
   (3 - 2 nu1 - nu2) MatterScalarMaster[nu1, nu2] +
    nu2 (MatterScalarMaster[nu1, nu2 + 1] - MatterScalarMaster[nu1 - 1, nu2 + 1])
  ];

MatterIdentityExpression["RecursionNu2"] :=
  FullSimplify[
   (3 - nu1 - 2 nu2) MatterScalarMaster[nu1, nu2] +
    nu1 (MatterScalarMaster[nu1 + 1, nu2] - MatterScalarMaster[nu1 + 1, nu2 - 1])
  ];

MatterReducedKernelExpression["13_dd"] :=
  ((1 + 9 nu1) Tan[nu1 Pi])/
   (112 nu1 (-6 + 5 nu1 + 5 nu1^2 - 5 nu1^3 + nu1^4) Pi);

MatterReducedKernelExpression["22_dd"] :=
  ((-3 + 2 nu1 + 2 nu2)*(-1 + 2 nu1 + 2 nu2)*
     (58 + 98 nu1^3 nu2 + (3 - 91 nu2) nu2 +
       7 nu1^2 (-13 - 2 nu2 + 28 nu2^2) +
       nu1 (3 + 2 nu2 (-73 + 7 nu2 (-1 + 7 nu2)))))/
   (196 nu1 (1 + nu1) (-1 + 2 nu1) nu2 (1 + nu2) (-1 + 2 nu2));

MatterReferenceKernelExpression[name_String] :=
  RealSpaceGaussianReferenceExpression[name];

MatterKernelValidationExpression[name_String] :=
  FullSimplify[
   MatterReducedKernelExpression[name] - MatterReferenceKernelExpression[name]
  ];

MatterIdentitySummary[seconds_: 30] :=
  ExactValidationSummary[$RealSpaceMatterIdentityNames, MatterIdentityExpression, seconds];

MatterIdentityNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  NumericResidualSummary[
   $RealSpaceMatterIdentityNames,
   MatterIdentityExpression,
   point,
   precision
  ];

MatterKernelValidationSummary[seconds_: 30] :=
  ExactValidationSummary[$RealSpaceMatterKernelNames, MatterKernelValidationExpression, seconds];

MatterKernelNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  NumericResidualSummary[
   $RealSpaceMatterKernelNames,
   MatterKernelValidationExpression,
   point,
   precision
  ];

ClassPTMatterDelta[nmax_Integer?Positive, kmax_?NumericQ, k0_?NumericQ] :=
  Log[kmax/k0]/(nmax - 1);

ClassPTMatterEtaGrid[
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  Module[{delta},
   delta = ClassPTMatterDelta[nmax, kmax, k0];
   Table[bias + (2 I Pi j)/(nmax delta), {j, -nmax/2, nmax/2}]
  ];

ClassPTMatterNuGrid[
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  (-1/2) ClassPTMatterEtaGrid[nmax, bias, kmax, k0];

ClassPTMatterM13Vector[
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  N[MatterReducedKernelExpression["13_dd"] /. nu1 -> #, 30] & /@
   ClassPTMatterNuGrid[nmax, bias, kmax, k0];

ClassPTMatterM22Matrix[
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  Module[{nus, halfIndex, directRows},
   nus = ClassPTMatterNuGrid[nmax, bias, kmax, k0];
   halfIndex = Floor[nmax/2] + 1;
   directRows =
    Table[
     N[
      (MatterReducedKernelExpression["22_dd"]*MatterScalarMaster[nu1, nu2]) /. {
        nu1 -> nus[[i]],
        nu2 -> nus[[j]]
       },
      30
     ],
     {i, 1, halfIndex},
     {j, 1, nmax + 1}
    ];
   Table[
    If[i <= halfIndex,
      directRows[[i, j]],
      Conjugate[directRows[[nmax + 2 - i, nmax + 2 - j]]]
    ],
    {i, 1, nmax + 1},
    {j, 1, nmax + 1}
   ]
  ];

ClassPTPackedLowerTriangle[matrix_?MatrixQ] :=
  Flatten@Table[matrix[[i, j]], {j, 1, Length[matrix]}, {i, j, Length[matrix]}];

ClassPTSerializeComplexVector[values_List] :=
  Join[Re[values], Im[values]];

ClassPTSerializeComplexPackedMatrix[matrix_?MatrixQ] :=
  Module[{packed = ClassPTPackedLowerTriangle[matrix]},
   Join[Re[packed], Im[packed]]
  ];

ExportTableWithTrailingNewline[path_String, data_List] :=
  Module[{stream},
   Export[path, List /@ data, "Table"];
   stream = OpenAppend[path];
   WriteString[stream, "\n"];
   Close[stream];
   path
  ];

ExportClassPTMatterM13Table[
   path_String,
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  Module[{data},
   If[!DirectoryQ[DirectoryName[path]],
    CreateDirectory[DirectoryName[path], CreateIntermediateDirectories -> True]
   ];
   data = ClassPTSerializeComplexVector[
     ClassPTMatterM13Vector[nmax, bias, kmax, k0]
    ];
   ExportTableWithTrailingNewline[path, data]
  ];

ExportClassPTMatterM22Table[
   path_String,
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  Module[{data},
   If[!DirectoryQ[DirectoryName[path]],
    CreateDirectory[DirectoryName[path], CreateIntermediateDirectories -> True]
   ];
   data = ClassPTSerializeComplexPackedMatrix[
     ClassPTMatterM22Matrix[nmax, bias, kmax, k0]
    ];
   ExportTableWithTrailingNewline[path, data]
  ];

LocalClassPTReferencePath["M22", 256] :=
  ResolveNotebookRelativePath[
   "pt_matrices",
   "M22oneline_N256_packed_CLASS-PTreference.dat"
  ];

LocalClassPTReferencePath[
   kind_String /; MemberQ[{"M13", "M22"}, kind],
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"]
] :=
  ResolveNotebookRelativePath[
   "pt_matrices",
   kind <> "oneline_N" <> ToString[nmax] <> "_CLASS-PTreference.dat"
  ];

LocalClassPTReferenceTable[
   kind_String /; MemberQ[{"M13", "M22"}, kind],
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"]
] :=
  Flatten @ Import[LocalClassPTReferencePath[kind, nmax], "Table"];

LocalNotebookEvaluationPath[
   kind_String /; MemberQ[{"M13", "M22"}, kind],
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"]
] :=
  ResolveNotebookRelativePath[
   "pt_matrices",
   kind <> "oneline_N" <> ToString[nmax] <> "_NBevaluation.dat"
  ];

ExportLocalNotebookEvaluationTable[
   kind_String /; MemberQ[{"M13", "M22"}, kind],
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  Switch[kind,
   "M13",
   ExportClassPTMatterM13Table[
    LocalNotebookEvaluationPath["M13", nmax],
    nmax,
    bias,
    kmax,
    k0
   ],
   "M22",
   ExportClassPTMatterM22Table[
    LocalNotebookEvaluationPath["M22", nmax],
    nmax,
    bias,
    kmax,
    k0
   ]
  ];

ExportLocalNotebookEvaluationTables[
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  <|
   "M13" -> ExportLocalNotebookEvaluationTable["M13", nmax, bias, kmax, k0],
   "M22" -> ExportLocalNotebookEvaluationTable["M22", nmax, bias, kmax, k0]
  |>;

LocalNotebookEvaluationComparison[
   kind_String /; MemberQ[{"M13", "M22"}, kind],
   nmax : (_Integer?Positive) : $ClassPTMatterDefaults["Nmax"],
   bias : (_?NumericQ) : $ClassPTMatterDefaults["Bias"],
   kmax : (_?NumericQ) : $ClassPTMatterDefaults["kmax"],
   k0 : (_?NumericQ) : $ClassPTMatterDefaults["k0"]
] :=
  Module[{derived, reference, diff},
   derived = Switch[kind,
     "M13",
     N[ClassPTSerializeComplexVector[ClassPTMatterM13Vector[nmax, bias, kmax, k0]], 20],
     "M22",
     N[ClassPTSerializeComplexPackedMatrix[ClassPTMatterM22Matrix[nmax, bias, kmax, k0]], 20]
    ];
   reference = LocalClassPTReferenceTable[kind, nmax];
   diff = N[derived - reference, 20];
   <|
    "ReferenceFile" -> LocalClassPTReferencePath[kind, nmax],
    "OutputFile" -> LocalNotebookEvaluationPath[kind, nmax],
    "Length" -> Length[derived],
    "MaxAbsDifference" -> Max[Abs[diff]],
    "MeanAbsDifference" -> Mean[Abs[diff]]
   |>
  ];
