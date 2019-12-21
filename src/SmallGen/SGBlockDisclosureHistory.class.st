Class {
	#name : #SGBlockDisclosureHistory,
	#superclass : #SGLiteralHistory,
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGBlockDisclosureHistory >> genNodeBy: aGenerator [
	self halt.
	^ aGenerator genClassNameNodeFrom: self
]

{ #category : #accessing }
SGBlockDisclosureHistory >> setTheValue: anObject [
	theUniqueId := anObject basicIdentityHash.
	self theClass: anObject class.
	theValue := anObject
]
