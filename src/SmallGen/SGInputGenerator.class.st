Class {
	#name : #SGInputGenerator,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'targetClasses',
		'generatedInputs',
		'methodNumber'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGInputGenerator class >> initWith: config [
	^ self new with: config
]

{ #category : #adding }
SGInputGenerator >> addInputsToResult: inputs generatedFrom: anObservation [
	| list |
	list := generatedInputs
		at: anObservation theClass
		ifAbsentPut: OrderedCollection new.
		list addAll: inputs
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genATestMethodName [
	methodNumber := methodNumber+ 1.
	^ 'testMetodNumber' , methodNumber
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genAssgnmentFor: aNode to: aName [
	^ RBAssignmentNode  variable: (RBVariableNode named: aName) value: aNode	
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genForCallNew: aClass [
	^ RBMessageNode receiver: (RBVariableNode named: aClass name) selector: 'new'
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genRefToObjectUnderTest: theClass [
	| newCall |
	newCall := self genForCallNew: theClass.
	^ self genAssgnmentFor: newCall to: 'object'.
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genSequenceWith: anArray [
	| temporaries  |
	temporaries := self genTempVariablesFrom: anArray.
	RBSequenceNode temporaries: temporaries statements: anArray
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genTempVariablesFrom: anArray [
	^ (anArray
		select: #isAssignment
		thenCollect: [ :anAssignment | RBTemporaryNode named: anAssignment variable name ]) 
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> genTestMethodWith: aSequenceNode [
	^ RBMethodNode selector: self genATestMethodName body: aSequenceNode
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputs [
	observations
		do: [ :anObservation | 
			| inputs |
			inputs := self generateInputsFor: anObservation.
			self addInputsToResult: inputs generatedFrom: anObservation
			 ]
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputsFor: anObservation [
	| theMethod theSequence refToObjectUnderTest |
	refToObjectUnderTest := self
		genRefToObjectUnderTest: anObservation theClass.
	theSequence := self genSequenceWith: { refToObjectUnderTest }.
	theMethod := self genTestMethodWith: theSequence.
	self halt
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputsFor: aListOfTargetClass withObservation: aListOfObservation [
	targetClasses := aListOfTargetClass asSet.
	observations := aListOfObservation.
	generatedInputs := Dictionary new.
	methodNumber:= 0.
	self generateInputs.
	^ generatedInputs
]

{ #category : #'instance creation' }
SGInputGenerator >> with: aConfig [
	self initialize.
	config := aConfig 
]
