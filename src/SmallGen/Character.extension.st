Extension { #name : #Character }

{ #category : #'*SmallGen' }
Character >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation
]
