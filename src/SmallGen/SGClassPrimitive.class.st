Class {
	#name : #SGClassPrimitive,
	#superclass : #SGPrimitive,
	#category : #'SmallGen-Model'
}

{ #category : #converting }
SGClassPrimitive >> dictionaryRepresentation [
	^ 
			{('model' -> self class name).
			('data' -> self theValue name)} asDictionary
]
