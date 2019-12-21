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
	#category : #'SmallGen-Core'
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

{ #category : #experiment }
SmallGen >> evaluateCoverag [
	coverage := self getCoveragEvaluator
		generateCoverageFor: targets
		byRunning: generatedInputs 
]

{ #category : #initialization }
SmallGen >> generate [
	self stepObservation.
	self stepFilterRecords.
	self stepFilterHistories.
	self stepSynthesis.
	"self evaluateCoverag.
	self minimizeCodeByCoverage."
	self halt
]

{ #category : #experiment }
SmallGen >> getCoveragEvaluator [
	^ SGMethodCoverage  initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getInputGenerator [
	^ SGInputGenerator initWith: config
]

{ #category : #experiment }
SmallGen >> getInputMinimizerCoverage [
	^ SGCoverageFilter  initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getInputMinimizerSimilarity [
	^ SGSimilarFilter initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getMethodCallsMinimizer [
	^ SGMethodCallFilter initWith: config
]

{ #category : #'as yet unclassified' }
SmallGen >> getObserver [
	^ SGObserver initWith: config
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

{ #category : #experiment }
SmallGen >> minimizeCodeByCoverage [
	minimizedCode := self getInputMinimizerCoverage
		minimizerFor: coverage
		inputs: generatedInputs
]

{ #category : #accessing }
SmallGen >> sampleCode: aCode [
	sampleCode:= aCode
]

{ #category : #initialization }
SmallGen >> stepFilterHistories [
	observations := self getInputMinimizerSimilarity
		minimizerFor: observations
]

{ #category : #initialization }
SmallGen >> stepFilterRecords [
	observations := self getMethodCallsMinimizer
		minimizerFor: observations
]

{ #category : #initialization }
SmallGen >> stepObservation [
	observations := self getObserver
		generateObservationFor: targets
		targetsCapture: targetsCapture
		byRunning: sampleCode
]

{ #category : #'as yet unclassified' }
SmallGen >> stepSynthesis [
	generatedInputs := self getInputGenerator
		generateInputsFor: targets
		withObservation: minimizedObservation
		andCaptureTargets: targetsCapture
]

{ #category : #accessing }
SmallGen >> target: aTargetClass [
	 targets add: aTargetClass
]

{ #category : #accessing }
SmallGen >> targetsCapture: aClassList [
	targetsCapture:= aClassList
]
