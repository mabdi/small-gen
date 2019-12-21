Class {
	#name : #SGLiteralHistory,
	#superclass : #SGHistory,
	#category : #'SmallGen-Model'
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

{ #category : #accessing }
SGLiteralHistory >> setTheValue: anObject [
	super setTheValue: anObject.
	theValue := anObject
]
