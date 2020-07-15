Extension { #name : #String }

{ #category : #'*SmallGen' }
String >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]
