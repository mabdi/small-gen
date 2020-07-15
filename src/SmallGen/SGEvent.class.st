Class {
	#name : #SGEvent,
	#superclass : #Object,
	#instVars : [
		'selector',
		'argsBefore'
	],
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGEvent >> argsBefore [
	^ argsBefore
]

{ #category : #accessing }
SGEvent >> argsBefore: anObject [
	argsBefore := anObject
]

{ #category : #converting }
SGEvent >> dictionaryRepresentation [
	^ 
			{('model' -> self class name).
			('args_before' -> self argsBefore asArray).
			('selector' -> self selector)} asDictionary
]

{ #category : #accessing }
SGEvent >> selector [
	^ selector
]

{ #category : #accessing }
SGEvent >> selector: anObject [
	selector := anObject
]
