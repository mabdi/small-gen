Class {
	#name : #SGInputGenerator,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'targetClasses',
		'generatedInputs'
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
	self halt	
]

{ #category : #'as yet unclassified' }
SGInputGenerator >> generateInputsFor: aListOfTargetClass withObservation: aListOfObservation [
	targetClasses := aListOfTargetClass asSet.
	observations := aListOfObservation.
	generatedInputs := Dictionary new.
	self generateInputs.
	^ generatedInputs
]

{ #category : #'instance creation' }
SGInputGenerator >> with: aConfig [
	self initialize.
	config := aConfig 
]
