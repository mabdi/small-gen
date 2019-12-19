Class {
	#name : #SGLiteralHistory,
	#superclass : #SGCallHistory,
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGLiteralHistory class >> forPrimitive: anObject [
	^ self new
		for: anObject;
		primitive: true;
		yourself
]

{ #category : #'as yet unclassified' }
SGLiteralHistory >> genNodeBy: aGenerator [
	^ aGenerator genLiteralArgNodeFrom: self
]
