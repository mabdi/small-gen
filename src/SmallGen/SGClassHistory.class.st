Class {
	#name : #SGClassHistory,
	#superclass : #SGLiteralHistory,
	#category : #'SmallGen-Model'
}

{ #category : #'as yet unclassified' }
SGClassHistory >> genNodeBy: aGenerator [
	^ aGenerator genClassNameNodeFrom: self
]
