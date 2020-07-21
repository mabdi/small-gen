Class {
	#name : #SGSkipped,
	#superclass : #SGState,
	#category : #'SmallGen-Model'
}

{ #category : #converting }
SGSkipped >> dictionaryRepresentation [
	^ 
			{('model' -> self class name).
			('type' -> self theValue class name)} asDictionary
]
