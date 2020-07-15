Extension { #name : #Collection }

{ #category : #'*SmallGen' }
Collection >> smallgen_state [
	^ (SGCompound with: self) dictionaryRepresentation
]
