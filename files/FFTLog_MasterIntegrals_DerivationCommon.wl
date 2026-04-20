BeginPackage["FFTLogMasterIntegrals`"];

ResolveDerivationPath::usage =
  "ResolveDerivationPath[parts...] builds a path relative to this derivation-first notebook suite.";
ScalarIMaster::usage =
  "ScalarIMaster[nu1, nu2] is the scalar FFTLog master integral I(nu1,nu2).";
ShiftedScalarIMaster::usage =
  "ShiftedScalarIMaster[a,b][nu1,nu2] returns ScalarIMaster[nu1-a,nu2-b].";
ShiftedScalarIMasterRatio::usage =
  "ShiftedScalarIMasterRatio[a,b][nu1,nu2] returns ScalarIMaster[nu1-a,nu2-b]/ScalarIMaster[nu1,nu2].";
DerivedLOSCoefficientByM::usage =
  "DerivedLOSCoefficientByM[n,m,nu1,nu2] is the Schwinger-derived coefficient of mu^(n-2 m).";
DerivedLOSCoefficient::usage =
  "DerivedLOSCoefficient[n,muPower,nu1,nu2] returns the LOS coefficient at the requested mu power.";
KernelReferenceText::usage =
  "KernelReferenceText[path] imports and trims one reference expression text file.";
KernelReferenceExpression::usage =
  "KernelReferenceExpression[path] parses one Mathematica expression from a reference text file.";
DefaultValidationPoint::usage =
  "DefaultValidationPoint[] returns a deterministic rational test point.";
ExactValidationSummary::usage =
  "ExactValidationSummary[keys,residualFn,seconds] validates each residual exactly, using normalization before heavy simplification; set seconds to Infinity or None to disable timeouts.";
NumericResidualSummary::usage =
  "NumericResidualSummary[keys,residualFn,point,precision] evaluates deterministic residuals.";
StableNumericResidual::usage =
  "StableNumericResidual[expr,precision] evaluates one residual numerically at elevated working precision and suppresses harmless internal-precision warnings.";
NormalizeValidationResidual::usage =
  "NormalizeValidationResidual[expr] applies Together/Cancel normalization before exact or numeric validation.";
ValidationResidualQ::usage =
  "ValidationResidualQ[expr,seconds] returns True when expr is proven to vanish; set seconds to Infinity or None to disable timeouts.";
ValidationAssumptions::usage =
  "ValidationAssumptions[] returns the generic symbolic assumptions used in exact residual checks.";

Begin["`Private`"];

$FFTLogDerivationRoot = Replace[DirectoryName[$InputFileName], {
    _String?(StringLength[#] > 0 &) :> DirectoryName[$InputFileName],
    _ :> Directory[]
}];

ResolveDerivationPath[parts__String] :=
  FileNameJoin[{$FFTLogDerivationRoot, parts}];

parseMathematicaExpression[text_String] :=
  Replace[
   ToExpression[text, InputForm, HoldComplete],
   HoldComplete[expr_] :> expr
  ];

KernelReferenceText[path_String] :=
  KernelReferenceText[path] = StringTrim[Import[path, "Text"]];

KernelReferenceExpression[path_String] :=
  KernelReferenceExpression[path] =
   parseMathematicaExpression[KernelReferenceText[path]];

ScalarIMaster[nu1_, nu2_] :=
  (1/(8 Pi^(3/2)))*
   Gamma[3/2 - nu1]*
   Gamma[3/2 - nu2]*
   Gamma[nu1 + nu2 - 3/2]/
   (Gamma[nu1] Gamma[nu2] Gamma[3 - nu1 - nu2]);

ShiftedScalarIMasterRatio[a_Integer?NonNegative, b_Integer?NonNegative][nu1_, nu2_] :=
  Module[{s = nu1 + nu2 - 3/2, t = 3 - nu1 - nu2},
   Pochhammer[3/2 - nu1, a]*
    Pochhammer[3/2 - nu2, b]*
    Pochhammer[nu1 - a, a]*
    Pochhammer[nu2 - b, b]/
    (Pochhammer[s - a - b, a + b]*Pochhammer[t, a + b])
  ];

ShiftedScalarIMaster[a_Integer?NonNegative, b_Integer?NonNegative][nu1_, nu2_] :=
  ScalarIMaster[nu1, nu2]*
   ShiftedScalarIMasterRatio[a, b][nu1, nu2];

DerivedLOSCoefficientByM[n_Integer?NonNegative, m_Integer?NonNegative, nu1_, nu2_] /;
   0 <= 2 m <= n :=
  (Factorial[n]/(Factorial[m] Factorial[n - 2 m] 4^m))*
   (1/(8 Pi^(3/2)))*
   Gamma[nu1 + nu2 - 3/2 - m]*
   Gamma[3/2 - nu2 + m]*
   Gamma[n - m + 3/2 - nu1]/
   (Gamma[nu1] Gamma[nu2] Gamma[n + 3 - nu1 - nu2]);

DerivedLOSCoefficient[n_Integer?NonNegative, muPower_Integer?NonNegative, nu1_, nu2_] /;
   muPower <= n && EvenQ[n - muPower] :=
  Module[{m = (n - muPower)/2},
   DerivedLOSCoefficientByM[n, m, nu1, nu2]
  ];

DefaultValidationPoint[] := <|
   "nu1" -> 2/5,
   "nu2" -> 3/7,
   "mu" -> 5/11,
   "k" -> 7/5
|>;

ValidationAssumptions[] :=
  Element[{nu1, nu2, mu, k}, Reals];

validationWorkingPrecision[precision_] :=
  Max[precision + 30, 2 precision];

NormalizeValidationResidual[expr_] :=
  Module[{expanded, combined, numerator, denominator, factors},
   expanded = Quiet @ Check[FunctionExpand[expr], expr];
   combined = Quiet @ Check[Together[expanded], expanded];
   combined = Quiet @ Check[Cancel[combined], combined];
   numerator = Quiet @ Check[Numerator[combined], combined];
   denominator = Quiet @ Check[Denominator[combined], 1];
   factors = Quiet @ Check[FactorTermsList[numerator], {1, numerator}];
   Quiet @ Check[Together[(Last[factors])/denominator], combined]
  ];

applyNumericValidationPoint[
   expr_,
   point_Association,
   precision_
] :=
  Module[{wp = validationWorkingPrecision[precision]},
   expr /. {
     s_Symbol /; KeyExistsQ[point, "nu1"] && SymbolName[Unevaluated[s]] == "nu1" :>
       N[Lookup[point, "nu1"], wp],
     s_Symbol /; KeyExistsQ[point, "nu2"] && SymbolName[Unevaluated[s]] == "nu2" :>
       N[Lookup[point, "nu2"], wp],
     s_Symbol /; KeyExistsQ[point, "mu"] && SymbolName[Unevaluated[s]] == "mu" :>
       N[Lookup[point, "mu"], wp],
     s_Symbol /; KeyExistsQ[point, "k"] && SymbolName[Unevaluated[s]] == "k" :>
       N[Lookup[point, "k"], wp]
    }
  ];

StableNumericResidual[
   expr_,
   precision_: 40
] :=
  Module[{wp, numeric},
   wp = validationWorkingPrecision[precision];
   numeric =
    Quiet[
     Check[
      N[expr, wp],
      $Failed
     ],
     {N::meprec, General::stop}
    ];
   Which[
    TrueQ[expr === 0], 0,
    numeric === $Failed, $Failed,
    TrueQ[numeric === 0], 0,
    True, Chop[N[numeric, precision]]
   ]
  ];

SetAttributes[validationTimeControl, HoldFirst];
validationTimeControl[expr_, seconds_] /;
   seconds === Infinity || seconds === None :=
  expr;
validationTimeControl[expr_, seconds_?NumericQ] :=
  TimeConstrained[expr, seconds, $Aborted];
validationTimeControl[expr_, _] := expr;

ValidationResidualQ[expr_, seconds_: Infinity, alreadyNormalized_: False] :=
  validationTimeControl[
   Quiet @ Check[
     Module[{normalized, numerator},
     normalized =
       If[TrueQ[alreadyNormalized], expr, NormalizeValidationResidual[expr]];
      numerator = Quiet @ Check[Numerator[normalized], normalized];
      TrueQ[normalized === 0] ||
       TrueQ[numerator === 0] ||
       TrueQ[Simplify[numerator == 0, Assumptions -> ValidationAssumptions[]]] ||
       TrueQ[Simplify[normalized == 0, Assumptions -> ValidationAssumptions[]]] ||
       TrueQ[FullSimplify[numerator == 0, Assumptions -> ValidationAssumptions[]]] ||
       TrueQ[FullSimplify[normalized == 0, Assumptions -> ValidationAssumptions[]]]
     ],
     $Failed
    ],
   seconds
  ];

Options[ExactValidationSummary] = {
  "Progress" -> False,
  "AlreadyNormalized" -> False
};

ExactValidationSummary[
   keys_List,
   residualFn_,
   seconds_: 30,
   OptionsPattern[]
] :=
  Module[
   {results = <||>, progressQ, alreadyNormalizedQ, total, index = 0, key, result},
   progressQ = TrueQ[OptionValue["Progress"]];
   alreadyNormalizedQ = TrueQ[OptionValue["AlreadyNormalized"]];
   total = Length[keys];
   Do[
    index++;
    If[progressQ,
     Print[
      StringForm[
       "[``/``] validating ``",
       index,
       total,
       key
      ]
     ]
    ];
    result = ValidationResidualQ[residualFn[key], seconds, alreadyNormalizedQ];
    results[key] = result;
    If[progressQ,
     Print[
      StringForm[
       "[``/``] `` -> ``",
       index,
       total,
       key,
       result
      ]
     ]
    ],
    {key, keys}
   ];
   results
  ];

NumericResidualSummary[
   keys_List,
   residualFn_,
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  AssociationMap[
   Function[key,
    StableNumericResidual[
     applyNumericValidationPoint[
      NormalizeValidationResidual[residualFn[key]],
      point,
      precision
     ],
     precision
    ]
   ],
   keys
  ];

End[];
EndPackage[];
