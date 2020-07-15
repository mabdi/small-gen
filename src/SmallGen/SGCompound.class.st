Class {
	#name : #SGCompound,
	#superclass : #SGState,
	#category : #'SmallGen-Model'
}

{ #category : #converting }
SGCompound >> dictionaryRepresentation [
	^ 
			{('model' -> self class name).
			('data' -> (self theValue collect: #dictionaryRepresentation)).
			('type' -> self theValue class name)} asDictionary
]
