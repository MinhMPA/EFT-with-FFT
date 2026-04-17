ClearAll["Global`*"];

Get[FileNameJoin[{DirectoryName[$InputFileName], "FFTLog_MasterIntegrals_Common.wl"}]];

$RedshiftSpaceGalaxyPaper = <|
   "Title" -> "Non-linear perturbation theory extension of the Boltzmann code CLASS",
   "ArXiv" -> "2004.10607",
   "Section" -> "Gaussian redshift-space galaxy sector decomposition"
|>;

$RedshiftSpaceGalaxyNuBias = -0.7;
$RedshiftSpaceGalaxyBasisKernelsM13 = {"13_dd", "13_dv", "13_vv", "F_G2"};
$RedshiftSpaceGalaxyBasisKernelsM22 = {
   "22_dd",
   "22_dv",
   "22_vv",
   "I_d2",
   "I_G2",
   "I_d2_d2",
   "I_d2_G2",
   "I_G2_G2",
   "I_d2_v"
};

RSDGalaxyM13SectorFiles[] := RedshiftSpaceGaussianFilenames["M13"];
RSDGalaxyM22SectorFiles[] := RedshiftSpaceGaussianFilenames["M22"];

RSDGalaxyDerivedSectorExpression[file_String] := GaussianSectorKernel[file];

RSDGalaxyReferenceSectorExpression[file_String] :=
  RedshiftSpaceGaussianReferenceExpression[file];

RSDGalaxySectorValidationExpression[file_String] :=
  FullSimplify[
   RSDGalaxyDerivedSectorExpression[file] - RSDGalaxyReferenceSectorExpression[file]
  ];

RSDGalaxySectorValidationSummary[seconds_: 30] := <|
   "M13" -> ExactValidationSummary[
     RSDGalaxyM13SectorFiles[],
     RSDGalaxySectorValidationExpression,
     seconds
    ],
   "M22" -> ExactValidationSummary[
     RSDGalaxyM22SectorFiles[],
     RSDGalaxySectorValidationExpression,
     seconds
    ]
|>;

RSDGalaxySectorNumericResidualSummary[
   point_Association : DefaultValidationPoint[],
   precision_: 40
] := <|
   "M13" -> NumericResidualSummary[
     RSDGalaxyM13SectorFiles[],
     RSDGalaxySectorValidationExpression,
     point,
     precision
    ],
   "M22" -> NumericResidualSummary[
     RSDGalaxyM22SectorFiles[],
     RSDGalaxySectorValidationExpression,
     point,
     precision
    ]
|>;
