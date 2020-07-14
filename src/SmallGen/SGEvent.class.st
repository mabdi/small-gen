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
SGEvent >> asString [
	self flag: #todo
]

{ #category : #printing }
SGEvent >> printOn: aStream [
	aStream
		nextPutAll: '[';
		nextPutAll: selector asString;
		space;
		nextPutAll: ('' join: (self args collect: #asString));
		nextPutAll: ']'
]

{ #category : #accessing }
SGEvent >> selector [
	^ selector
]

{ #category : #accessing }
SGEvent >> selector: anObject [
	selector := anObject
]
