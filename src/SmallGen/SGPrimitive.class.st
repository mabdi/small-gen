Class {
	#name : #SGPrimitive,
	#superclass : #SGState,
	#category : #'SmallGen-Model'
}

{ #category : #converting }
SGPrimitive >> dictionaryRepresentation [
	^ 
			{('model' -> self class name).
			('data' -> self theValue).
			('type' -> self theValue class name)} asDictionary
]
