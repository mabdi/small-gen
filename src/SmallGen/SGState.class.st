Class {
	#name : #SGState,
	#superclass : #Object,
	#instVars : [
		'theValue'
	],
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGState class >> tag [
	self subclassResponsibility 
]

{ #category : #accessing }
SGState >> theValue [
	^ theValue
]

{ #category : #accessing }
SGState >> theValue: anObject [
	theValue := anObject 
]
