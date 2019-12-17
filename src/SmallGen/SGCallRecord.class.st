Class {
	#name : #SGCallRecord,
	#superclass : #Object,
	#instVars : [
		'selector',
		'args',
		'theClass'
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

{ #category : #accessing }
SGCallRecord >> theClass [
^theClass
]

{ #category : #accessing }
SGCallRecord >> theClass: aClass [
theClass:=aClass
]
