Class {
	#name : #SGEvent,
	#superclass : #Object,
	#instVars : [
		'selector',
		'argsBefore',
		'argsAfter',
		'stateBefore',
		'stateAfter',
		'result'
	],
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGEvent >> argsAfter [
	^ argsAfter
]

{ #category : #accessing }
SGEvent >> argsAfter: anObject [
	argsAfter := anObject
]

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
	^ {('model' -> self class name).
	('args_before' -> self argsBefore asArray).
	('args_after' -> self argsAfter asArray).
	('state_before' -> self stateBefore).
	('state_after' -> self stateAfter).
	('result' -> self result).
	('selector' -> self selector)} asDictionary
]

{ #category : #accessing }
SGEvent >> result [
	^ result
]

{ #category : #accessing }
SGEvent >> result: anObject [
	result := anObject
]

{ #category : #accessing }
SGEvent >> selector [
	^ selector
]

{ #category : #accessing }
SGEvent >> selector: anObject [
	selector := anObject
]

{ #category : #accessing }
SGEvent >> stateAfter [
	^ stateAfter
]

{ #category : #accessing }
SGEvent >> stateAfter: anObject [
	stateAfter := anObject
]

{ #category : #accessing }
SGEvent >> stateBefore [
	^ stateBefore
]

{ #category : #accessing }
SGEvent >> stateBefore: anObject [
	stateBefore := anObject
]
