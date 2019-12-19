Class {
	#name : #SGLiteralHistory,
	#superclass : #SGHistory,
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGLiteralHistory class >> for: anObject [
	^ self new
		for: anObject;
		primitive: true;
		yourself
]

{ #category : #'as yet unclassified' }
SGLiteralHistory >> genNodeBy: aGenerator [
	^ aGenerator genLiteralArgNodeFrom: self
]
