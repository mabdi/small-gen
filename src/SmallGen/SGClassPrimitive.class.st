Class {
	#name : #SGClassPrimitive,
	#superclass : #SGPrimitive,
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGClassPrimitive class >> tag [
	^ 'Class'
]

{ #category : #'as yet unclassified' }
SGClassPrimitive >> genNodeBy: aGenerator [
	^ aGenerator genClassNameNodeFrom: self
]
