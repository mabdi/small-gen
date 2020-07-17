Class {
	#name : #SGState,
	#superclass : #Object,
	#instVars : [
		'theValue'
	],
	#category : #'SmallGen-Model'
}

{ #category : #'instance creation' }
SGState class >> with: anObject [
	^ self new
		initializeWith: anObject;
		yourself
]

{ #category : #converting }
SGState >> dictionaryRepresentation [
	^ self subclassResponsibility 
]

{ #category : #initialization }
SGState >> initializeWith: anObject [
	self theValue: anObject 
]

{ #category : #'as yet unclassified' }
SGState >> state_identity [
	^ theValue smallgen_state_identity 
]

{ #category : #accessing }
SGState >> theValue [
	^ theValue
]

{ #category : #accessing }
SGState >> theValue: anObject [
	theValue := anObject 
]
