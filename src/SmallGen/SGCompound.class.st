Class {
	#name : #SGCompound,
	#superclass : #SGState,
	#category : #'SmallGen-Model'
}

{ #category : #converting }
SGCompound >> dictionaryRepresentation [
	^ {('model' -> self class name).
	('data' -> (self theValue collect: [:x | x smallgen_state ])).
	('uuid' -> (self theValue basicIdentityHash)).
	('type' -> self theValue class name)} asDictionary
]
