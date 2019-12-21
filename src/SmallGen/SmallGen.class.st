Class {
	#name : #SmallGen,
	#superclass : #Object,
	#instVars : [
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
	^ self new
		target: SmallBank;
		targetsCapture: {SmallBank};
		sampleCode: [ | s |
			s := SmallBank new.
			s deposit: 1000 atRandom.
			s balance > 100
				ifTrue: [ s withdraw: 100 ] ];
		generate
]

{ #category : #example }
SmallGen class >> example2 [
	^ self new
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
	^ self new
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

{ #category : #action }
SmallGen >> generate [
	self stepObservation.
	self stepFilterRecords.
	self stepFilterHistories.
	self stepSynthesis.
	"self evaluateCoverag.
	self minimizeCodeByCoverage."
	self halt
]

{ #category : #initialization }
SmallGen >> initialize [ 
	targets := OrderedCollection new
]

{ #category : #accessing }
SmallGen >> sampleCode: aCode [
	sampleCode:= aCode
]

{ #category : #steps }
SmallGen >> stepFilterHistories [
	observations := SGHistoryFilter new 
		minimizerFor: observations
]

{ #category : #steps }
SmallGen >> stepFilterRecords [
	observations := SGRecordFilter new
		minimizerFor: observations
]

{ #category : #steps }
SmallGen >> stepObservation [
	observations := SGObserver new
		generateObservationFor: targets
		targetsCapture: targetsCapture
		byRunning: sampleCode
]

{ #category : #steps }
SmallGen >> stepSynthesis [
	generatedInputs := SGInputGenerator new
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
