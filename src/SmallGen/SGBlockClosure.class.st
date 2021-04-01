Class {
	#name : #SGBlockClosure,
	#superclass : #SGState,
	#instVars : [
		'theReqVars'
	],
	#category : #'SmallGen-Model'
}

{ #category : #initialization }
SGBlockClosure >> captureRequiredVariables [
	theReqVars := theValue body allVariables asSet
		difference: theValue allDefinedVariables asSet.
	
]

{ #category : #converting }
SGBlockClosure >> dictionaryRepresentation [
	^ {('model' -> self class name).
	('data' -> self theData).
	('type' -> self theValue class name)} asDictionary
]

{ #category : #initialization }
SGBlockClosure >> initializeWith: anObject [
	self initialize.
	self theValue: anObject.
	self captureRequiredVariables
]

{ #category : #converting }
SGBlockClosure >> theData [
	^ theValue sourceNode clone
]
