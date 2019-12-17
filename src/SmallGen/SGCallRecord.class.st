Class {
	#name : #SGCallRecord,
	#superclass : #Object,
	#instVars : [
		'selector',
		'args'
	],
	#category : #SmallGen
}

{ #category : #accessing }
SGCallRecord >> args [
	^ args
]

{ #category : #accessing }
SGCallRecord >> args: anObject [
	args := anObject
]

{ #category : #copying }
SGCallRecord >> copy [ 
	^ self class new args: [ :arg | arg copy ]; selector: selector 
]

{ #category : #accessing }
SGCallRecord >> selector [
	^ selector
]

{ #category : #accessing }
SGCallRecord >> selector: anObject [
	selector := anObject
]
