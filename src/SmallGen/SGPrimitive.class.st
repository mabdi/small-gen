Class {
	#name : #SGPrimitive,
	#superclass : #SGState,
	#category : #'SmallGen-Model'
}

{ #category : #accessing }
SGPrimitive class >> tag [
	^ 'Primitive'
]

{ #category : #'instance creation' }
SGPrimitive class >> with: aValue [
	^ self
		new
		theValue: aValue;
		yourself
]

{ #category : #'as yet unclassified' }
SGPrimitive >> genNodeBy: aGenerator [
	^ aGenerator genLiteralArgNodeFrom: self
]
