Class {
	#name : #SmallGen,
	#superclass : #Object,
	#instVars : [
		'sampleCode',
		'observations',
		'classesToObserve',
		'generatedInputs',
		'classesToGenerate'
	],
	#category : #'SmallGen-Core'
}

{ #category : #example }
SmallGen class >> example [
	^ self new
		classesToGenerate: {SmallBank};
		classesToObserve: {SmallBank};
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
		classesToGenerate: {SAAssertGenerator};
		classesToObserve:
			{SAAssertGenerator.
			SAObservationFalse.
			SAObservationTrue.
			SAObservationNil.
			SAObservationFraction.
			SAObservationPrimitive.
			SAObservationCollection.
			SAObservationError.
			SAObservationObject.
			SAObservationValue.
			SAObservationAbstract};
		sampleCode: [ SmallAmp example ];
		generate
]

{ #category : #example }
SmallGen class >> example3 [
	^ self new
		classesToGenerate: {SAObservationFalse. SAObservationTrue.
		SAObservationNil.
		SAObservationFraction.
		SAObservationPrimitive.
		SAObservationCollection.
		SAObservationObject.
		SAObservationValue.
		SAObservationAbstract};
		classesToObserve:
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
SmallGen class >> exampleMocked [
	^ self new
		classesToGenerate: {SmallBank};
		classesToObserve: {SmallBank};
		sampleCode: [ | s |
			s := SmallBank new.
			s deposit: 1000 atRandom.
			s balance > 100
				ifTrue: [ s withdraw: 100 ] ];
		generateMocked
]

{ #category : #example }
SmallGen class >> exampleMocked2 [
	^ self new
		classesToGenerate: {SAAssertGenerator};
		classesToObserve:
			{SAAssertGenerator.
			SAObservationFalse.
			SAObservationTrue.
			SAObservationNil.
			SAObservationFraction.
			SAObservationPrimitive.
			SAObservationCollection.
			SAObservationError.
			SAObservationObject.
			SAObservationValue.
			SAObservationAbstract};
		sampleCode: [ SmallAmp example ];
		generateMocked
]

{ #category : #example }
SmallGen class >> exampleMocked3 [
	^ self new
		classesToGenerate:
			{SAObservationFalse.
			SAObservationTrue.
			SAObservationNil.
			SAObservationFraction.
			SAObservationPrimitive.
			SAObservationCollection.
			SAObservationObject.
			SAObservationValue.
			SAObservationAbstract};
		classesToObserve:
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
		generateMocked
]

{ #category : #accessing }
SmallGen >> classesToGenerate: anObject [
	classesToGenerate := anObject asSet
]

{ #category : #accessing }
SmallGen >> classesToObserve: aClassList [
	classesToObserve := aClassList asSet
]

{ #category : #action }
SmallGen >> generate [
	self stepObservation.
	observations ifEmpty: [ ^ self halt ].
	self stepPrepare.
	self stepSynthesis.
	self stepInstallGenerated.
	SGBuildTestClass new defaultTempPackage asPackage browse.
]

{ #category : #action }
SmallGen >> generateMocked [
	self stepObservation.
	observations ifEmpty: [ ^ self halt ].
	observations := SGMockedStrategy new
		observations: observations;
		classesToGenerate: classesToGenerate;
		classesToObserve: classesToObserve;
		prepare.
	self stepSynthesis.
	self stepInstallGenerated.
	SGBuildTestClass new defaultTempPackage asPackage browse
]

{ #category : #accessing }
SmallGen >> sampleCode: aCode [
	sampleCode:= aCode
]

{ #category : #steps }
SmallGen >> stepInstallGenerated [
	generatedInputs keysAndValuesDo: [ :key :value | SGBuildTestClass new buildFor: key methods: value ]
	
]

{ #category : #steps }
SmallGen >> stepObservation [
	observations := SGObserver new
		generateObservationFor: classesToGenerate
		targetsCapture: classesToObserve
		byRunning: sampleCode
]

{ #category : #steps }
SmallGen >> stepPrepare [
	observations := SGShortestStrategy new
		observations: observations;
		classesToGenerate: classesToGenerate;
		classesToObserve: classesToObserve;
		prepare
]

{ #category : #steps }
SmallGen >> stepSynthesis [
	generatedInputs := SGMethodSynthesizer new
		generateInputsFor: classesToGenerate
		withObservation: observations
		andCaptureTargets: classesToObserve
]
