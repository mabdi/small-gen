Class {
	#name : #SGClassHistory,
	#superclass : #SGLiteralHistory,
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGClassHistory >> genNodeBy: aGenerator [
	^ aGenerator genVariableArgNodeFrom: self
]
