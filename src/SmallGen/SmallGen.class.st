Class {
	#name : #SmallGen,
	#superclass : #Object,
	#instVars : [
		'config',
		'targets',
		'sampleCode',
		'observations',
		'targetsCapture',
		'generatedInputs',
		'coverage',
		'minimizedCode',
		'minimizedObservation'
	],
	#category : #SmallGen
}

{ #category : #example }
SmallGen class >> example [
	| config result |
	config := SGConfig new.
	result := (self initializeWith: config)
		target: SmallBank;
		targetsCapture: { SmallBank };
		sampleCode: [ | s |
			s := SmallBank new.
			s deposit: 1000 atRandom.
			s balance > 100
				ifTrue: [ s withdraw: 100 ] ];
		generate
]

{ #category : #example }
SmallGen class >> example2 [
	(self initializeWith: SGConfig new)
		target: SAAssertGenerator;
		targetsCapture:
			{SAAssertGenerator.
			SAObservationFalse.
			SAObservationTrue.
			SAObservationNil.
			SAObservationFraction.
			SAObservationPrimitive.
			SAObservationCollection.
			SAObservationObject.
			SAObservationValue.
			SAObservationAbstract};
		sampleCode: [ SmallAmp example ];
		generate
]

{ #category : #example }
SmallGen class >> example3 [
	(self initializeWith: SGConfig new)
		target: SAObservationFalse;
		target: SAObservationTrue;
		target: SAObservationNil;
		target: SAObservationFraction;
		target: SAObservationPrimitive;
		target: SAObservationCollection;
		target: SAObservationObject;
		target: SAObservationValue;
		target: SAObservationAbstract;
		
		targetsCapture:
			{SAAssertGenerator.
			SAObservationFalse.
			SAObservationTrue.
			SAObservationNil.
			SAObservationFraction.
			SAObservationPrimitive.
			SAObservationCollection.
			SAObservationObject.
			SAObservationValue.
			SAObservationAbstract};
		sampleCode: [ SmallAmp example ];
		generate
]

{ #category : #example }
SmallGen class >> initializeWith: aConfig [
	^ self new initializeWith: aConfig
]

{ #category : #'as yet unclassified' }
SmallGen >> coveragEvaluatorClass [
	^ SGMethodCoverage 
]

{ #category : #initialization }
SmallGen >> evaluateCoverag [
	coverage := self getCoveragEvaluator
		generateCoverageFor: targets
		byRunning: generatedInputs 
]

{ #category : #initialization }
SmallGen >> generate [
	self observe.
	"self minimizeCodeBySimilarity."
	self minimizeMethodCalls.
	self generateUsingObservations.
	"self evaluateCoverag.
	self minimizeCodeByCoverage."
	self halt
]

{ #category : #'as yet unclassified' }
SmallGen >> generateUsingObservations [
	generatedInputs := self getInputGenerator
		generateInputsFor: targets
		withObservation: minimizedObservation
		andCaptureTargets: targetsCapture
]

{ #category : #'as yet unclassified' }
SmallGen >> getCoveragEvaluator [
	^ self coveragEvaluatorClass initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getInputGenerator [
	^ self inputGeneratorClass initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getInputMinimizerCoverage [
	^ self inputMinimizerCoverageClass initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getInputMinimizerSimilarity [
	^ self inputMinimizerSimilarityClass  initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getMethodCallsMinimizer [
	^ self methodCallsMinimizerClass initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getObserver [
	^ self observerClass initWith: config
]

{ #category : #initialization }
SmallGen >> initialize [ 
	targets := OrderedCollection new
]

{ #category : #initialization }
SmallGen >> initializeWith: aConfig [
	self initialize. 
	config := aConfig.
	
]

{ #category : #'as yet unclassified' }
SmallGen >> inputGeneratorClass [
	^ SGInputGenerator 
]

{ #category : #'as yet unclassified' }
SmallGen >> inputMinimizerCoverageClass [
	^ SGCoverageMinimize
]

{ #category : #'as yet unclassified' }
SmallGen >> inputMinimizerSimilarityClass [
	^ SGSimilarMinimize 
]

{ #category : #'as yet unclassified' }
SmallGen >> methodCallsMinimizerClass [
	^ SGMethodCallMinimize 
]

{ #category : #initialization }
SmallGen >> minimizeCodeByCoverage [
	minimizedCode := self getInputMinimizerCoverage
		minimizerFor: coverage
		inputs: generatedInputs
]

{ #category : #initialization }
SmallGen >> minimizeCodeBySimilarity [
	minimizedObservation := self getInputMinimizerSimilarity
		minimizerFor: observations
]

{ #category : #initialization }
SmallGen >> minimizeMethodCalls [
	minimizedObservation := self getMethodCallsMinimizer
		minimizerFor: observations
]

{ #category : #initialization }
SmallGen >> observe [
	observations := self getObserver
		                generateObservationFor: targets
			targetsCapture: targetsCapture                 
		byRunning: sampleCode
]

{ #category : #'as yet unclassified' }
SmallGen >> observerClass [
	^ SGObserver 
]

{ #category : #accessing }
SmallGen >> sampleCode: aCode [
	sampleCode:= aCode
]

{ #category : #accessing }
SmallGen >> target: aTargetClass [
	 targets add: aTargetClass
]

{ #category : #accessing }
SmallGen >> targetsCapture: aClassList [
	targetsCapture:= aClassList
]
